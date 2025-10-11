class Lesson {
  final String id;
  final String subject;
  final String className;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String room;
  final String status; // 'completed', 'ongoing', 'upcoming'
  final int sessionNumber;
  final String sessionTitle;
  final String? content;
  final List<String> attendanceList;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.subject,
    required this.className,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.status,
    required this.sessionNumber,
    required this.sessionTitle,
    this.content,
    this.attendanceList = const [],
    this.isCompleted = false,
  });

  Lesson copyWith({
    String? id,
    String? subject,
    String? className,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? room,
    String? status,
    int? sessionNumber,
    String? sessionTitle,
    String? content,
    List<String>? attendanceList,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      className: className ?? this.className,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      status: status ?? this.status,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      content: content ?? this.content,
      attendanceList: attendanceList ?? this.attendanceList,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class LeaveRequest {
  final String id;
  final String lessonId;
  final String type; // 'leave' or 'makeup'
  final String reason;
  final DateTime? makeupDate;
  final String startTime;
  final String endTime;
  final String? additionalNotes;
  final String status; // 'pending', 'approved', 'rejected'

  LeaveRequest({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.reason,
    this.makeupDate,
    required this.startTime,
    required this.endTime,
    this.additionalNotes,
    this.status = 'pending',
  });
}
