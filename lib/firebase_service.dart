import 'package:firebase_database/firebase_database.dart';
import 'app_state.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Khởi tạo Firebase
  Future<void> initialize() async {
    // Firebase đã được khởi tạo trong main.dart
  }

  // --- CRUD Operations cho Giảng viên ---
  Future<void> addLecturer(Lecturer lecturer) async {
    await _database.child('lecturers').push().set({
      'name': lecturer.name,
      'title': lecturer.title,
      'email': lecturer.email,
      'phone': lecturer.phone,
      'subject': lecturer.subject,
      'hoursPlanned': lecturer.hoursPlanned,
      'hoursActual': lecturer.hoursActual,
    });
  }

  Future<List<Lecturer>> getLecturers() async {
    final snapshot = await _database.child('lecturers').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final lecturerData = entry.value as Map<dynamic, dynamic>;
        return Lecturer(
          name: lecturerData['name'] ?? '',
          title: lecturerData['title'] ?? '',
          email: lecturerData['email'] ?? '',
          phone: lecturerData['phone'] ?? '',
          subject: lecturerData['subject'] ?? '',
          hoursPlanned: lecturerData['hoursPlanned'] ?? 0,
          hoursActual: lecturerData['hoursActual'] ?? 0,
        );
      }).toList();
    }
    return [];
  }

  // --- CRUD Operations cho Lịch dạy ---
  Future<void> addSchedule(ScheduleItem schedule) async {
    await _database.child('schedules').push().set({
      'lecturer': schedule.lecturer,
      'subject': schedule.subject,
      'className': schedule.className,
      'date': schedule.date.millisecondsSinceEpoch,
      'session': schedule.session,
      'room': schedule.room,
      'status': schedule.status.index,
      'attendance': schedule.attendance,
    });
  }

  Future<List<ScheduleItem>> getSchedules() async {
    final snapshot = await _database.child('schedules').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final scheduleData = entry.value as Map<dynamic, dynamic>;
        return ScheduleItem(
          lecturer: scheduleData['lecturer'] ?? '',
          subject: scheduleData['subject'] ?? '',
          className: scheduleData['className'] ?? '',
          date: DateTime.fromMillisecondsSinceEpoch(scheduleData['date'] ?? 0),
          session: scheduleData['session'] ?? '',
          room: scheduleData['room'] ?? '',
          status: SessionStatus.values[scheduleData['status'] ?? 0],
          attendance: scheduleData['attendance'],
        );
      }).toList();
    }
    return [];
  }

  // --- CRUD Operations cho Yêu cầu nghỉ ---
  Future<void> addLeaveRequest(LeaveRequest request) async {
    await _database.child('leaveRequests').push().set({
      'lecturer': request.lecturer,
      'subject': request.subject,
      'className': request.className,
      'date': request.date.millisecondsSinceEpoch,
      'session': request.session,
      'room': request.room,
      'submittedAt': request.submittedAt.millisecondsSinceEpoch,
      'reason': request.reason,
      'documentUrl': request.documentUrl,
      'status': request.status.index,
    });
  }

  Future<List<LeaveRequest>> getLeaveRequests() async {
    final snapshot = await _database.child('leaveRequests').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final requestData = entry.value as Map<dynamic, dynamic>;
        return LeaveRequest(
          lecturer: requestData['lecturer'] ?? '',
          subject: requestData['subject'] ?? '',
          className: requestData['className'] ?? '',
          date: DateTime.fromMillisecondsSinceEpoch(requestData['date'] ?? 0),
          session: requestData['session'] ?? '',
          room: requestData['room'] ?? '',
          submittedAt: DateTime.fromMillisecondsSinceEpoch(requestData['submittedAt'] ?? 0),
          reason: requestData['reason'] ?? '',
          documentUrl: requestData['documentUrl'],
          status: RequestStatus.values[requestData['status'] ?? 0],
        );
      }).toList();
    }
    return [];
  }

  Future<void> updateLeaveRequestStatus(String key, RequestStatus status) async {
    await _database.child('leaveRequests').child(key).update({
      'status': status.index,
    });
  }

  // --- CRUD Operations cho Đăng ký dạy bù ---
  Future<void> addMakeupRegistration(MakeupRegistration makeup) async {
    await _database.child('makeups').push().set({
      'lecturer': makeup.lecturer,
      'originalDate': makeup.originalDate.millisecondsSinceEpoch,
      'originalSession': makeup.originalSession,
      'makeupDate': makeup.makeupDate.millisecondsSinceEpoch,
      'makeupSession': makeup.makeupSession,
      'makeupRoom': makeup.makeupRoom,
      'studentConfirmedPercent': makeup.studentConfirmedPercent,
      'status': makeup.status.index,
    });
  }

  Future<List<MakeupRegistration>> getMakeups() async {
    final snapshot = await _database.child('makeups').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final makeupData = entry.value as Map<dynamic, dynamic>;
        return MakeupRegistration(
          lecturer: makeupData['lecturer'] ?? '',
          originalDate: DateTime.fromMillisecondsSinceEpoch(makeupData['originalDate'] ?? 0),
          originalSession: makeupData['originalSession'] ?? '',
          makeupDate: DateTime.fromMillisecondsSinceEpoch(makeupData['makeupDate'] ?? 0),
          makeupSession: makeupData['makeupSession'] ?? '',
          makeupRoom: makeupData['makeupRoom'] ?? '',
          studentConfirmedPercent: makeupData['studentConfirmedPercent'],
          status: RequestStatus.values[makeupData['status'] ?? 0],
        );
      }).toList();
    }
    return [];
  }

  Future<void> updateMakeupStatus(String key, RequestStatus status) async {
    await _database.child('makeups').child(key).update({
      'status': status.index,
    });
  }

  // --- CRUD Operations cho Cảnh báo ---
  Future<void> addAlert(AlertItem alert) async {
    await _database.child('alerts').push().set({
      'type': alert.type.index,
      'detail': alert.detail,
      'date': alert.date.millisecondsSinceEpoch,
      'priority': alert.priority,
      'state': alert.state.index,
    });
  }

  Future<List<AlertItem>> getAlerts() async {
    final snapshot = await _database.child('alerts').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final alertData = entry.value as Map<dynamic, dynamic>;
        return AlertItem(
          type: AlertType.values[alertData['type'] ?? 0],
          detail: alertData['detail'] ?? '',
          date: DateTime.fromMillisecondsSinceEpoch(alertData['date'] ?? 0),
          priority: alertData['priority'] ?? '',
          state: AlertState.values[alertData['state'] ?? 0],
        );
      }).toList();
    }
    return [];
  }

  Future<void> updateAlertState(String key, AlertState state) async {
    await _database.child('alerts').child(key).update({
      'state': state.index,
    });
  }

  // --- Xóa tất cả dữ liệu (để reset) ---
  Future<void> clearAllData() async {
    await _database.child('lecturers').remove();
    await _database.child('schedules').remove();
    await _database.child('leaveRequests').remove();
    await _database.child('makeups').remove();
    await _database.child('alerts').remove();
  }
}
