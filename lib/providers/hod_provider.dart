import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hod_models.dart';
import '../models/users.dart';
import '../models/leave_requests.dart';
import '../models/makeup_requests.dart';
import '../models/schedules.dart';
import '../models/course_sections.dart';
import '../models/lessons.dart';
// [THÊM MỚI] Imports cho các models (Giả định bạn có các file này)
import '../models/subjects.dart';
import '../models/classrooms.dart';
import '../models/rooms.dart';

// [THÊM MỚI] Imports cho các services
import '../services/user_service.dart';
import '../services/lesson_service.dart';
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

  static const bool useSampleData = false;
  static const bool loadAllDataForDebug = true;

  // Data from Firebase or Sample
  List<Lecturer> _lecturers = [];
  List<LeaveRequest> _leaveRequests = [];
  List<MakeupRegistration> _makeups = [];
  List<ScheduleItem> _schedules = [];
  List<ScheduleItem> _schedulesFromSchedules = [];
  List<ScheduleItem> _schedulesFromLessons = [];
  List<AlertItem> _alerts = [];
  List<String> _subjectNames = [];

  // Stream subscriptions
  StreamSubscription<List<Users>>? _usersSubscription;
  StreamSubscription<List<LeaveRequests>>? _leaveRequestsSubscription;
  StreamSubscription<List<MakeupRequests>>? _makeupRequestsSubscription;
  StreamSubscription<List<Schedules>>? _schedulesSubscription;
  StreamSubscription? _subjectsSubscription;
  StreamSubscription<List<Lessons>>? _lessonsSubscription;

  // Cache Maps (Fix lỗi N+1 Query)
  Map<String, Users> _userCache = {};
  Map<String, CourseSections> _sectionCache = {};
  Map<String, Subjects> _subjectCache = {};
  Map<String, Classrooms> _classroomCache = {};
  Map<String, Rooms> _roomCache = {};
  Map<String, Lessons> _lessonCache = {};
  Map<String, Schedules> _scheduleCache = {};
  Map<String, LeaveRequests> _leaveRequestCache = {};

  // [THÊM MỚI] Cache cho dữ liệu "thô" để xây dựng lại danh sách
  List<Schedules> _rawSchedules = [];
  List<Lessons> _rawLessons = [];

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

  String? get selectedLecturerForSchedule => _selectedLecturerForSchedule;

  void clearLecturerForSchedule() {
    _selectedLecturerForSchedule = null;
    notifyListeners();
  }

  void setAttendanceStatsFilter(String className, String subject) {
    _selectedClassForAttendance = className;
    _selectedSubjectForAttendance = subject;
    _shouldShowAttendanceStats = true;
    notifyListeners();
  }

  String? get selectedClassForAttendance => _selectedClassForAttendance;
  String? get selectedSubjectForAttendance => _selectedSubjectForAttendance;
  bool get shouldShowAttendanceStats => _shouldShowAttendanceStats;

  void clearAttendanceStatsFilter() {
    _selectedClassForAttendance = null;
    _selectedSubjectForAttendance = null;
    _shouldShowAttendanceStats = false;
    notifyListeners();
  }

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
      print('⚠️ AppState: Falling back to sample data');
      await loadSampleData();
    }
  }

  Future<void> loadSampleData() async {
    print('🔍 AppState: Loading sample data...');
    _lecturers = SampleDataProvider.getSampleLecturers();
    _leaveRequests = SampleDataProvider.getSampleLeaveRequests();
    _makeups = SampleDataProvider.getSampleMakeupRequests();
    _schedules = SampleDataProvider.getSampleSchedules();
    _alerts = SampleDataProvider.getSampleAlerts();
    print('✅ AppState: Loaded sample data');
    notifyListeners();
  }

  Future<void> _loadCaches() async {
    print('🔍 AppState: Loading caches...');
    try {
      final results = await Future.wait([
        UserService.getUsersStream().first.timeout(const Duration(seconds: 15)),
        CourseSectionService.getCourseSectionsStream().first.timeout(const Duration(seconds: 15)),
        SubjectService.getSubjectsStream().first.timeout(const Duration(seconds: 15)),
        ClassroomService.getClassroomsStream().first.timeout(const Duration(seconds: 15)),
        RoomService.getRoomsStream().first.timeout(const Duration(seconds: 15)),
        LessonService.getLessonsStream().first.timeout(const Duration(seconds: 15)),
        ScheduleService.getSchedulesStream().first.timeout(const Duration(seconds: 15)),
        LeaveRequestService.getLeaveRequestsStream().first.timeout(const Duration(seconds: 15)),
      ]);

      final users = results[0] as List<Users>;
      final sections = results[1] as List<CourseSections>;
      final subjects = results[2] as List<Subjects>;
      final classrooms = results[3] as List<Classrooms>;
      final rooms = results[4] as List<Rooms>;
      final lessons = results[5] as List<Lessons>;
      final schedules = results[6] as List<Schedules>;
      final leaveRequests = results[7] as List<LeaveRequests>;

      // [SỬA LỖI] Xây dựng cache với HAI key (ID tài liệu VÀ employeeId)
      _userCache = {}; // Khởi tạo map rỗng
      for (var u in users) {
        // Key 1: Dùng ID tài liệu (ví dụ: "GNAZqb...")
        _userCache[u.id] = u;

        // Key 2: Dùng employeeId (ví dụ: "teacher_001" hoặc "EMP002")
        if (u.employeeId != null && u.employeeId!.isNotEmpty) {
          _userCache[u.employeeId!] = u;
        }
      }

      _sectionCache = {for (var s in sections) s.id: s};
      _subjectCache = {for (var s in subjects) s.id: s};
      _classroomCache = {for (var c in classrooms) c.id: c};
      _roomCache = {for (var r in rooms) r.id: r};
      _lessonCache = {for (var l in lessons) l.id: l};
      _scheduleCache = {for (var s in schedules) s.id: s};
      _leaveRequestCache = {for (var r in leaveRequests) r.id: r};

      print('✅ AppState: Caches loaded (Users: ${_userCache.length}, Sections: ${_sectionCache.length}, Subjects: ${_subjectCache.length})');
    } catch (e, stackTrace) {
      print('❌ AppState: CRITICAL Error loading caches: $e');
      print('❌ AppState: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> loadDataFromFirebase() async {
    if (_departmentId == null) {
      print('⚠️ AppState: departmentId is null, cannot load data');
      return;
    }

    print('🔍 AppState: Loading TEACHERS by role (ignore department)');

    _usersSubscription?.cancel();

    try {
      await _loadCaches();

      final users = _userCache.values.where((u) => u.role == 'teacher').toList();
      print('✅ AppState: Loaded ${users.length} teachers from cache');

      final teachers = users;
      print('✅ AppState: Found ${teachers.length} teachers');

      _departmentTeacherIds = teachers.map((t) => t.id).toList();

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

      _usersSubscription = UserService.getUsersByRoleStream('teacher')
          .listen((updatedUsers) async {
        try {
          // [SỬA LỖI] Cập nhật cache với cả 2 key
          for (var u in updatedUsers) {
            _userCache[u.id] = u;
            if (u.employeeId != null && u.employeeId!.isNotEmpty) {
              _userCache[u.employeeId!] = u;
            }
          }

          final updatedTeachers = updatedUsers;
          _departmentTeacherIds = updatedTeachers.map((t) => t.id).toList();
          _lecturers = await _convertUsersToLecturers(updatedTeachers);

          // [SỬA LỖI] Gọi hàm xử lý lại schedule khi user thay đổi
          _processCachedSchedules();

        } catch (e) {
          print('❌ AppState: Error in users stream listener: $e');
        }
      });

      _subjectsSubscription?.cancel();
      _subjectsSubscription = SubjectService.getSubjectsStream().listen((subjectModels) {
        _subjectCache.addAll({for (var s in subjectModels) s.id: s});
        _subjectNames = subjectModels.map((s) => s.name).where((e) => e.isNotEmpty).toSet().toList();

        // [SỬA LỖI] Gọi hàm xử lý lại schedule khi subject thay đổi
        _processCachedSchedules();
      });

      // [THÊM MỚI] Lắng nghe các stream tra cứu khác
      ClassroomService.getClassroomsStream().listen((models) {
        _classroomCache.addAll({for (var m in models) m.id: m});
        _processCachedSchedules();
      });
      RoomService.getRoomsStream().listen((models) {
        _roomCache.addAll({for (var m in models) m.id: m});
        _processCachedSchedules();
      });

    } catch (e) {
      print('❌ AppState: Error in loadDataFromFirebase: $e');
      rethrow;
    }
  }

  Future<List<Lecturer>> _convertUsersToLecturers(List<Users> users) async {
    final lecturers = <Lecturer>[];

    final allCourseSections = _sectionCache.values.toList();
    final allSchedules = _scheduleCache.values.toList();

    for (final user in users) {
      int hoursPlanned = 0;
      int hoursActual = 0;

      try {
        final courseSections = allCourseSections.where((s) => s.teacherId == user.id || s.teacherId == user.employeeId).toList();

        for (final section in courseSections) {
          final schedules = allSchedules.where((s) => s.courseSectionId == section.id).toList();

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

  // [THÊM MỚI] Hàm này chỉ xử lý, không lắng nghe stream
  void _processCachedSchedules() {
    print('🔄 AppState: Processing cached schedules...');
    // --- Xử lý collection 'schedules' (từ _rawSchedules) ---
    final nextSchedules = <ScheduleItem>[];
    for (final schedule in _rawSchedules) {
      final sectionDetails = _sectionCache[schedule.courseSectionId];

      String subjectName = '';
      String className = '';
      String roomName = '';
      String teacherName = '';

      if (sectionDetails != null) {
        // Tra cứu bằng ID tài liệu HOẶC employeeId
        teacherName = _userCache[sectionDetails.teacherId]?.fullName ?? 'Không rõ';
        subjectName = _subjectCache[sectionDetails.subjectId]?.name ?? 'Không rõ';
        className = _classroomCache[sectionDetails.classroomId]?.name ?? 'Không rõ';
        roomName = _roomCache[sectionDetails.roomId]?.name ?? 'Không rõ';
      } else {
        print('⚠️ AppState: Cannot find sectionDetails in cache for sectionId ${schedule.courseSectionId}');
      }

      SessionStatus status;
      switch (schedule.status) {
        case ScheduleStatus.completed: status = SessionStatus.daDay; break;
        case ScheduleStatus.cancelled: status = SessionStatus.nghi; break;
        default: status = SessionStatus.chuaDay;
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
    _schedulesFromSchedules = nextSchedules;

    // --- Xử lý collection 'lessons' (từ _rawLessons) ---
    final lessonItems = <ScheduleItem>[];
    for (final l in _rawLessons) {
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

      SessionStatus status;
      switch (l.status) {
        case 'completed': status = SessionStatus.daDay; break;
        case 'ongoing': status = SessionStatus.chuaDay; break;
        default: status = SessionStatus.chuaDay;
      }

      final session = '${start.hour}:${start.minute.toString().padLeft(2, '0')}-${end.hour}:${end.minute.toString().padLeft(2, '0')}';

      // Tra cứu bằng ID tài liệu HOẶC employeeId
      String teacherName = _userCache[l.teacherId]?.fullName ?? 'Không rõ';

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
    _schedulesFromLessons = lessonItems;

    _rebuildSchedules(); // <-- Hàm này sẽ gọi notifyListeners()
  }


  // [SỬA ĐỔI] Hàm này giờ chỉ lắng nghe, lưu cache thô, và gọi hàm xử lý
  Future<void> _loadSchedules() async {
    _schedulesSubscription?.cancel();
    _lessonsSubscription?.cancel();

    if (loadAllDataForDebug) {
      try {
        _schedulesSubscription = ScheduleService.getSchedulesStream().listen((firestoreSchedules) {
          print('🔄 AppState: Received ${firestoreSchedules.length} schedules update');
          _rawSchedules = firestoreSchedules; // Cập nhật cache thô
          _scheduleCache.addAll({for (var s in firestoreSchedules) s.id: s});
          _processCachedSchedules(); // Xây dựng lại danh sách
        });

        _lessonsSubscription = LessonService.getLessonsStream().listen((lessons) {
          print('🔄 AppState: Received ${lessons.length} lessons update');
          _rawLessons = lessons; // Cập nhật cache thô
          _lessonCache.addAll({for (var l in lessons) l.id: l});
          _processCachedSchedules(); // Xây dựng lại danh sách
        });
      } catch (e) {
        print('Error loading all schedules (debug): $e');
      }
      return;
    }

    print('⚠️ AppState: Logic "non-debug" cho _loadSchedules() đã bị vô hiệu hóa.');
  }

  // [SỬA ĐỔI] Sửa lại hàm này để dùng _processCachedSchedules
  Future<void> _loadLeaveRequests() async {
    _leaveRequestsSubscription?.cancel();

    if (loadAllDataForDebug) {
      _leaveRequestsSubscription = LeaveRequestService
          .getLeaveRequestsStream()
          .listen((firestoreRequests) {
        print('🔄 AppState: Received ${firestoreRequests.length} leave requests');
        _leaveRequestCache.addAll({for (var r in firestoreRequests) r.id: r});

        final allLeaveRequests = <LeaveRequest>[];
        for (final firestoreRequest in firestoreRequests) {

          final teacher = _userCache[firestoreRequest.teacherId];
          final teacherName = teacher?.fullName ?? '';

          final schedule = (firestoreRequest.scheduleId != null && firestoreRequest.scheduleId!.isNotEmpty)
              ? _scheduleCache[firestoreRequest.scheduleId!]
              : null;

          Lessons? lesson;
          if (schedule == null && (firestoreRequest.lessonId != null && firestoreRequest.lessonId!.isNotEmpty)) {
            lesson = _lessonCache[firestoreRequest.lessonId!];
          }

          final section = schedule != null
              ? _sectionCache[schedule.courseSectionId]
              : null;

          String subjectName = '';
          String className = '';
          String roomName = '';

          if (section != null) {
            subjectName = _subjectCache[section.subjectId]?.name ?? '';
            className = _classroomCache[section.classroomId]?.name ?? '';
            roomName = _roomCache[section.roomId]?.name ?? '';
          } else if (lesson != null) {
            subjectName = lesson.subject ?? '';
            className = lesson.className;
            roomName = lesson.room ?? '';
          }

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
            case LeaveRequestStatus.approved: status = RequestStatus.approved; break;
            case LeaveRequestStatus.rejected: status = RequestStatus.rejected; break;
            default: status = RequestStatus.pending;
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
        // [SỬA LỖI] Phải gọi notifyListeners() ở đây vì hàm này không gọi _rebuildSchedules
        notifyListeners();
      });
      return;
    }

    print('⚠️ AppState: Logic "non-debug" cho _loadLeaveRequests() đã bị vô hiệu hóa.');
  }

  // [SỬA ĐỔI] Sửa lại hàm này để dùng _processCachedSchedules
  Future<void> _loadMakeupRequests() async {
    _makeupRequestsSubscription?.cancel();

    if (loadAllDataForDebug) {
      _makeupRequestsSubscription = MakeupRequestService
          .getMakeupRequestsStream()
          .listen((firestoreMakeups) async {
        print('🔄 AppState: Received ${firestoreMakeups.length} makeup requests');

        final allMakeups = <MakeupRegistration>[];
        for (final firestoreMakeup in firestoreMakeups) {

          final teacher = _userCache[firestoreMakeup.teacherId];
          final teacherName = teacher?.fullName ?? '';

          final leaveRequest = _leaveRequestCache[firestoreMakeup.leaveRequestId];
          if (leaveRequest == null) continue;

          final originalSchedule = (leaveRequest.scheduleId != null && leaveRequest.scheduleId!.isNotEmpty)
              ? _scheduleCache[leaveRequest.scheduleId!]
              : null;

          Lessons? originalLesson;
          if (originalSchedule == null && (leaveRequest.lessonId != null && leaveRequest.lessonId!.isNotEmpty)) {
            originalLesson = _lessonCache[leaveRequest.lessonId!];
          }
          if (originalSchedule == null && originalLesson == null) continue;

          String subjectName = '';
          String className = '';
          String roomName = '';
          String originalSession;
          DateTime originalDate;

          if (originalSchedule != null) {
            final section = _sectionCache[originalSchedule.courseSectionId];
            if (section == null) continue;

            subjectName = _subjectCache[section.subjectId]?.name ?? '';
            className = _classroomCache[section.classroomId]?.name ?? '';

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

          roomName = _roomCache[firestoreMakeup.proposedRoomId]?.name ?? '';

          final makeupStartHour = firestoreMakeup.proposedStartTime.hour;
          final makeupEndHour = firestoreMakeup.proposedEndTime.hour;
          final makeupStartMin = firestoreMakeup.proposedStartTime.minute;
          final makeupEndMin = firestoreMakeup.proposedEndTime.minute;
          final makeupSession = '$makeupStartHour:${makeupStartMin.toString().padLeft(2, '0')}-$makeupEndHour:${makeupEndMin.toString().padLeft(2, '0')}';
          RequestStatus status;
          switch (firestoreMakeup.status) {
            case MakeupRequestStatus.approved: status = RequestStatus.approved; break;
            case MakeupRequestStatus.rejected: status = RequestStatus.rejected; break;
            default: status = RequestStatus.pending;
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
        // [SỬA LỖI] Phải gọi notifyListeners() ở đây
        notifyListeners();
      });
      return;
    }

    print('⚠️ AppState: Logic "non-debug" cho _loadMakeupRequests() đã bị vô hiệu hóa.');
  }

  // --- Các hàm phê duyệt (Giữ nguyên) ---

  Future<void> approveLeave(int index) async {
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
        status: RequestStatus.approved,
        submittedAt: leaveRequest.submittedAt,
        approvedBy: 'Trưởng Bộ môn',
        approvedDate: DateTime.now(),
      );
      notifyListeners();
      // TODO: Update Firestore document
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
    print('🔄 AppState: Rebuilt schedules. Total: ${_schedules.length} (From Schedules: ${_schedulesFromSchedules.length}, From Lessons: ${_schedulesFromLessons.length})');
    notifyListeners();
  }
}