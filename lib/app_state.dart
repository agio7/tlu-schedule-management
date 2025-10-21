import 'package:flutter/material.dart';
import 'firebase_service.dart';

// --- Enums ---
enum SessionStatus { chuaDay, daDay, nghi, dayBu }
enum RequestStatus { pending, approved, rejected }
enum AlertType { conflict, noMakeup, delay }
enum AlertState { unresolved, inProgress, resolved }

// --- Data Models ---
class Lecturer {
  final String name;
  final String title;
  final String email;
  final String phone;
  final String subject;
  final int hoursPlanned;
  final int hoursActual;

  Lecturer({
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    required this.subject,
    required this.hoursPlanned,
    required this.hoursActual,
  });
}

class ScheduleItem {
  final String lecturer;
  final String subject;
  final String className;
  final DateTime date;
  final String session;
  final String room;
  final SessionStatus status;
  final String? attendance;

  ScheduleItem({
    required this.lecturer,
    required this.subject,
    required this.className,
    required this.date,
    required this.session,
    required this.room,
    required this.status,
    this.attendance,
  });
}

class LeaveRequest {
  final String lecturer;
  final String subject;
  final String className;
  final DateTime date;
  final String session;
  final String room;
  final DateTime submittedAt;
  final String reason;
  final String? documentUrl;
  final RequestStatus status;

  LeaveRequest({
    required this.lecturer,
    required this.subject,
    required this.className,
    required this.date,
    required this.session,
    required this.room,
    required this.submittedAt,
    required this.reason,
    this.documentUrl,
    required this.status,
  });
}

class MakeupRegistration {
  final String lecturer;
  final DateTime originalDate;
  final String originalSession;
  final DateTime makeupDate;
  final String makeupSession;
  final String makeupRoom;
  final int studentConfirmedPercent;
  final RequestStatus status;

  MakeupRegistration({
    required this.lecturer,
    required this.originalDate,
    required this.originalSession,
    required this.makeupDate,
    required this.makeupSession,
    required this.makeupRoom,
    required this.studentConfirmedPercent,
    required this.status,
  });
}

class AlertItem {
  final AlertType type;
  final String detail;
  final DateTime date;
  final String priority;
  final AlertState state;

  AlertItem({
    required this.type,
    required this.detail,
    required this.date,
    required this.priority,
    required this.state,
  });
}

// --- App State ---
class AppState extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  final List<Lecturer> lecturers = [];
  final List<ScheduleItem> schedules = [];
  final List<LeaveRequest> leaveRequests = [];
  final List<MakeupRegistration> makeups = [];
  final List<AlertItem> alerts = [];

  AppState() {
    _loadData();
  }

  // --- Getters ---
  int get totalLecturers => lecturers.length;
  int get totalSubjects => lecturers.map((e) => e.subject).toSet().length;
  int get totalSessions => schedules.length;
  int get totalAlerts => alerts.length;
  bool get isLoading => _isLoading;

  // --- Load dữ liệu từ Firebase ---
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load tất cả dữ liệu từ Firebase
      final lecturersData = await _firebaseService.getLecturers();
      final schedulesData = await _firebaseService.getSchedules();
      final leaveRequestsData = await _firebaseService.getLeaveRequests();
      final makeupsData = await _firebaseService.getMakeups();
      final alertsData = await _firebaseService.getAlerts();

      // Cập nhật dữ liệu
      lecturers.clear();
      lecturers.addAll(lecturersData);

      schedules.clear();
      schedules.addAll(schedulesData);

      leaveRequests.clear();
      leaveRequests.addAll(leaveRequestsData);

      makeups.clear();
      makeups.addAll(makeupsData);

      alerts.clear();
      alerts.addAll(alertsData);

    } catch (e) {
      print('Lỗi khi load dữ liệu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Refresh dữ liệu ---
  Future<void> refreshData() async {
    await _loadData();
  }


  // --- Business Logic ---
  int _currentTab = 0;
  int get currentTab => _currentTab;
  
  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  Future<void> approveLeave(int index) async {
    try {
      final request = leaveRequests[index];
      // TODO: Cập nhật status trong Firebase
      print('Đã duyệt yêu cầu nghỉ của ${request.lecturer}');
    } catch (e) {
      print('Lỗi khi duyệt yêu cầu nghỉ: $e');
    }
  }

  Future<void> approveMakeup(int index) async {
    try {
      final makeup = makeups[index];
      // TODO: Cập nhật status trong Firebase
      print('Đã duyệt đăng ký dạy bù của ${makeup.lecturer}');
    } catch (e) {
      print('Lỗi khi duyệt đăng ký dạy bù: $e');
    }
  }

  Future<void> updateAlertState(int index, AlertState newState) async {
    try {
      final alert = alerts[index];
      // TODO: Cập nhật state trong Firebase
      print('Đã cập nhật trạng thái cảnh báo: ${alert.detail}');
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái cảnh báo: $e');
    }
  }
}

// --- Helper Functions ---
String dmy(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String hm(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String getSessionStatusText(SessionStatus status) {
  switch (status) {
    case SessionStatus.chuaDay:
      return 'Chưa dạy';
    case SessionStatus.daDay:
      return 'Đã dạy';
    case SessionStatus.nghi:
      return 'Nghỉ';
    case SessionStatus.dayBu:
      return 'Dạy bù';
  }
}

String getRequestStatusText(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return 'Chờ duyệt';
    case RequestStatus.approved:
      return 'Đã duyệt';
    case RequestStatus.rejected:
      return 'Từ chối';
  }
}

String getAlertTypeText(AlertType type) {
  switch (type) {
    case AlertType.conflict:
      return 'Xung đột lịch';
    case AlertType.noMakeup:
      return 'Chưa dạy bù';
    case AlertType.delay:
      return 'Chậm tiến độ';
  }
}

String getAlertStateText(AlertState state) {
  switch (state) {
    case AlertState.unresolved:
      return 'Chưa giải quyết';
    case AlertState.inProgress:
      return 'Đang xử lý';
    case AlertState.resolved:
      return 'Đã giải quyết';
  }
}

Color getSessionStatusColor(SessionStatus status) {
  switch (status) {
    case SessionStatus.chuaDay:
      return Colors.orange;
    case SessionStatus.daDay:
      return Colors.green;
    case SessionStatus.nghi:
      return Colors.red;
    case SessionStatus.dayBu:
      return Colors.blue;
  }
}

Color getRequestStatusColor(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return Colors.orange;
    case RequestStatus.approved:
      return Colors.green;
    case RequestStatus.rejected:
      return Colors.red;
  }
}

Color getAlertPriorityColor(String priority) {
  switch (priority) {
    case 'Cao':
      return Colors.red;
    case 'Trung bình':
      return Colors.orange;
    case 'Thấp':
      return Colors.green;
    default:
      return Colors.grey;
  }
}