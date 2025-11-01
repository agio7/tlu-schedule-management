// Models for Department Head (Trưởng bộ môn) Dashboard

// Enums
enum SessionStatus {
  chuaDay,
  daDay,
  nghi,
  dayBu,
}

enum RequestStatus {
  pending,
  approved,
  rejected,
}

enum AlertType {
  conflict,
  noMakeup,
  delay,
}

enum AlertState {
  unresolved,
  inProgress,
  resolved,
}

// Lecturer Model
class Lecturer {
  final String name;
  final String email;
  final String phone;
  final String title;
  final String subject;
  final int hoursPlanned;
  final int hoursActual;

  Lecturer({
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.subject,
    required this.hoursPlanned,
    required this.hoursActual,
  });
}

// Leave Request Model (for UI)
class LeaveRequest {
  final String lecturer;
  final String subject;
  final String className;
  final String room;
  final DateTime date;
  final String session;
  final String reason;
  final RequestStatus status;
  final DateTime submittedAt;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;
  final DateTime? approvedDate;

  LeaveRequest({
    required this.lecturer,
    required this.subject,
    required this.className,
    required this.room,
    required this.date,
    required this.session,
    required this.reason,
    required this.status,
    required this.submittedAt,
    this.approvedBy,
    this.rejectedBy,
    this.rejectionReason,
    this.approvedDate,
  });
}

// Makeup Registration Model (for UI)
class MakeupRegistration {
  final String lecturer;
  final String subject;
  final String className;
  final DateTime originalDate;
  final String originalSession;
  final DateTime makeupDate;
  final String makeupSession;
  final String makeupRoom;
  final RequestStatus status;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;
  final DateTime? approvedDate;
  final DateTime submittedAt;

  MakeupRegistration({
    required this.lecturer,
    required this.originalDate,
    required this.originalSession,
    required this.makeupDate,
    required this.makeupSession,
    required this.makeupRoom,
    this.status = RequestStatus.pending,
    this.subject = '',
    this.className = '',
    this.approvedBy,
    this.rejectedBy,
    this.rejectionReason,
    this.approvedDate,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();
}

// Schedule Item Model (for UI)
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

// Alert Item Model
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

// Helper function to format date
String dmy(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

