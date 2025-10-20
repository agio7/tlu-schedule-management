import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả lịch dạy
  Stream<List<Lesson>> getLessonsStream(String teacherId) {
    return _firestore
        .collection('schedules')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Lesson(
          id: doc.id,
          subject: data['subjectName'] ?? '',
          className: data['className'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          startTime: data['startTime'] ?? '',
          endTime: data['endTime'] ?? '',
          room: data['roomName'] ?? '',
          status: _calculateStatus(
            (data['date'] as Timestamp).toDate(),
            data['startTime'] ?? '',
            data['endTime'] ?? '',
          ),
          sessionNumber: data['sessionNumber'] ?? 1,
          sessionTitle: data['sessionTitle'] ?? '',
          content: data['content'],
          attendanceList: List<String>.from(data['attendanceList'] ?? []),
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();
    });
  }

  // Lấy lịch dạy theo ID
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final doc = await _firestore.collection('schedules').doc(lessonId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Lesson(
        id: doc.id,
        subject: data['subjectName'] ?? '',
        className: data['className'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        startTime: data['startTime'] ?? '',
        endTime: data['endTime'] ?? '',
        room: data['roomName'] ?? '',
        status: _calculateStatus(
          (data['date'] as Timestamp).toDate(),
          data['startTime'] ?? '',
          data['endTime'] ?? '',
        ),
        sessionNumber: data['sessionNumber'] ?? 1,
        sessionTitle: data['sessionTitle'] ?? '',
        content: data['content'],
        attendanceList: List<String>.from(data['attendanceList'] ?? []),
        isCompleted: data['isCompleted'] ?? false,
      );
    } catch (e) {
      print('Error getting lesson: $e');
      return null;
    }
  }

  // Cập nhật nội dung bài học
  Future<void> updateLessonContent(String lessonId, String content) async {
    await _firestore.collection('schedules').doc(lessonId).update({
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Cập nhật điểm danh
  Future<void> updateAttendance(String lessonId, List<String> attendanceList) async {
    await _firestore.collection('schedules').doc(lessonId).update({
      'attendanceList': attendanceList,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Gửi đơn xin nghỉ
  Future<void> submitLeaveRequest(LeaveRequest request) async {
    await _firestore.collection('leaveRequests').add({
      'lessonId': request.lessonId,
      'type': request.type,
      'reason': request.reason,
      'makeupDate': request.makeupDate != null
          ? Timestamp.fromDate(request.makeupDate!)
          : null,
      'startTime': request.startTime,
      'endTime': request.endTime,
      'additionalNotes': request.additionalNotes,
      'status': request.status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Lấy danh sách đơn xin nghỉ
  Stream<List<LeaveRequest>> getLeaveRequestsStream(String teacherId) {
    return _firestore
        .collection('leaveRequests')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaveRequest(
          id: doc.id,
          lessonId: data['lessonId'] ?? '',
          type: data['type'] ?? 'leave',
          reason: data['reason'] ?? '',
          makeupDate: data['makeupDate'] != null
              ? (data['makeupDate'] as Timestamp).toDate()
              : null,
          startTime: data['startTime'] ?? '',
          endTime: data['endTime'] ?? '',
          additionalNotes: data['additionalNotes'],
          status: data['status'] ?? 'pending',
        );
      }).toList();
    });
  }

  // Tính toán trạng thái bài học
  String _calculateStatus(DateTime date, String startTime, String endTime) {
    final now = DateTime.now();
    final lessonDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (lessonDate.isBefore(today)) {
      return 'completed';
    } else if (lessonDate.isAfter(today)) {
      return 'upcoming';
    } else {
      // Cùng ngày - kiểm tra giờ
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      final lessonStart = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      final lessonEnd = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      if (now.isBefore(lessonStart)) {
        return 'upcoming';
      } else if (now.isAfter(lessonEnd)) {
        return 'completed';
      } else {
        return 'ongoing';
      }
    }
  }
}