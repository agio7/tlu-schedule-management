// [DÁN TOÀN BỘ CODE NÀY VÀO: providers/hod_provider.dart]

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/hod_models.dart';
import '../models/users.dart';
import '../models/leave_requests.dart';
import '../models/makeup_requests.dart';
import '../models/schedules.dart';
import '../models/course_sections.dart';
import '../models/lessons.dart';
import '../models/subjects.dart';
import '../models/classrooms.dart';
import '../models/rooms.dart';

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
  String? _selectedLecturerForSchedule;
  String? _selectedClassForAttendance;
  String? _selectedSubjectForAttendance;
  bool _shouldShowAttendanceStats = false;

  static const bool useSampleData = false;
  static const bool loadAllDataForDebug = true;

  // Data
  List<Lecturer> _lecturers = [];
  List<LeaveRequest> _leaveRequests = [];
  List<MakeupRegistration> _makeups = [];
  List<ScheduleItem> _schedules = [];
  List<AlertItem> _alerts = [];
  List<String> _subjectNames = [];

  // Cache Maps
  Map<String, Users> _userCache = {};
  Map<String, CourseSections> _sectionCache = {};
  Map<String, Subjects> _subjectCache = {};
  Map<String, Classrooms> _classroomCache = {};
  Map<String, Rooms> _roomCache = {};
  Map<String, Lessons> _lessonCache = {};
  Map<String, Schedules> _scheduleCache = {};
  Map<String, LeaveRequests> _leaveRequestCache = {};
  Map<String, MakeupRequests> _makeupRequestsCache = {};

  // Cache cho dữ liệu "thô"
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

  // --- Các hàm setTab và filter (Giữ nguyên) ---
  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }
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
  // --- Kết thúc các hàm setTab và filter ---

  // [HÀM MỚI] Dùng để dịch ID người duyệt
  String _getApproverName(String? approverId) {
    if (approverId == 'admin') {
      return 'Admin (Phòng ĐT)';
    }
    // Giả sử bất kỳ ID nào khác là Trưởng Bộ môn
    return 'Trưởng Bộ môn';
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
    _rebuildSchedules(); // Tính toán thống kê cho sample data
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
        MakeupRequestService.getMakeupRequestsStream().first.timeout(const Duration(seconds: 15)),
      ]);

      final users = results[0] as List<Users>;
      final sections = results[1] as List<CourseSections>;
      final subjects = results[2] as List<Subjects>;
      final classrooms = results[3] as List<Classrooms>;
      final rooms = results[4] as List<Rooms>;
      final lessons = results[5] as List<Lessons>;
      final schedules = results[6] as List<Schedules>;
      final leaveRequests = results[7] as List<LeaveRequests>;
      final makeupRequests = results[8] as List<MakeupRequests>;

      _userCache = {};
      for (var u in users) {
        _userCache[u.id] = u;
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
      _makeupRequestsCache = {for (var r in makeupRequests) r.id: r};

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

    try {
      await _loadCaches();

      final uniqueUsers = _userCache.values.toSet();
      final users = uniqueUsers.where((u) => u.role == 'teacher').toList();
      print('✅ AppState: Loaded ${users.length} teachers from cache');
      final teachers = users;
      print('✅ AppState: Found ${teachers.length} teachers');
      _departmentTeacherIds = teachers.map((t) => t.id).toList();
      _lecturers = await _convertUsersToLecturers(teachers);
      print('✅ AppState: Converted ${_lecturers.length} lecturers');

      _rawSchedules = _scheduleCache.values.toList();
      _rawLessons = _lessonCache.values.toList();
      _processCachedSchedules();

      await _loadLeaveRequests();
      await _loadMakeupRequests();

      _subjectNames = _subjectCache.values.map((s) => s.name).where((e) => e.isNotEmpty).toSet().toList();

      notifyListeners();

    } catch (e) {
      print('❌ AppState: Error in loadDataFromFirebase: $e');
      rethrow;
    }
  }

  // [DÁN ĐÈ HÀM NÀY: providers/hod_provider.dart]
  Future<List<Lecturer>> _convertUsersToLecturers(List<Users> users) async {
    final lecturers = <Lecturer>[];
    final allLessons = _lessonCache.values.toList();
    final allCourseSections = _sectionCache.values.toList();

    for (final user in users) {
      int hoursActual = 0;
      int hoursPlanned = 0;

      // [SỬA LỖI] Lấy đúng 2 key
      final docIdKey = user.id; // ID tài liệu (GNAZ...)
      final employeeIdKey = user.employeeId; // ID tùy chỉnh ("teacher_001")

      String subjectName = user.specialization ?? '';

      // 1. Tính giờ THỰC TẾ
      try {
        final lessonsTaught = allLessons.where((l) =>
        // So sánh với CẢ HAI key
        (l.teacherId == docIdKey || l.teacherId == employeeIdKey) &&
            l.status == 'completed'
        ).toList();

        for (final lesson in lessonsTaught) {
          try {
            final sParts = lesson.startTime.split(':');
            final eParts = lesson.endTime.split(':');
            if (sParts.length >= 2 && eParts.length >= 2) {
              final start = DateTime(2000, 1, 1, int.parse(sParts[0]), int.parse(sParts[1]));
              final end = DateTime(2000, 1, 1, int.parse(eParts[0]), int.parse(eParts[1]));
              final duration = end.difference(start);
              if (duration.inMinutes > 0) {
                hoursActual += (duration.inMinutes / 60).round();
              }
            }
          } catch (e) { /* ignore parse error */ }
        }
      } catch (e) {
        print('Error calculating ACTUAL hours for ${user.fullName}: $e');
      }

      // 2. Tính giờ KẾ HOẠCH VÀ Tên môn học
      try {
        // [SỬA LỖI] So sánh teacherId của CourseSection với CẢ HAI key
        final sectionsTaught = allCourseSections.where((s) =>
        s.teacherId == docIdKey || s.teacherId == employeeIdKey
        ).toList();

        final subjectNamesSet = <String>{};

        for (final section in sectionsTaught) {
          final scheduleString = section.scheduleString;

          final timeMatch = RegExp(r'(\d{1,2}:\d{2})-(\d{1,2}:\d{2})').firstMatch(scheduleString);

          if (timeMatch != null) {
            final startTime = timeMatch.group(1)!;
            final endTime = timeMatch.group(2)!;

            final sParts = startTime.split(':');
            final eParts = endTime.split(':');

            if (sParts.length == 2 && eParts.length == 2) {
              final start = DateTime(2000, 1, 1, int.parse(sParts[0]), int.parse(sParts[1]));
              final end = DateTime(2000, 1, 1, int.parse(eParts[0]), int.parse(eParts[1]));
              final duration = end.difference(start);

              if (duration.inMinutes > 0) {
                final sessionHours = (duration.inMinutes / 60).round();
                hoursPlanned += sessionHours * 8; // Ghi đè 8 tuần
              }
            } else {
              print('⚠️ AppState: RegExp failed to parse time from: $scheduleString');
            }
          }

          final name = _subjectCache[section.subjectId]?.name;
          if (name != null && name.isNotEmpty) {
            subjectNamesSet.add(name);
          }
        }

        if (subjectNamesSet.isNotEmpty) {
          subjectName = subjectNamesSet.join(', ');
        }

      } catch (e) {
        print('Error calculating PLANNED hours for ${user.fullName}: $e');
      }

      lecturers.add(Lecturer(
        name: user.fullName,
        email: user.email,
        phone: user.phoneNumber ?? '',
        title: user.academicRank ?? 'Giảng viên',
        subject: subjectName,
        hoursPlanned: hoursPlanned,
        hoursActual: hoursActual,
      ));
    }
    return lecturers;
  }

  void _processCachedSchedules() {
    print('🔄 AppState: Processing cached schedules...');
    List<ScheduleItem> nextSchedules = [];

    // --- Xử lý collection 'schedules' ---
    for (final schedule in _rawSchedules) {
      final sectionDetails = _sectionCache[schedule.courseSectionId];
      String subjectName = 'Không rõ', className = 'Không rõ', roomName = 'Không rõ', teacherName = 'Không rõ';
      String? classroomId;
      int studentCount = 0;
      int totalSessions = 8; // Ghi đè 8

      if (sectionDetails != null) {
        teacherName = _userCache[sectionDetails.teacherId]?.fullName ?? 'Không rõ';
        subjectName = _subjectCache[sectionDetails.subjectId]?.name ?? 'Không rõ';

        classroomId = sectionDetails.classroomId;
        final classroom = _classroomCache[classroomId];
        className = classroom?.name ?? 'Không rõ';
        studentCount = classroom?.studentCount ?? 0;

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
      final session = '${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')}-${schedule.endTime.hour}:${schedule.endTime.minute.toString().padLeft(2, '0')}';

      nextSchedules.add(ScheduleItem(
        lecturer: teacherName,
        subject: subjectName,
        className: className,
        classroomId: classroomId,
        date: schedule.startTime,
        session: session,
        room: roomName,
        status: status,
        attendanceList: null,
        studentCount: studentCount,
        totalSessions: totalSessions,
      ));
    }

    List<ScheduleItem> lessonItems = [];
    // --- Xử lý collection 'lessons' ---
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
      String teacherName = _userCache[l.teacherId]?.fullName ?? 'Không rõ';

      final classroom = _classroomCache[l.classroomId];
      int studentCount = classroom?.studentCount ?? 0;
      int totalSessions = 8; // Ghi đè 8

      lessonItems.add(ScheduleItem(
        lecturer: teacherName,
        subject: l.subject ?? '',
        className: l.className,
        classroomId: l.classroomId,
        date: start,
        session: session,
        room: l.room ?? '',
        status: status,
        attendanceList: l.attendanceList,
        studentCount: studentCount,
        totalSessions: totalSessions,
      ));
    }

    _schedules = [...nextSchedules, ...lessonItems];
    _rebuildSchedules();
  }

  Future<void> _loadLeaveRequests() async {
    final allLeaveRequests = <LeaveRequest>[];
    for (final firestoreRequest in _leaveRequestCache.values) {
      final teacher = _userCache[firestoreRequest.teacherId];
      final teacherName = teacher?.fullName ?? 'Không rõ';

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
        sessionString = '${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')}-${schedule.endTime.hour}:${schedule.endTime.minute.toString().padLeft(2, '0')}';
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
        id: firestoreRequest.id,
        lecturer: teacherName,
        subject: subjectName,
        className: className,
        room: roomName,
        date: dateValue,
        session: sessionString,
        reason: firestoreRequest.reason,
        status: status,
        submittedAt: firestoreRequest.createdAt,
        // [SỬA LỖI] Dùng hàm helper mới
        approvedBy: firestoreRequest.approverId != null ? _getApproverName(firestoreRequest.approverId) : null,
        rejectedBy: status == RequestStatus.rejected ? _getApproverName(firestoreRequest.approverId) : null,
        rejectionReason: firestoreRequest.approverNotes,
        approvedDate: firestoreRequest.approvedDate,
      ));
    }
    _leaveRequests = allLeaveRequests;
  }

  Future<void> _loadMakeupRequests() async {
    final allMakeups = <MakeupRegistration>[];

    for (final firestoreMakeup in _makeupRequestsCache.values) {
      final teacher = _userCache[firestoreMakeup.teacherId];
      final teacherName = teacher?.fullName ?? 'Không rõ';

      // --- [1] Lấy lịch gốc theo originalScheduleId (nếu có)
      final originalSchedule = (firestoreMakeup.originalScheduleId != null &&
          firestoreMakeup.originalScheduleId!.isNotEmpty)
          ? _scheduleCache[firestoreMakeup.originalScheduleId!]
          : null;

      // --- [2] Bổ sung: lấy bài giảng gốc từ lessonId (nếu không có schedule)
      Lessons? originalLesson;
      if (originalSchedule == null &&
          firestoreMakeup.lessonId != null &&
          firestoreMakeup.lessonId!.isNotEmpty) {
        originalLesson = _lessonCache[firestoreMakeup.lessonId!];
      }

      // Nếu cả hai đều không có thì bỏ qua
      if (originalSchedule == null && originalLesson == null) {
        print(
            '⚠️ MakeupRequest bị bỏ qua vì không có originalScheduleId hoặc lessonId hợp lệ: ${firestoreMakeup.id}');
        continue;
      }

      String subjectName = '';
      String className = '';
      String roomName = '';
      String originalSession;
      DateTime originalDate;

      // --- [3] Nếu có originalSchedule
      if (originalSchedule != null) {
        final section = _sectionCache[originalSchedule.courseSectionId];
        if (section == null) continue;

        subjectName = _subjectCache[section.subjectId]?.name ?? '';
        className = _classroomCache[section.classroomId]?.name ?? '';
        originalSession =
        '${originalSchedule.startTime.hour}:${originalSchedule.startTime.minute.toString().padLeft(2, '0')}-${originalSchedule.endTime.hour}:${originalSchedule.endTime.minute.toString().padLeft(2, '0')}';
        originalDate = originalSchedule.startTime;
      }
      // --- [4] Nếu không có schedule nhưng có lesson
      else {
        subjectName = originalLesson?.subject ?? '';
        className = originalLesson?.className ?? '';
        final sParts = originalLesson?.startTime.split(':') ?? [''];
        final eParts = originalLesson?.endTime.split(':') ?? [''];
        originalSession =
        '${sParts.first}:${(sParts.length > 1 ? sParts[1].padLeft(2, '0') : '00')}-${eParts.first}:${(eParts.length > 1 ? eParts[1].padLeft(2, '0') : '00')}';
        originalDate = originalLesson?.date ?? firestoreMakeup.createdAt;
      }

      // --- [5] Các thông tin còn lại
      roomName = _roomCache[firestoreMakeup.proposedRoomId]?.name ?? '';

      final makeupSession =
          '${firestoreMakeup.proposedStartTime.hour}:${firestoreMakeup.proposedStartTime.minute.toString().padLeft(2, '0')}-${firestoreMakeup.proposedEndTime.hour}:${firestoreMakeup.proposedEndTime.minute.toString().padLeft(2, '0')}';

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

      // --- [6] Thêm vào danh sách
      allMakeups.add(MakeupRegistration(
        id: firestoreMakeup.id,
        lecturer: teacherName,
        subject: subjectName,
        className: className,
        originalDate: originalDate,
        originalSession: originalSession,
        makeupDate: firestoreMakeup.proposedStartTime,
        makeupSession: makeupSession,
        makeupRoom: roomName,
        status: status,
        approvedBy: firestoreMakeup.approverId != null
            ? _getApproverName(firestoreMakeup.approverId)
            : null,
        rejectedBy: status == RequestStatus.rejected
            ? _getApproverName(firestoreMakeup.approverId)
            : null,
        rejectionReason: firestoreMakeup.approverNotes,
        approvedDate: firestoreMakeup.updatedAt,
        submittedAt: firestoreMakeup.createdAt,
      ));
    }

    _makeups = allMakeups;
  }


  // --- Các hàm phê duyệt (Đã sửa) ---

  static const String HOD_APPROVER_ID = 'department_head';

  Future<void> approveLeave(int index) async {
    if (index < 0 || index >= _leaveRequests.length) return;
    final request = _leaveRequests[index];
    print('Approving leave request: ${request.id}');

    final dataToUpdate = {
      'status': 'approved',
      'approverId': HOD_APPROVER_ID,
      'approverNotes': 'Đã duyệt bởi Trưởng Bộ môn',
      'approvedDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await LeaveRequestService.updateLeaveRequest(request.id, dataToUpdate);
      print('✅ Successfully approved leave ${request.id}');
      await loadDataFromFirebase(); // Tải lại
    } catch (e) {
      print('❌ Error approving leave request: $e');
    }
  }

  Future<void> rejectLeave(int index, String rejectionReason) async {
    if (index < 0 || index >= _leaveRequests.length) return;
    final request = _leaveRequests[index];
    print('Rejecting leave request: ${request.id}');

    final dataToUpdate = {
      'status': 'rejected',
      'approverId': HOD_APPROVER_ID,
      'approverNotes': rejectionReason,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await LeaveRequestService.updateLeaveRequest(request.id, dataToUpdate);
      print('✅ Successfully rejected leave ${request.id}');
      await loadDataFromFirebase(); // Tải lại
    } catch (e) {
      print('❌ Error rejecting leave request: $e');
    }
  }

  Future<void> approveMakeup(int index) async {
    if (index < 0 || index >= _makeups.length) return;
    final request = _makeups[index];
    print('Approving makeup request: ${request.id}');

    final dataToUpdate = {
      'status': 'approved',
      'approverId': HOD_APPROVER_ID,
      'approverNotes': 'Đã duyệt',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await MakeupRequestService.updateMakeupRequest(request.id, dataToUpdate);
      print('✅ Successfully approved makeup ${request.id}');
      await loadDataFromFirebase(); // Tải lại
    } catch (e) {
      print('❌ Error approving makeup request: $e');
    }
  }

  Future<void> rejectMakeup(int index, String rejectionReason) async {
    if (index < 0 || index >= _makeups.length) return;
    final request = _makeups[index];
    print('Rejecting makeup request: ${request.id}');

    final dataToUpdate = {
      'status': 'rejected',
      'approverId': HOD_APPROVER_ID,
      'approverNotes': rejectionReason,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await MakeupRequestService.updateMakeupRequest(request.id, dataToUpdate);
      print('✅ Successfully rejected makeup ${request.id}');
      await loadDataFromFirebase(); // Tải lại
    } catch (e) {
      print('❌ Error rejecting makeup request: $e');
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
  // --- [KẾT THÚC] Các hàm phê duyệt ---

  @override
  void dispose() {
    super.dispose();
  }

  void _rebuildSchedules() {
    print('🔄 AppState: Rebuilt schedules list. Total: ${_schedules.length}');
    // Không cần tính toán thống kê ở đây
    _lecturers = List.from(_lecturers);
    notifyListeners();
  }
}