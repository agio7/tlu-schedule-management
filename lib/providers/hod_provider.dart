import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hod_models.dart';
import '../models/users.dart';
import '../models/leave_requests.dart';
import '../models/makeup_requests.dart';
import '../models/schedules.dart';
import '../models/course_sections.dart';
import '../services/user_service.dart';
import '../services/lesson_service.dart';
import '../models/lessons.dart';
import '../services/leave_request_service.dart';
import '../services/makeup_request_service.dart';
import '../services/schedule_service.dart';
import '../services/course_section_service.dart';
import '../services/attendance_service.dart';
import '../services/subject_service.dart';
import '../services/classroom_service.dart';
import '../services/room_service.dart';
import 'sample_data_provider.dart';

class AppState extends ChangeNotifier {
  int currentTab = 0;
  String? _departmentId;
  List<String> _departmentTeacherIds = [];
  String? _selectedLecturerForSchedule; // Lưu tên giảng viên để filter ở màn hình lịch dạy
  String? _selectedClassForAttendance; // Lưu lớp để filter ở màn hình thống kê điểm danh
  String? _selectedSubjectForAttendance; // Lưu môn học để filter ở màn hình thống kê điểm danh
  bool _shouldShowAttendanceStats = false; // Flag để chuyển đến màn hình thống kê điểm danh
  
  // Flag để chuyển đổi giữa Firebase và sample data
  static const bool useSampleData = false; // Đổi thành false để dùng Firebase
  // Bật để lấy toàn bộ dữ liệu (không giới hạn theo giảng viên/phòng ban) cho mục đích kiểm tra
  static const bool loadAllDataForDebug = true;

  // Data from Firebase or Sample
  List<Lecturer> _lecturers = [];
  List<LeaveRequest> _leaveRequests = [];
  List<MakeupRegistration> _makeups = [];
  List<ScheduleItem> _schedules = [];
  // Internal sources to prevent stream overwrites
  List<ScheduleItem> _schedulesFromSchedules = [];
  List<ScheduleItem> _schedulesFromLessons = [];
  List<AlertItem> _alerts = [];
  List<String> _subjectNames = [];

  // Stream subscriptions (chỉ dùng khi useSampleData = false)
  StreamSubscription<List<Users>>? _usersSubscription;
  StreamSubscription<List<LeaveRequests>>? _leaveRequestsSubscription;
  StreamSubscription<List<MakeupRequests>>? _makeupRequestsSubscription;
  StreamSubscription<List<Schedules>>? _schedulesSubscription;
  StreamSubscription? _subjectsSubscription;
  StreamSubscription<List<Lessons>>? _lessonsSubscription;

  List<Lecturer> get lecturers => _lecturers;
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  List<MakeupRegistration> get makeups => _makeups;
  List<ScheduleItem> get schedules => _schedules;
  List<AlertItem> get alerts => _alerts;
  List<String> get subjects => _subjectNames;

  // KPI values
  int get totalLecturers => _lecturers.length;
  int get totalSubjects => _schedules.map((s) => s.subject).toSet().length;
  int get totalSessions => _schedules.length;

  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  // Set lecturer filter cho màn hình lịch dạy
  void setLecturerForSchedule(String? lecturerName) {
    _selectedLecturerForSchedule = lecturerName;
    notifyListeners();
  }

  // Get lecturer filter cho màn hình lịch dạy
  String? get selectedLecturerForSchedule => _selectedLecturerForSchedule;

  // Clear lecturer filter sau khi đã sử dụng
  void clearLecturerForSchedule() {
    _selectedLecturerForSchedule = null;
    notifyListeners();
  }

  // Set filter cho màn hình thống kê điểm danh (khi bấm vào môn đã dạy)
  void setAttendanceStatsFilter(String className, String subject) {
    _selectedClassForAttendance = className;
    _selectedSubjectForAttendance = subject;
    _shouldShowAttendanceStats = true;
    notifyListeners();
  }

  // Get filter cho màn hình thống kê điểm danh
  String? get selectedClassForAttendance => _selectedClassForAttendance;
  String? get selectedSubjectForAttendance => _selectedSubjectForAttendance;
  bool get shouldShowAttendanceStats => _shouldShowAttendanceStats;

  // Clear filter sau khi đã sử dụng
  void clearAttendanceStatsFilter() {
    _selectedClassForAttendance = null;
    _selectedSubjectForAttendance = null;
    _shouldShowAttendanceStats = false;
    notifyListeners();
  }

  // Initialize with department ID
  Future<void> initialize(String departmentId) async {
    print('🔍 AppState: Initializing with departmentId: $departmentId');
    print('🔍 AppState: useSampleData = $useSampleData');
    _departmentId = departmentId;
    
    try {
      if (useSampleData) {
        await loadSampleData();
        print('✅ AppState: Successfully loaded sample data');
      } else {
        await loadDataFromFirebase();
        print('✅ AppState: Successfully loaded data from Firebase');
      }
    } catch (e, stackTrace) {
      print('❌ AppState: Error loading data: $e');
      print('❌ AppState: Stack trace: $stackTrace');
      // Fallback về sample data nếu có lỗi
      print('⚠️ AppState: Falling back to sample data');
      await loadSampleData();
    }
  }

  // Load sample data for testing
  Future<void> loadSampleData() async {
    print('🔍 AppState: Loading sample data...');
    
    // Load từ SampleDataProvider
    _lecturers = SampleDataProvider.getSampleLecturers();
    _leaveRequests = SampleDataProvider.getSampleLeaveRequests();
    _makeups = SampleDataProvider.getSampleMakeupRequests();
    _schedules = SampleDataProvider.getSampleSchedules();
    _alerts = SampleDataProvider.getSampleAlerts();
    
    print('✅ AppState: Loaded ${_lecturers.length} lecturers');
    print('✅ AppState: Loaded ${_leaveRequests.length} leave requests');
    print('✅ AppState: Loaded ${_makeups.length} makeup requests');
    print('✅ AppState: Loaded ${_schedules.length} schedules');
    print('✅ AppState: Loaded ${_alerts.length} alerts');
    
    notifyListeners();
  }

  // Load data from Firebase
  Future<void> loadDataFromFirebase() async {
    if (_departmentId == null) {
      print('⚠️ AppState: departmentId is null, cannot load data');
      return;
    }

    print('🔍 AppState: Loading TEACHERS by role (ignore department)');
    
    // Load teachers in department
    _usersSubscription?.cancel();
    
    // Sử dụng first để lấy data ngay lập tức thay vì stream
    try {
      final usersStream = UserService.getUsersByRoleStream('teacher');
      final users = await usersStream.first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ AppState: Timeout loading users, returning empty list');
          return <Users>[];
        },
      );
      
      print('✅ AppState: Loaded ${users.length} teachers');
      
      final teachers = users; // already filtered to teachers by Firestore
      print('✅ AppState: Found ${teachers.length} teachers');
      
      _departmentTeacherIds = teachers.map((t) => t.id).toList();
      
      // Convert to Lecturer model
      _lecturers = await _convertUsersToLecturers(teachers);
      print('✅ AppState: Converted ${_lecturers.length} lecturers');
      notifyListeners();
      
      // Load related data (non-blocking)
      _loadSchedules().catchError((e) {
        print('❌ AppState: Error loading schedules: $e');
      });
      _loadLeaveRequests().catchError((e) {
        print('❌ AppState: Error loading leave requests: $e');
      });
      _loadMakeupRequests().catchError((e) {
        print('❌ AppState: Error loading makeup requests: $e');
      });
      
      // Subscribe to stream for realtime updates
      _usersSubscription = UserService.getUsersByRoleStream('teacher')
          .listen((updatedUsers) async {
        try {
          final updatedTeachers = updatedUsers; // already teachers
          _departmentTeacherIds = updatedTeachers.map((t) => t.id).toList();
          _lecturers = await _convertUsersToLecturers(updatedTeachers);
          notifyListeners();
        } catch (e) {
          print('❌ AppState: Error in users stream listener: $e');
        }
      });

      // Load all subjects (for filters)
      _subjectsSubscription?.cancel();
      _subjectsSubscription = SubjectService.getSubjectsStream().listen((subjectModels) {
        _subjectNames = subjectModels.map((s) => s.name).where((e) => e.isNotEmpty).toSet().toList();
        notifyListeners();
      });
    } catch (e) {
      print('❌ AppState: Error in loadDataFromFirebase: $e');
      rethrow;
    }
  }

  // Convert Users to Lecturers
  Future<List<Lecturer>> _convertUsersToLecturers(List<Users> users) async {
    final lecturers = <Lecturer>[];
    
    for (final user in users) {
      // Calculate hours from schedules
      int hoursPlanned = 0;
      int hoursActual = 0;
      
      try {
        final courseSections = await CourseSectionService
            .getCourseSectionsByTeacherStream(user.id)
            .first;
        
        for (final section in courseSections) {
          final schedules = await ScheduleService
              .getSchedulesByCourseSectionStream(section.id)
              .first;
          
          for (final schedule in schedules) {
            final duration = schedule.endTime.difference(schedule.startTime);
            hoursPlanned += duration.inHours;
            
            if (schedule.status == ScheduleStatus.completed) {
              hoursActual += duration.inHours;
            }
          }
        }
      } catch (e) {
        print('Error calculating hours for ${user.fullName}: $e');
      }
      
      lecturers.add(Lecturer(
        name: user.fullName,
        email: user.email,
        phone: user.phoneNumber ?? '',
        title: user.academicRank ?? 'Giảng viên',
        subject: user.specialization ?? '',
        hoursPlanned: hoursPlanned,
        hoursActual: hoursActual,
      ));
    }
    
    return lecturers;
  }

  // Load schedules
  Future<void> _loadSchedules() async {
    _schedulesSubscription?.cancel();
    
    final allSchedules = <ScheduleItem>[];

    // Chế độ debug: lấy tất cả schedules trực tiếp (bỏ mọi ràng buộc)
    if (loadAllDataForDebug) {
      try {
        _schedulesSubscription = ScheduleService.getSchedulesStream().listen((firestoreSchedules) async {
          final nextSchedules = <ScheduleItem>[];
          for (final schedule in firestoreSchedules) {
            // Lấy thông tin section liên quan (có thể thiếu)
            final sectionDetails = await CourseSectionService.getCourseSectionById(schedule.courseSectionId);

            // Lấy tên subject, lớp, phòng, giảng viên
            String subjectName = '';
            String className = '';
            String roomName = '';
            String teacherName = '';
            try {
              if (sectionDetails != null) {
                final teacher = await UserService.getUserById(sectionDetails.teacherId);
                teacherName = teacher?.fullName ?? '';
                final subject = await SubjectService.getSubjectById(sectionDetails.subjectId);
                subjectName = subject?.name ?? '';
                final classroom = await ClassroomService.getClassroomById(sectionDetails.classroomId);
                className = classroom?.name ?? '';
                final room = await RoomService.getRoomById(sectionDetails.roomId);
                roomName = room?.name ?? '';
              }
            } catch (e) {
              print('Error loading schedule details: $e');
            }

            // Map status và định dạng tiết học
            SessionStatus status;
            switch (schedule.status) {
              case ScheduleStatus.completed:
                status = SessionStatus.daDay;
                break;
              case ScheduleStatus.cancelled:
                status = SessionStatus.nghi;
                break;
              default:
                status = SessionStatus.chuaDay;
            }
            final startHour = schedule.startTime.hour;
            final endHour = schedule.endTime.hour;
            final startMin = schedule.startTime.minute;
            final endMin = schedule.endTime.minute;
            final session = '$startHour:${startMin.toString().padLeft(2, '0')}-$endHour:${endMin.toString().padLeft(2, '0')}';

            nextSchedules.add(ScheduleItem(
              lecturer: teacherName.isNotEmpty ? teacherName : 'Không rõ',
              subject: subjectName.isNotEmpty ? subjectName : 'Không rõ',
              className: className.isNotEmpty ? className : 'Không rõ',
              date: schedule.startTime,
              session: session,
              room: roomName.isNotEmpty ? roomName : 'Không rõ',
              status: status,
              attendance: null,
            ));
          }
          _schedulesFromSchedules = nextSchedules; // keep source A
          _rebuildSchedules();
        });

        // Also load raw lessons collection and merge into schedules list for display
        _lessonsSubscription?.cancel();
        _lessonsSubscription = LessonService.getLessonsStream().listen((lessons) async {
          final lessonItems = <ScheduleItem>[];
          for (final l in lessons) {
            // Combine date + start/end time strings
            DateTime start = l.date;
            DateTime end = l.date;
            try {
              final sParts = l.startTime.split(':');
              final eParts = l.endTime.split(':');
              if (sParts.length >= 2) {
                start = DateTime(l.date.year, l.date.month, l.date.day, int.tryParse(sParts[0]) ?? 0, int.tryParse(sParts[1]) ?? 0);
              }
              if (eParts.length >= 2) {
                end = DateTime(l.date.year, l.date.month, l.date.day, int.tryParse(eParts[0]) ?? 0, int.tryParse(eParts[1]) ?? 0);
              }
            } catch (_) {}

            // Map status
            SessionStatus status;
            switch (l.status) {
              case 'completed':
                status = SessionStatus.daDay;
                break;
              case 'ongoing':
                status = SessionStatus.chuaDay; // no direct mapping, treat as đang dạy -> chuaDay/daDay? choose chuaDay
                break;
              default:
                status = SessionStatus.chuaDay;
            }

            final session = '${start.hour}:${start.minute.toString().padLeft(2, '0')}-${end.hour}:${end.minute.toString().padLeft(2, '0')}';

            // Lấy tên giảng viên từ teacherId
            String teacherName = 'Không rõ';
            if (l.teacherId != null && l.teacherId!.isNotEmpty) {
              try {
                final teacher = await UserService.getUserById(l.teacherId!);
                teacherName = teacher?.fullName ?? 'Không rõ';
              } catch (e) {
                print('Error loading teacher for lesson ${l.id}: $e');
              }
            }

            lessonItems.add(ScheduleItem(
              lecturer: teacherName,
              subject: l.subject ?? '',
              className: l.className,
              date: start,
              session: session,
              room: l.room ?? '',
              status: status,
              attendance: null,
            ));
          }

          // Replace source B and rebuild combined list
          _schedulesFromLessons = lessonItems;
          _rebuildSchedules();
        });
      } catch (e) {
        print('Error loading all schedules (debug): $e');
      }
      return;
    }

    for (final teacherId in _departmentTeacherIds) {
      try {
        final courseSections = await CourseSectionService
            .getCourseSectionsByTeacherStream(teacherId)
            .first;
        
        for (final section in courseSections) {
          _schedulesSubscription = ScheduleService
              .getSchedulesByCourseSectionStream(section.id)
              .listen((schedules) async {
            // Get section details
            final sectionDetails = await CourseSectionService.getCourseSectionById(section.id);
            if (sectionDetails == null) return;
            
            // Get subject, classroom, room names
            String subjectName = '';
            String className = '';
            String roomName = '';
            String teacherName = '';
            
            try {
              final teacher = await UserService.getUserById(sectionDetails.teacherId);
              teacherName = teacher?.fullName ?? '';
              
              final subject = await SubjectService.getSubjectById(sectionDetails.subjectId);
              subjectName = subject?.name ?? '';
              
              final classroom = await ClassroomService.getClassroomById(sectionDetails.classroomId);
              className = classroom?.name ?? '';
              
              final room = await RoomService.getRoomById(sectionDetails.roomId);
              roomName = room?.name ?? '';
            } catch (e) {
              print('Error loading schedule details: $e');
            }
            
            // Convert schedules to ScheduleItems
            final scheduleItems = schedules.map((schedule) {
              // Map status
              SessionStatus status;
              switch (schedule.status) {
                case ScheduleStatus.completed:
                  status = SessionStatus.daDay;
                  break;
                case ScheduleStatus.cancelled:
                  status = SessionStatus.nghi;
                  break;
                default:
                  status = schedule.startTime.isBefore(DateTime.now())
                      ? SessionStatus.chuaDay
                      : SessionStatus.chuaDay;
              }
              
              // Format session time
              final startHour = schedule.startTime.hour;
              final endHour = schedule.endTime.hour;
              final startMin = schedule.startTime.minute;
              final endMin = schedule.endTime.minute;
              final session = '$startHour:${startMin.toString().padLeft(2, '0')}-$endHour:${endMin.toString().padLeft(2, '0')}';
              
              // Get attendance if completed
              String? attendance;
              if (status == SessionStatus.daDay) {
                // Load attendance from Firebase (simplified)
                attendance = null; // Will be loaded separately if needed
              }
              
              return ScheduleItem(
                lecturer: teacherName,
                subject: subjectName,
                className: className,
                date: schedule.startTime,
                session: session,
                room: roomName,
                status: status,
                attendance: attendance,
              );
            }).toList();
            
            allSchedules.addAll(scheduleItems);
            _schedules = allSchedules;
            notifyListeners();
          });
        }
      } catch (e) {
        print('Error loading schedules for teacher $teacherId: $e');
      }
    }
  }

  // Load leave requests
  Future<void> _loadLeaveRequests() async {
    _leaveRequestsSubscription?.cancel();
    
    final allLeaveRequests = <LeaveRequest>[];

    if (loadAllDataForDebug) {
      _leaveRequestsSubscription = LeaveRequestService
          .getLeaveRequestsStream()
          .listen((firestoreRequests) async {
        for (final firestoreRequest in firestoreRequests) {
          final teacher = await UserService.getUserById(firestoreRequest.teacherId);
          final teacherName = teacher?.fullName ?? '';
          // Xử lý scheduleId có thể null hoặc rỗng
          final schedule = (firestoreRequest.scheduleId != null && firestoreRequest.scheduleId!.isNotEmpty)
              ? await ScheduleService.getScheduleById(firestoreRequest.scheduleId!)
              : null;
          Lessons? lesson;
          if (schedule == null && (firestoreRequest.lessonId != null && firestoreRequest.lessonId!.isNotEmpty)) {
            lesson = await LessonService.getLessonById(firestoreRequest.lessonId!);
          }
          final section = schedule != null
              ? await CourseSectionService.getCourseSectionById(schedule.courseSectionId)
              : null;
          String subjectName = '';
          String className = '';
          String roomName = '';
          try {
            if (section != null) {
              final subject = await SubjectService.getSubjectById(section.subjectId);
              subjectName = subject?.name ?? '';
              final classroom = await ClassroomService.getClassroomById(section.classroomId);
              className = classroom?.name ?? '';
              final room = await RoomService.getRoomById(section.roomId);
              roomName = room?.name ?? '';
            } else if (lesson != null) {
              subjectName = lesson.subject ?? '';
              className = lesson.className;
              roomName = lesson.room ?? '';
            }
          } catch (_) {}
          String sessionString;
          DateTime dateValue;
          if (schedule != null) {
            final startHour = schedule.startTime.hour;
            final endHour = schedule.endTime.hour;
            final startMin = schedule.startTime.minute;
            final endMin = schedule.endTime.minute;
            sessionString = '$startHour:${startMin.toString().padLeft(2, '0')}-$endHour:${endMin.toString().padLeft(2, '0')}';
            dateValue = schedule.startTime;
          } else if (lesson != null) {
            final sParts = lesson.startTime.split(':');
            final eParts = lesson.endTime.split(':');
            sessionString = '${sParts.first}:${(sParts.length>1?sParts[1].padLeft(2,'0'):'00')}-${eParts.first}:${(eParts.length>1?eParts[1].padLeft(2,'0'):'00')}';
            dateValue = lesson.date;
          } else {
            continue;
          }
          RequestStatus status;
          switch (firestoreRequest.status) {
            case LeaveRequestStatus.approved:
              status = RequestStatus.approved;
              break;
            case LeaveRequestStatus.rejected:
              status = RequestStatus.rejected;
              break;
            default:
              status = RequestStatus.pending;
          }
          allLeaveRequests.add(LeaveRequest(
            lecturer: teacherName,
            subject: subjectName,
            className: className,
            room: roomName,
            date: dateValue,
            session: sessionString,
            reason: firestoreRequest.reason,
            status: status,
            submittedAt: firestoreRequest.createdAt,
            approvedBy: firestoreRequest.approverId != null ? 'Trưởng Bộ môn' : null,
            rejectedBy: status == RequestStatus.rejected ? 'Trưởng Bộ môn' : null,
            rejectionReason: firestoreRequest.approverNotes,
            approvedDate: firestoreRequest.approvedDate,
          ));
        }
        _leaveRequests = allLeaveRequests;
        notifyListeners();
      });
      return;
    }

    for (final teacherId in _departmentTeacherIds) {
      _leaveRequestsSubscription = LeaveRequestService
          .getLeaveRequestsByTeacherStream(teacherId)
          .listen((firestoreRequests) async {
        for (final firestoreRequest in firestoreRequests) {
          // Get teacher info
          final teacher = await UserService.getUserById(firestoreRequest.teacherId);
          final teacherName = teacher?.fullName ?? '';
          
          // Get schedule info (có thể null nếu dùng lessonId)
          final schedule = (firestoreRequest.scheduleId != null && firestoreRequest.scheduleId!.isNotEmpty)
              ? await ScheduleService.getScheduleById(firestoreRequest.scheduleId!)
              : null;
          // Nếu không có schedule, thử lấy lesson
          Lessons? lesson;
          if (schedule == null && (firestoreRequest.lessonId != null && firestoreRequest.lessonId!.isNotEmpty)) {
            lesson = await LessonService.getLessonById(firestoreRequest.lessonId!);
            if (lesson == null) continue;
          } else if (schedule == null) {
            continue;
          }
          
          String subjectName = '';
          String className = '';
          String roomName = '';
          String sessionString;
          DateTime dateValue;
          
          try {
            if (schedule != null) {
              final section = await CourseSectionService.getCourseSectionById(schedule.courseSectionId);
              if (section == null) continue;
              
              final subject = await SubjectService.getSubjectById(section.subjectId);
              subjectName = subject?.name ?? '';
              
              final classroom = await ClassroomService.getClassroomById(section.classroomId);
              className = classroom?.name ?? '';
              
              final room = await RoomService.getRoomById(section.roomId);
              roomName = room?.name ?? '';
              
              final startHour = schedule.startTime.hour;
              final endHour = schedule.endTime.hour;
              final startMin = schedule.startTime.minute;
              final endMin = schedule.endTime.minute;
              sessionString = '$startHour:${startMin.toString().padLeft(2, '0')}-$endHour:${endMin.toString().padLeft(2, '0')}';
              dateValue = schedule.startTime;
            } else if (lesson != null) {
              subjectName = lesson.subject ?? '';
              className = lesson.className;
              roomName = lesson.room ?? '';
              
              final sParts = lesson.startTime.split(':');
              final eParts = lesson.endTime.split(':');
              sessionString = '${sParts.first}:${(sParts.length>1?sParts[1].padLeft(2,'0'):'00')}-${eParts.first}:${(eParts.length>1?eParts[1].padLeft(2,'0'):'00')}';
              dateValue = lesson.date;
            } else {
              continue;
            }
          } catch (e) {
            print('Error loading leave request details: $e');
            continue;
          }
          
          // Map status
          RequestStatus status;
          switch (firestoreRequest.status) {
            case LeaveRequestStatus.approved:
              status = RequestStatus.approved;
              break;
            case LeaveRequestStatus.rejected:
              status = RequestStatus.rejected;
              break;
            default:
              status = RequestStatus.pending;
          }
          
          allLeaveRequests.add(LeaveRequest(
            lecturer: teacherName,
            subject: subjectName,
            className: className,
            room: roomName,
            date: dateValue,
            session: sessionString,
            reason: firestoreRequest.reason,
            status: status,
            submittedAt: firestoreRequest.createdAt,
            approvedBy: firestoreRequest.approverId != null ? 'Trưởng Bộ môn' : null,
            rejectedBy: status == RequestStatus.rejected ? 'Trưởng Bộ môn' : null,
            rejectionReason: firestoreRequest.approverNotes,
            approvedDate: firestoreRequest.approvedDate,
          ));
        }
        
        _leaveRequests = allLeaveRequests;
        notifyListeners();
      });
    }
  }

  // Load makeup requests
  Future<void> _loadMakeupRequests() async {
    _makeupRequestsSubscription?.cancel();
    
    final allMakeups = <MakeupRegistration>[];

    if (loadAllDataForDebug) {
      _makeupRequestsSubscription = MakeupRequestService
          .getMakeupRequestsStream()
          .listen((firestoreMakeups) async {
        for (final firestoreMakeup in firestoreMakeups) {
          final teacher = await UserService.getUserById(firestoreMakeup.teacherId);
          final teacherName = teacher?.fullName ?? '';
          final leaveRequest = await LeaveRequestService.getLeaveRequestById(firestoreMakeup.leaveRequestId);
          if (leaveRequest == null) continue;
          
          // Xử lý originalSchedule có thể null, fallback sang lesson
          final originalSchedule = (leaveRequest.scheduleId != null && leaveRequest.scheduleId!.isNotEmpty)
              ? await ScheduleService.getScheduleById(leaveRequest.scheduleId!)
              : null;
          Lessons? originalLesson;
          if (originalSchedule == null && (leaveRequest.lessonId != null && leaveRequest.lessonId!.isNotEmpty)) {
            originalLesson = await LessonService.getLessonById(leaveRequest.lessonId!);
          }
          if (originalSchedule == null && originalLesson == null) continue;

          String subjectName = '';
          String className = '';
          String roomName = '';
          String originalSession;
          DateTime originalDate;

          try {
            if (originalSchedule != null) {
              final section = await CourseSectionService.getCourseSectionById(originalSchedule.courseSectionId);
              if (section == null) continue;

              final subject = await SubjectService.getSubjectById(section.subjectId);
              subjectName = subject?.name ?? '';
              final classroom = await ClassroomService.getClassroomById(section.classroomId);
              className = classroom?.name ?? '';

              final originalStartHour = originalSchedule.startTime.hour;
              final originalEndHour = originalSchedule.endTime.hour;
              final originalStartMin = originalSchedule.startTime.minute;
              final originalEndMin = originalSchedule.endTime.minute;
              originalSession = '$originalStartHour:${originalStartMin.toString().padLeft(2, '0')}-$originalEndHour:${originalEndMin.toString().padLeft(2, '0')}';
              originalDate = originalSchedule.startTime;
            } else if (originalLesson != null) {
              subjectName = originalLesson.subject ?? '';
              className = originalLesson.className;

              final sParts = originalLesson.startTime.split(':');
              final eParts = originalLesson.endTime.split(':');
              originalSession = '${sParts.first}:${(sParts.length>1?sParts[1].padLeft(2,'0'):'00')}-${eParts.first}:${(eParts.length>1?eParts[1].padLeft(2,'0'):'00')}';
              originalDate = originalLesson.date;
            } else {
              continue;
            }

            final room = await RoomService.getRoomById(firestoreMakeup.proposedRoomId);
            roomName = room?.name ?? '';
          } catch (e) {
            print('Error loading makeup request details: $e');
            continue;
          }

          final makeupStartHour = firestoreMakeup.proposedStartTime.hour;
          final makeupEndHour = firestoreMakeup.proposedEndTime.hour;
          final makeupStartMin = firestoreMakeup.proposedStartTime.minute;
          final makeupEndMin = firestoreMakeup.proposedEndTime.minute;
          final makeupSession = '$makeupStartHour:${makeupStartMin.toString().padLeft(2, '0')}-$makeupEndHour:${makeupEndMin.toString().padLeft(2, '0')}';
          RequestStatus status;
          switch (firestoreMakeup.status) {
            case MakeupRequestStatus.approved:
              status = RequestStatus.approved;
              break;
            case MakeupRequestStatus.rejected:
              status = RequestStatus.rejected;
              break;
            default:
              status = RequestStatus.pending;
          }
          allMakeups.add(MakeupRegistration(
            lecturer: teacherName,
            subject: subjectName,
            className: className,
            originalDate: originalDate,
            originalSession: originalSession,
            makeupDate: firestoreMakeup.proposedStartTime,
            makeupSession: makeupSession,
            makeupRoom: roomName,
            status: status,
            approvedBy: firestoreMakeup.approverId != null ? 'Trưởng Bộ môn' : null,
            rejectedBy: status == RequestStatus.rejected ? 'Trưởng Bộ môn' : null,
            rejectionReason: null,
            approvedDate: null,
            submittedAt: firestoreMakeup.createdAt,
          ));
        }
        _makeups = allMakeups;
        notifyListeners();
      });
      return;
    }

    for (final teacherId in _departmentTeacherIds) {
      _makeupRequestsSubscription = MakeupRequestService
          .getMakeupRequestsByTeacherStream(teacherId)
          .listen((firestoreMakeups) async {
        for (final firestoreMakeup in firestoreMakeups) {
          // Get teacher info
          final teacher = await UserService.getUserById(firestoreMakeup.teacherId);
          final teacherName = teacher?.fullName ?? '';

          // Get leave request to find original schedule
          final leaveRequest = await LeaveRequestService.getLeaveRequestById(firestoreMakeup.leaveRequestId);
          if (leaveRequest == null) continue;

          final originalSchedule = await ScheduleService.getScheduleById(leaveRequest.scheduleId ?? '');
          if (originalSchedule == null) continue;

          // Get course section details
          final section = await CourseSectionService.getCourseSectionById(originalSchedule.courseSectionId);
          if (section == null) continue;

          String subjectName = '';
          String className = '';
          String roomName = '';

          try {
            final subject = await SubjectService.getSubjectById(section.subjectId);
            subjectName = subject?.name ?? '';

            final classroom = await ClassroomService.getClassroomById(section.classroomId);
            className = classroom?.name ?? '';

            final room = await RoomService.getRoomById(firestoreMakeup.proposedRoomId);
            roomName = room?.name ?? '';
          } catch (e) {
            print('Error loading makeup request details: $e');
          }

          // Format sessions
          final originalStartHour = originalSchedule.startTime.hour;
          final originalEndHour = originalSchedule.endTime.hour;
          final originalStartMin = originalSchedule.startTime.minute;
          final originalEndMin = originalSchedule.endTime.minute;
          final originalSession = '$originalStartHour:${originalStartMin.toString().padLeft(2, '0')}-$originalEndHour:${originalEndMin.toString().padLeft(2, '0')}';

          final makeupStartHour = firestoreMakeup.proposedStartTime.hour;
          final makeupEndHour = firestoreMakeup.proposedEndTime.hour;
          final makeupStartMin = firestoreMakeup.proposedStartTime.minute;
          final makeupEndMin = firestoreMakeup.proposedEndTime.minute;
          final makeupSession = '$makeupStartHour:${makeupStartMin.toString().padLeft(2, '0')}-$makeupEndHour:${makeupEndMin.toString().padLeft(2, '0')}';

          // Map status
          RequestStatus status;
          switch (firestoreMakeup.status) {
            case MakeupRequestStatus.approved:
              status = RequestStatus.approved;
              break;
            case MakeupRequestStatus.rejected:
              status = RequestStatus.rejected;
              break;
            default:
              status = RequestStatus.pending;
          }

          allMakeups.add(MakeupRegistration(
            lecturer: teacherName,
            subject: subjectName,
            className: className,
            originalDate: originalSchedule.startTime,
            originalSession: originalSession,
            makeupDate: firestoreMakeup.proposedStartTime,
            makeupSession: makeupSession,
            makeupRoom: roomName,
            status: status,
            approvedBy: firestoreMakeup.approverId != null ? 'Trưởng Bộ môn' : null,
            rejectedBy: status == RequestStatus.rejected ? 'Trưởng Bộ môn' : null,
            rejectionReason: null, // Not stored in MakeupRequests model
            approvedDate: null, // Not stored in MakeupRequests model
            submittedAt: firestoreMakeup.createdAt,
          ));
        }

        _makeups = allMakeups;
        notifyListeners();
      });
    }
  }

  // Approval methods - Update Firebase
  Future<void> approveLeave(int index) async {
    if (index >= 0 && index < _leaveRequests.length) {
      // Find corresponding Firestore leave request
      final leaveRequest = _leaveRequests[index];

      // Find Firestore document (simplified - need to store document IDs)
      // For now, update local state and sync later
      _leaveRequests[index] = LeaveRequest(
        lecturer: leaveRequest.lecturer,
        subject: leaveRequest.subject,
        className: leaveRequest.className,
        room: leaveRequest.room,
        date: leaveRequest.date,
        session: leaveRequest.session,
        reason: leaveRequest.reason,
        status: RequestStatus.approved,
        submittedAt: leaveRequest.submittedAt,
        approvedBy: 'Trưởng Bộ môn',
        approvedDate: DateTime.now(),
      );
      notifyListeners();

      // TODO: Update Firestore document
      // Need to store document IDs with LeaveRequest model
    }
  }

  Future<void> rejectLeave(int index, String rejectionReason) async {
    if (index >= 0 && index < _leaveRequests.length) {
      final leaveRequest = _leaveRequests[index];

      _leaveRequests[index] = LeaveRequest(
        lecturer: leaveRequest.lecturer,
        subject: leaveRequest.subject,
        className: leaveRequest.className,
        room: leaveRequest.room,
        date: leaveRequest.date,
        session: leaveRequest.session,
        reason: leaveRequest.reason,
        status: RequestStatus.rejected,
        submittedAt: leaveRequest.submittedAt,
        rejectedBy: 'Trưởng Bộ môn',
        rejectionReason: rejectionReason,
      );
      notifyListeners();

      // TODO: Update Firestore document
    }
  }

  Future<void> approveMakeup(int index) async {
    if (index >= 0 && index < _makeups.length) {
      final makeup = _makeups[index];

      _makeups[index] = MakeupRegistration(
        lecturer: makeup.lecturer,
        subject: makeup.subject,
        className: makeup.className,
        originalDate: makeup.originalDate,
        originalSession: makeup.originalSession,
        makeupDate: makeup.makeupDate,
        makeupSession: makeup.makeupSession,
        makeupRoom: makeup.makeupRoom,
        status: RequestStatus.approved,
        approvedBy: 'Trưởng Bộ môn',
        approvedDate: DateTime.now(),
        submittedAt: makeup.submittedAt,
      );
      notifyListeners();

      // TODO: Update Firestore document
    }
  }

  Future<void> rejectMakeup(int index, String rejectionReason) async {
    if (index >= 0 && index < _makeups.length) {
      final makeup = _makeups[index];

      _makeups[index] = MakeupRegistration(
        lecturer: makeup.lecturer,
        subject: makeup.subject,
        className: makeup.className,
        originalDate: makeup.originalDate,
        originalSession: makeup.originalSession,
        makeupDate: makeup.makeupDate,
        makeupSession: makeup.makeupSession,
        makeupRoom: makeup.makeupRoom,
        status: RequestStatus.rejected,
        rejectedBy: 'Trưởng Bộ môn',
        rejectionReason: rejectionReason,
        submittedAt: makeup.submittedAt,
      );
      notifyListeners();

      // TODO: Update Firestore document
    }
  }

  void updateAlertState(int index, AlertState state) {
    if (index >= 0 && index < _alerts.length) {
      _alerts[index] = AlertItem(
        type: _alerts[index].type,
        detail: _alerts[index].detail,
        date: _alerts[index].date,
        priority: _alerts[index].priority,
        state: state,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _leaveRequestsSubscription?.cancel();
    _makeupRequestsSubscription?.cancel();
    _schedulesSubscription?.cancel();
    _subjectsSubscription?.cancel();
    _lessonsSubscription?.cancel();
    super.dispose();
  }

  // Combine schedule sources and notify
  void _rebuildSchedules() {
    _schedules = [..._schedulesFromSchedules, ..._schedulesFromLessons];
    notifyListeners();
  }
}





