import 'package:flutter/foundation.dart';
import '../models/lesson.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _lessons = [];
  List<LeaveRequest> _leaveRequests = [];

  List<Lesson> get lessons => _lessons;
  List<LeaveRequest> get leaveRequests => _leaveRequests;

  // Sample data for demonstration
  void loadSampleData() {
    _lessons = [
      Lesson(
        id: '1',
        subject: 'Phân tích thiết kế hệ thống',
        className: 'CNPM-K14',
        date: DateTime(2025, 9, 21),
        startTime: '07:30',
        endTime: '09:30',
        room: 'A107',
        status: 'completed',
        sessionNumber: 1,
        sessionTitle: 'Giới thiệu môn học',
        isCompleted: true,
      ),
      Lesson(
        id: '2',
        subject: 'Công nghệ phần mềm',
        className: 'CNTT-K14',
        date: DateTime(2025, 9, 21),
        startTime: '13:30',
        endTime: '15:30',
        room: 'C202',
        status: 'ongoing',
        sessionNumber: 2,
        sessionTitle: 'Phương pháp thu thập yêu cầu',
        isCompleted: false,
      ),
      Lesson(
        id: '3',
        subject: 'Phân tích thiết kế hệ thống',
        className: 'CNPM-K14',
        date: DateTime(2025, 9, 28),
        startTime: '07:30',
        endTime: '09:30',
        room: 'A107',
        status: 'upcoming',
        sessionNumber: 4,
        sessionTitle: 'Xây dựng biểu đồ use-case',
        isCompleted: false,
      ),
      Lesson(
        id: '4',
        subject: 'Lập trình web',
        className: 'CNPM-K15',
        date: DateTime(2025, 10, 5),
        startTime: '07:30',
        endTime: '09:30',
        room: 'B203',
        status: 'upcoming',
        sessionNumber: 1,
        sessionTitle: 'Giới thiệu HTML/CSS',
        isCompleted: false,
      ),
    ];
    notifyListeners();
  }

  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Lesson> getTodayLessons() {
    final today = DateTime.now();
    return _lessons.where((lesson) {
      return lesson.date.year == today.year &&
          lesson.date.month == today.month &&
          lesson.date.day == today.day;
    }).toList();
  }

  List<Lesson> getLessonsBySubject(String subject) {
    return _lessons.where((lesson) => lesson.subject == subject).toList();
  }

  void updateLessonContent(String lessonId, String content) {
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1) {
      _lessons[index] = _lessons[index].copyWith(content: content);
      notifyListeners();
    }
  }

  void updateAttendance(String lessonId, List<String> attendanceList) {
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1) {
      _lessons[index] = _lessons[index].copyWith(attendanceList: attendanceList);
      notifyListeners();
    }
  }

  void submitLeaveRequest(LeaveRequest request) {
    _leaveRequests.add(request);
    notifyListeners();
  }

  List<Lesson> getCompletedLessons() {
    return _lessons.where((lesson) => lesson.isCompleted).toList();
  }

  List<Lesson> getUpcomingLessons() {
    return _lessons.where((lesson) => !lesson.isCompleted).toList();
  }
}



