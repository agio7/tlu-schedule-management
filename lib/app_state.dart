import 'package:flutter/material.dart';

// --- ENUMS ---
enum SessionStatus { daDay, nghi, dayBu, chuaDay }
enum RequestStatus { pending, approved, rejected }
enum AlertType { conflict, delay, highLeave, noMakeup }
enum AlertState { unresolved, inProgress, resolved }

// --- MODELS ---
class Lecturer {
  Lecturer({
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    required this.subject,
    required this.hoursPlanned,
    required this.hoursActual,
  });

  final String name;
  final String title;
  final String email;
  final String phone;
  final String subject;
  final int hoursPlanned;
  final int hoursActual;
}

class ScheduleItem {
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

  final String lecturer;
  final String subject;
  final String className;
  final DateTime date;
  final String session;
  final String room;
  SessionStatus status;
  final String? attendance;
}

class LeaveRequest {
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
    this.status = RequestStatus.pending,
  });

  final String lecturer;
  final String subject;
  final String className;
  final DateTime date;
  final String session;
  final String room;
  final DateTime submittedAt;
  final String reason;
  final String? documentUrl;
  RequestStatus status;
}

class MakeupRegistration {
  MakeupRegistration({
    required this.lecturer,
    required this.originalDate,
    required this.originalSession,
    required this.makeupDate,
    required this.makeupSession,
    required this.makeupRoom,
    this.studentConfirmedPercent,
    this.status = RequestStatus.pending,
  });

  final String lecturer;
  final DateTime originalDate;
  final String originalSession;
  final DateTime makeupDate;
  final String makeupSession;
  final String makeupRoom;
  final int? studentConfirmedPercent;
  RequestStatus status;
}

class AlertItem {
  AlertItem({
    required this.type,
    required this.detail,
    required this.date,
    required this.priority,
    this.state = AlertState.unresolved,
  });

  final AlertType type;
  final String detail;
  final DateTime date;
  final String priority;
  AlertState state;
}

// --- STATE MANAGEMENT ---
class AppState extends ChangeNotifier {
  // KHỞI TẠO TẤT CẢ CÁC DANH SÁCH LÀ RỖNG []
  final List<Lecturer> lecturers = [];
  final List<ScheduleItem> schedules = [];
  final List<LeaveRequest> leaveRequests = [];
  final List<MakeupRegistration> makeups = [];
  final List<AlertItem> alerts = [];

  AppState();

  int currentTabIndex = 0;

  // --- Getters cho KPI Cards ---
  int get totalLecturers => lecturers.length;
  int get totalSubjects => lecturers.map((e) => e.subject).toSet().length;
  int get totalSessions => schedules.length;
  int get totalAlerts => alerts.length;

  void setTab(int i) {
    currentTabIndex = i;
    notifyListeners();
  }

  // --- Nghiệp vụ phê duyệt (giữ lại logic để minh họa) ---
  void approveLeave(LeaveRequest r, bool approve) {
    // Logic cập nhật trạng thái
    r.status = approve ? RequestStatus.approved : RequestStatus.rejected;
    notifyListeners();
  }

  void approveMakeup(MakeupRegistration m, bool approve) {
    // Logic cập nhật trạng thái
    m.status = approve ? RequestStatus.approved : RequestStatus.rejected;
    notifyListeners();
  }

  void updateAlertState(AlertItem a, AlertState s) {
    // Logic cập nhật trạng thái cảnh báo
    a.state = s;
    notifyListeners();
  }
}

// --- HELPERS ---
String statusLabel(SessionStatus s) => {
  SessionStatus.daDay: 'Đã dạy',
  SessionStatus.nghi: 'Nghỉ',
  SessionStatus.dayBu: 'Dạy bù',
  SessionStatus.chuaDay: 'Chưa dạy',
}[s]!;

String alertTypeLabel(AlertType t) => {
  AlertType.conflict: 'Trùng lịch',
  AlertType.delay: 'Chậm tiến độ',
  AlertType.highLeave: 'Nghỉ nhiều',
  AlertType.noMakeup: 'Chưa dạy bù',
}[t]!;

String alertStateLabel(AlertState s) => {
  AlertState.unresolved: 'Chưa xử lý',
  AlertState.inProgress: 'Đang xử lý',
  AlertState.resolved: 'Đã xử lý',
}[s]!;

String dmy(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';