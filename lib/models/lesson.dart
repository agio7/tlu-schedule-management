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
  final String? teacherId;
  final String? subjectId;
  final String? classroomId;
  final String? roomId;
  final String? notes;

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
    this.teacherId,
    this.subjectId,
    this.classroomId,
    this.roomId,
    this.notes,
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
    String? teacherId,
    String? subjectId,
    String? classroomId,
    String? roomId,
    String? notes,
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
      teacherId: teacherId ?? this.teacherId,
      subjectId: subjectId ?? this.subjectId,
      classroomId: classroomId ?? this.classroomId,
      roomId: roomId ?? this.roomId,
      notes: notes ?? this.notes,
    );
  }

  // Factory constructor để tạo Lesson từ Map (Firestore document)
  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    
    // Xử lý date từ Firestore Timestamp
    DateTime date;
    if (map['date'] != null) {
      if (map['date'] is DateTime) {
        date = map['date'] as DateTime;
      } else {
        // Nếu là Timestamp từ Firestore
        date = (map['date'] as dynamic).toDate();
      }
    } else {
      date = DateTime.now();
    }

    final lesson = Lesson(
      id: id,
      subject: map['subject']?.toString() ?? 'Môn học chưa xác định',
      className: map['className']?.toString() ?? '',
      date: date,
      startTime: map['startTime']?.toString() ?? '',
      endTime: map['endTime']?.toString() ?? '',
      room: map['room']?.toString() ?? '',
      status: map['status']?.toString() ?? 'upcoming',
      sessionNumber: (map['sessionNumber'] as num?)?.toInt() ?? 1,
      sessionTitle: map['sessionTitle']?.toString() ?? '',
      content: map['content']?.toString(),
      attendanceList: List<String>.from((map['attendanceList'] as List?)?.map((e) => e.toString()) ?? []),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      teacherId: map['teacherId']?.toString(),
      subjectId: map['subjectId']?.toString(),
      classroomId: map['classroomId']?.toString(),
      roomId: map['roomId']?.toString(),
      notes: map['notes']?.toString(),
    );
    
    return lesson;
  }

  // Method để chuyển Lesson thành Map (để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'className': className,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'status': status,
      'sessionNumber': sessionNumber,
      'sessionTitle': sessionTitle,
      'content': content,
      'attendanceList': attendanceList,
      'isCompleted': isCompleted,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'classroomId': classroomId,
      'roomId': roomId,
      'notes': notes,
    };
  }
}




