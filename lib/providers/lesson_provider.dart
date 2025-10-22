import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../models/leave_request.dart';
import '../services/lesson_service.dart';
import '../services/leave_request_service.dart';
import '../services/realtime_service.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _lessons = [];
  List<LeaveRequest> _leaveRequests = [];
  bool _isLoading = false;
  String? _error;

  List<Lesson> get lessons => _lessons;
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load lessons from Firebase
  Future<void> loadLessons() async {
    _setLoading(true);
    _error = null;
    
    try {
      _lessons = await LessonService.getAllLessons();
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải dữ liệu: $e';
      print('Error loading lessons: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load lessons by teacher ID
  Future<void> loadLessonsByTeacher(String teacherId) async {
    _setLoading(true);
    _error = null;
    
    try {
      _lessons = await LessonService.getLessonsByTeacher(teacherId);
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải dữ liệu giảng viên: $e';
      print('Error loading lessons by teacher: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load lessons by date
  Future<void> loadLessonsByDate(DateTime date) async {
    _setLoading(true);
    _error = null;
    
    try {
      _lessons = await LessonService.getLessonsByDate(date);
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải dữ liệu theo ngày: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load lessons by teacher and date
  Future<void> loadLessonsByTeacherAndDate(String teacherId, DateTime date) async {
    _setLoading(true);
    _error = null;
    
    try {
      _lessons = await LessonService.getLessonsByTeacherAndDate(teacherId, date);
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải dữ liệu giảng viên theo ngày: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }


  void _setLoading(bool loading) {
    _isLoading = loading;
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

  Future<bool> updateLessonContent(String lessonId, String content) async {
    try {
      final success = await LessonService.updateLessonContent(lessonId, content);
      if (success) {
        // Cập nhật local state
        final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) {
          _lessons[index] = _lessons[index].copyWith(content: content);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Lỗi khi cập nhật nội dung: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAttendance(String lessonId, List<String> attendanceList) async {
    try {
      final success = await LessonService.updateAttendance(lessonId, attendanceList);
      if (success) {
        // Cập nhật local state
        final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) {
          _lessons[index] = _lessons[index].copyWith(attendanceList: attendanceList);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Lỗi khi cập nhật điểm danh: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markLessonCompleted(String lessonId) async {
    try {
      final success = await LessonService.markLessonCompleted(lessonId);
      if (success) {
        // Cập nhật local state
        final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) {
          _lessons[index] = _lessons[index].copyWith(
            isCompleted: true,
            status: 'completed',
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Lỗi khi đánh dấu hoàn thành: $e';
      notifyListeners();
      return false;
    }
  }

  // Load leave requests from Firebase
  Future<void> loadLeaveRequests() async {
    try {
      _leaveRequests = await LeaveRequestService.getAllLeaveRequests();
      notifyListeners();
    } catch (e) {
      print('Error loading leave requests: $e');
    }
  }

  // Load leave requests by teacher ID
  Future<void> loadLeaveRequestsByTeacher(String teacherId) async {
    try {
      _leaveRequests = await LeaveRequestService.getLeaveRequestsByTeacher(teacherId);
      notifyListeners();
    } catch (e) {
      print('Error loading leave requests by teacher: $e');
    }
  }

  Future<void> submitLeaveRequest(LeaveRequest request) async {
    try {
      final requestId = await LeaveRequestService.createLeaveRequest(request);
      if (requestId != null) {
        _leaveRequests.add(request.copyWith(id: requestId));
        notifyListeners();
      }
    } catch (e) {
      print('Error submitting leave request: $e');
    }
  }

  List<Lesson> getCompletedLessons() {
    return _lessons.where((lesson) => lesson.isCompleted).toList();
  }

  List<Lesson> getUpcomingLessons() {
    return _lessons.where((lesson) => !lesson.isCompleted).toList();
  }

  // Setup real-time streams
  void setupRealtimeStreams(String teacherId) {
    // Listen to lessons changes
    RealtimeService.getLessonsStreamByTeacher(teacherId).listen((lessons) {
      _lessons = lessons;
      notifyListeners();
    });

    // Listen to leave requests changes
    RealtimeService.getLeaveRequestsStreamByTeacher(teacherId).listen((leaveRequests) {
      _leaveRequests = leaveRequests;
      notifyListeners();
    });
  }

  // Setup real-time streams for all data (admin view)
  void setupAllRealtimeStreams() {
    // Listen to all lessons changes
    RealtimeService.getAllLessonsStream().listen((lessons) {
      _lessons = lessons;
      notifyListeners();
    });

    // Listen to all leave requests changes
    RealtimeService.getAllLeaveRequestsStream().listen((leaveRequests) {
      _leaveRequests = leaveRequests;
      notifyListeners();
    });
  }
}



