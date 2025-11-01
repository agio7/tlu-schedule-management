import 'dart:async';
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
  
  // Stream subscriptions để có thể cancel
  StreamSubscription<List<Lesson>>? _lessonsSubscription;
  StreamSubscription<List<LeaveRequest>>? _leaveRequestsSubscription;
  bool _streamsInitialized = false;

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
    // Chỉ setup một lần
    if (_streamsInitialized) {
      return;
    }
    
    // Cancel existing subscriptions nếu có
    _lessonsSubscription?.cancel();
    _leaveRequestsSubscription?.cancel();
    
    // Initial load ngay lập tức để có dữ liệu sẵn
    loadLessonsByTeacher(teacherId);
    loadLeaveRequestsByTeacher(teacherId);
    
    // Listen to lessons changes
    _lessonsSubscription = RealtimeService.getLessonsStreamByTeacher(teacherId).listen(
      (lessons) {
        _lessons = lessons;
        notifyListeners();
      },
      onError: (error) {
        print('Error in lessons stream: $error');
        _error = 'Lỗi khi tải dữ liệu buổi học: $error';
        // Load fallback data
        loadLessonsByTeacher(teacherId);
        notifyListeners();
      },
    );

    // Listen to leave requests changes
    _leaveRequestsSubscription = RealtimeService.getLeaveRequestsStreamByTeacher(teacherId).listen(
      (leaveRequests) {
        _leaveRequests = leaveRequests;
        notifyListeners();
      },
      onError: (error) {
        print('Error in leave requests stream: $error');
        _error = 'Lỗi khi tải dữ liệu nghỉ dạy: $error';
        // Load fallback data
        loadLeaveRequestsByTeacher(teacherId);
        notifyListeners();
      },
    );
    
    _streamsInitialized = true;
  }

  // Setup real-time streams for all data (admin view)
  void setupAllRealtimeStreams() {
    // Chỉ setup một lần
    if (_streamsInitialized) {
      return;
    }
    
    // Cancel existing subscriptions nếu có
    _lessonsSubscription?.cancel();
    _leaveRequestsSubscription?.cancel();
    
    // Initial load ngay lập tức để có dữ liệu sẵn
    loadLessons();
    loadLeaveRequests();
    
    // Listen to all lessons changes
    _lessonsSubscription = RealtimeService.getAllLessonsStream().listen(
      (lessons) {
        _lessons = lessons;
        notifyListeners();
      },
      onError: (error) {
        print('Error in all lessons stream: $error');
        _error = 'Lỗi khi tải dữ liệu buổi học: $error';
        // Load fallback data
        loadLessons();
        notifyListeners();
      },
    );

    // Listen to all leave requests changes
    _leaveRequestsSubscription = RealtimeService.getAllLeaveRequestsStream().listen(
      (leaveRequests) {
        _leaveRequests = leaveRequests;
        notifyListeners();
      },
      onError: (error) {
        print('Error in all leave requests stream: $error');
        _error = 'Lỗi khi tải dữ liệu nghỉ dạy: $error';
        // Load fallback data
        loadLeaveRequests();
        notifyListeners();
      },
    );
    
    _streamsInitialized = true;
  }
  
  // Reset streams (để có thể reload)
  void resetStreams() {
    _lessonsSubscription?.cancel();
    _leaveRequestsSubscription?.cancel();
    _lessons = [];
    _leaveRequests = [];
    _streamsInitialized = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _lessonsSubscription?.cancel();
    _leaveRequestsSubscription?.cancel();
    super.dispose();
  }
}



