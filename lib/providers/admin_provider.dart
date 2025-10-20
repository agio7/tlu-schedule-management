import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/teacher_service.dart';
import '../services/subject_service.dart';
import '../services/classroom_service.dart';
import '../services/room_service.dart';
import '../models/user.dart';
import '../models/teacher.dart';
import '../models/subject.dart';
import '../models/classroom.dart';
import '../models/room.dart';
import '../models/schedule.dart';
import '../models/leave_request.dart';

class AdminProvider with ChangeNotifier {
  Map<String, int> _dashboardStats = {};
  List<User> _users = [];
  List<Teacher> _teachers = [];
  List<Subject> _subjects = [];
  List<Classroom> _classrooms = [];
  List<Room> _rooms = [];
  List<Schedule> _schedules = [];
  List<LeaveRequest> _leaveRequests = [];
  List<LeaveRequest> _pendingLeaveRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, int> get dashboardStats => _dashboardStats;
  List<User> get users => _users;
  List<Teacher> get teachers => _teachers;
  List<Subject> get subjects => _subjects;
  List<Classroom> get classrooms => _classrooms;
  List<Room> get rooms => _rooms;
  List<Schedule> get schedules => _schedules;
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  List<LeaveRequest> get pendingLeaveRequests => _pendingLeaveRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load dashboard statistics từ Firestore
  Future<void> loadDashboardStats() async {
    _setLoading(true);
    _clearError();
    try {
      print('📊 AdminProvider: Đang load dashboard stats...');
      _dashboardStats = await AdminService.getDashboardStats();
      print('✅ AdminProvider: Dashboard stats loaded: $_dashboardStats');
    } catch (e) {
      _setError('Không thể tải dữ liệu tổng quan: $e');
      print('❌ Error loading dashboard stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load users by role với stream
  Future<void> loadUsersByRole(String role) async {
    _setLoading(true);
    _clearError();
    try {
      print('👥 AdminProvider: Đang load users với role: $role...');
      AdminService.getUsersStreamByRole(role).listen((users) {
        _users = users;
        print('✅ AdminProvider: Loaded ${users.length} users với role $role');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách người dùng: $e');
        print('❌ Error loading users by role: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách người dùng: $e');
      print('❌ Error setting up user stream: $e');
      _setLoading(false);
    }
  }

  // Load teachers với stream
  Future<void> loadTeachers() async {
    _setLoading(true);
    _clearError();
    try {
      print('👨‍🏫 AdminProvider: Đang load teachers...');
      AdminService.getTeachersStream().listen((teachers) {
        _teachers = teachers;
        print('✅ AdminProvider: Loaded ${teachers.length} teachers');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách giảng viên: $e');
        print('❌ Error loading teachers: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách giảng viên: $e');
      print('❌ Error setting up teachers stream: $e');
      _setLoading(false);
    }
  }

  // Load subjects với stream
  Future<void> loadSubjects() async {
    _setLoading(true);
    _clearError();
    try {
      print('📚 AdminProvider: Đang load subjects...');
      SubjectService.getSubjectsStream().listen((subjects) {
        _subjects = subjects;
        print('✅ AdminProvider: Loaded ${subjects.length} subjects');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách môn học: $e');
        print('❌ Error loading subjects: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách môn học: $e');
      print('❌ Error setting up subjects stream: $e');
      _setLoading(false);
    }
  }

  // Load classrooms với stream
  Future<void> loadClassrooms() async {
    _setLoading(true);
    _clearError();
    try {
      print('🏫 AdminProvider: Đang load classrooms...');
      ClassroomService.getClassroomsStream().listen((classrooms) {
        _classrooms = classrooms;
        print('✅ AdminProvider: Loaded ${classrooms.length} classrooms');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách lớp học: $e');
        print('❌ Error loading classrooms: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách lớp học: $e');
      print('❌ Error setting up classrooms stream: $e');
      _setLoading(false);
    }
  }

  // Load rooms với stream
  Future<void> loadRooms() async {
    _setLoading(true);
    _clearError();
    try {
      print('🏢 AdminProvider: Đang load rooms...');
      RoomService.getRoomsStream().listen((rooms) {
        _rooms = rooms;
        print('✅ AdminProvider: Loaded ${rooms.length} rooms');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách phòng học: $e');
        print('❌ Error loading rooms: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách phòng học: $e');
      print('❌ Error setting up rooms stream: $e');
      _setLoading(false);
    }
  }

  // Load schedules với stream
  Future<void> loadSchedules() async {
    _setLoading(true);
    _clearError();
    try {
      print('📅 AdminProvider: Đang load schedules...');
      AdminService.getSchedulesStream().listen((schedules) {
        _schedules = schedules;
        print('✅ AdminProvider: Loaded ${schedules.length} schedules');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách lịch trình: $e');
        print('❌ Error loading schedules: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách lịch trình: $e');
      print('❌ Error setting up schedules stream: $e');
      _setLoading(false);
    }
  }

  // Load leave requests với stream
  Future<void> loadLeaveRequests() async {
    _setLoading(true);
    _clearError();
    try {
      print('📝 AdminProvider: Đang load leave requests...');
      AdminService.getLeaveRequestsStream().listen((leaveRequests) {
        _leaveRequests = leaveRequests;
        print('✅ AdminProvider: Loaded ${leaveRequests.length} leave requests');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách yêu cầu nghỉ phép: $e');
        print('❌ Error loading leave requests: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách yêu cầu nghỉ phép: $e');
      print('❌ Error setting up leave requests stream: $e');
      _setLoading(false);
    }
  }

  // Load pending leave requests với stream
  Future<void> loadPendingLeaveRequests() async {
    _setLoading(true);
    _clearError();
    try {
      print('📝 AdminProvider: Đang load pending leave requests...');
      AdminService.getLeaveRequestsByStatusStream('pending').listen((pendingRequests) {
        _pendingLeaveRequests = pendingRequests;
        print('✅ AdminProvider: Loaded ${pendingRequests.length} pending leave requests');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách yêu cầu nghỉ phép chờ duyệt: $e');
        print('❌ Error loading pending leave requests: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách yêu cầu nghỉ phép chờ duyệt: $e');
      print('❌ Error setting up pending leave requests stream: $e');
      _setLoading(false);
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();
    try {
      print('🗑️ AdminProvider: Đang xóa user $userId...');
      await AdminService.deleteUser(userId);
      print('✅ AdminProvider: User $userId đã được xóa');
      // Data will automatically refresh via stream
    } catch (e) {
      _setError('Không thể xóa người dùng: $e');
      print('❌ Error deleting user: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update leave request status
  Future<void> updateLeaveRequestStatus(String requestId, String status, String? approverNotes) async {
    _setLoading(true);
    _clearError();
    try {
      print('📝 AdminProvider: Đang cập nhật leave request $requestId với status: $status...');
      await AdminService.updateLeaveRequestStatus(requestId, status, approverNotes);
      print('✅ AdminProvider: Leave request $requestId đã được cập nhật');
      // Data will automatically refresh via stream
    } catch (e) {
      _setError('Không thể cập nhật yêu cầu nghỉ phép: $e');
      print('❌ Error updating leave request: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      print('👤 AdminProvider: Đang lấy thông tin user $userId...');
      return await AdminService.getUserById(userId);
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  // Get schedule by ID
  Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      print('📅 AdminProvider: Đang lấy thông tin schedule $scheduleId...');
      return await AdminService.getScheduleById(scheduleId);
    } catch (e) {
      print('❌ Error getting schedule by ID: $e');
      return null;
    }
  }

  // Helper methods để filter data
  List<Schedule> getSchedulesByTeacher(String teacherId) {
    return _schedules.where((schedule) => schedule.teacherId == teacherId).toList();
  }

  List<Schedule> getSchedulesByDateRange(DateTime startDate, DateTime endDate) {
    return _schedules.where((schedule) {
      return schedule.startTime.isAfter(startDate) && schedule.startTime.isBefore(endDate);
    }).toList();
  }

  List<LeaveRequest> getLeaveRequestsByTeacher(String teacherId) {
    return _leaveRequests.where((request) => request.teacherId == teacherId).toList();
  }

  List<LeaveRequest> getLeaveRequestsByStatus(String status) {
    return _leaveRequests.where((request) => request.status.toString().split('.').last == status).toList();
  }

  // CRUD operations for Teachers
  Future<void> addTeacher(Map<String, dynamic> teacherData) async {
    _setLoading(true);
    _clearError();
    try {
      print('👨‍🏫 AdminProvider: Đang thêm teacher mới...');
      final teacherId = await TeacherService.addTeacher(
        Teacher(
          id: '', // Will be set by Firestore
          email: teacherData['email'],
          fullName: teacherData['fullName'],
          role: teacherData['role'] ?? 'teacher',
          departmentId: teacherData['departmentId'],
          phoneNumber: teacherData['phoneNumber'],
          avatar: teacherData['avatar'],
          employeeId: teacherData['employeeId'],
          specialization: teacherData['specialization'],
          academicRank: teacherData['academicRank'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      print('✅ AdminProvider: Đã thêm teacher với ID: $teacherId');
      // Reload teachers to get updated list
      await loadTeachers();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi thêm teacher: $e');
      _setError('Lỗi khi thêm giảng viên: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTeacher(String teacherId, Map<String, dynamic> teacherData) async {
    _setLoading(true);
    _clearError();
    try {
      print('👨‍🏫 AdminProvider: Đang cập nhật teacher $teacherId...');
      final existingTeacher = _teachers.firstWhere((t) => t.id == teacherId);
      
      final updatedTeacher = existingTeacher.copyWith(
        email: teacherData['email'],
        fullName: teacherData['fullName'],
        departmentId: teacherData['departmentId'],
        phoneNumber: teacherData['phoneNumber'],
        avatar: teacherData['avatar'],
        employeeId: teacherData['employeeId'],
        specialization: teacherData['specialization'],
        academicRank: teacherData['academicRank'],
        updatedAt: DateTime.now(),
      );

      await TeacherService.updateTeacher(teacherId, updatedTeacher);
      print('✅ AdminProvider: Đã cập nhật teacher $teacherId');
      // Reload teachers to get updated list
      await loadTeachers();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi cập nhật teacher: $e');
      _setError('Lỗi khi cập nhật giảng viên: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTeacher(String teacherId) async {
    _setLoading(true);
    _clearError();
    try {
      print('👨‍🏫 AdminProvider: Đang xóa teacher $teacherId...');
      await TeacherService.deleteTeacher(teacherId);
      print('✅ AdminProvider: Đã xóa teacher $teacherId');
      // Reload teachers to get updated list
      await loadTeachers();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi xóa teacher: $e');
      _setError('Lỗi khi xóa giảng viên: $e');
    } finally {
      _setLoading(false);
    }
  }

  // CRUD operations for Subjects
  Future<void> addSubject(Map<String, dynamic> subjectData) async {
    _setLoading(true);
    _clearError();
    try {
      print('📚 AdminProvider: Đang thêm subject mới...');
      final subjectId = await SubjectService.addSubject(
        Subject(
          id: '', // Will be set by Firestore
          name: subjectData['name'],
          code: subjectData['code'],
          departmentId: subjectData['departmentId'] ?? '',
          credits: subjectData['credits'] ?? 0,
          totalHours: subjectData['totalHours'] ?? 0,
          description: subjectData['description'],
          prerequisites: subjectData['prerequisites'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      print('✅ AdminProvider: Đã thêm subject với ID: $subjectId');
      await loadSubjects();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi thêm subject: $e');
      _setError('Lỗi khi thêm môn học: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSubject(String subjectId, Map<String, dynamic> subjectData) async {
    _setLoading(true);
    _clearError();
    try {
      print('📚 AdminProvider: Đang cập nhật subject $subjectId...');
      final existingSubject = _subjects.firstWhere((s) => s.id == subjectId);
      
      final updatedSubject = existingSubject.copyWith(
        name: subjectData['name'],
        code: subjectData['code'],
        departmentId: subjectData['departmentId'],
        credits: subjectData['credits'],
        totalHours: subjectData['totalHours'],
        description: subjectData['description'],
        prerequisites: subjectData['prerequisites'],
        updatedAt: DateTime.now(),
      );

      await SubjectService.updateSubject(subjectId, updatedSubject);
      print('✅ AdminProvider: Đã cập nhật subject $subjectId');
      await loadSubjects();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi cập nhật subject: $e');
      _setError('Lỗi khi cập nhật môn học: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    _setLoading(true);
    _clearError();
    try {
      print('📚 AdminProvider: Đang xóa subject $subjectId...');
      await SubjectService.deleteSubject(subjectId);
      print('✅ AdminProvider: Đã xóa subject $subjectId');
      await loadSubjects();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi xóa subject: $e');
      _setError('Lỗi khi xóa môn học: $e');
    } finally {
      _setLoading(false);
    }
  }

  // CRUD operations for Classrooms
  Future<void> addClassroom(Map<String, dynamic> classroomData) async {
    _setLoading(true);
    _clearError();
    try {
      print('🏫 AdminProvider: Đang thêm classroom mới...');
      final classroomId = await ClassroomService.addClassroom(
        Classroom(
          id: '', // Will be set by Firestore
          name: classroomData['name'],
          code: classroomData['code'],
          departmentId: classroomData['departmentId'] ?? '',
          academicYear: classroomData['academicYear'] ?? '',
          semester: classroomData['semester'] ?? '',
          studentCount: classroomData['studentCount'] ?? 0,
          description: classroomData['description'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      print('✅ AdminProvider: Đã thêm classroom với ID: $classroomId');
      await loadClassrooms();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi thêm classroom: $e');
      _setError('Lỗi khi thêm lớp học: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateClassroom(String classroomId, Map<String, dynamic> classroomData) async {
    _setLoading(true);
    _clearError();
    try {
      print('🏫 AdminProvider: Đang cập nhật classroom $classroomId...');
      final existingClassroom = _classrooms.firstWhere((c) => c.id == classroomId);
      
      final updatedClassroom = existingClassroom.copyWith(
        name: classroomData['name'],
        code: classroomData['code'],
        departmentId: classroomData['departmentId'],
        academicYear: classroomData['academicYear'],
        semester: classroomData['semester'],
        studentCount: classroomData['studentCount'],
        description: classroomData['description'],
        updatedAt: DateTime.now(),
      );

      await ClassroomService.updateClassroom(classroomId, updatedClassroom);
      print('✅ AdminProvider: Đã cập nhật classroom $classroomId');
      await loadClassrooms();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi cập nhật classroom: $e');
      _setError('Lỗi khi cập nhật lớp học: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteClassroom(String classroomId) async {
    _setLoading(true);
    _clearError();
    try {
      print('🏫 AdminProvider: Đang xóa classroom $classroomId...');
      await ClassroomService.deleteClassroom(classroomId);
      print('✅ AdminProvider: Đã xóa classroom $classroomId');
      await loadClassrooms();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi xóa classroom: $e');
      _setError('Lỗi khi xóa lớp học: $e');
    } finally {
      _setLoading(false);
    }
  }

  // CRUD operations for Rooms
  Future<void> addRoom(Map<String, dynamic> roomData) async {
    _setLoading(true);
    _clearError();
    try {
      print('🏢 AdminProvider: Đang thêm room mới...');
      final roomId = await RoomService.addRoom(
        Room(
          id: '', // Will be set by Firestore
          name: roomData['name'],
          code: roomData['code'],
          building: roomData['building'],
          capacity: roomData['capacity'] ?? 0,
          type: roomData['type'] ?? 'lecture',
          floor: roomData['floor'] ?? 1,
          equipment: List<String>.from(roomData['equipment'] ?? []),
          description: roomData['description'],
          isAvailable: roomData['isAvailable'] ?? true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      print('✅ AdminProvider: Đã thêm room với ID: $roomId');
      await loadRooms();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi thêm room: $e');
      _setError('Lỗi khi thêm phòng học: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> roomData) async {
    _setLoading(true);
    _clearError();
    try {
      print('🏢 AdminProvider: Đang cập nhật room $roomId...');
      final existingRoom = _rooms.firstWhere((r) => r.id == roomId);
      
      final updatedRoom = existingRoom.copyWith(
        name: roomData['name'],
        code: roomData['code'],
        building: roomData['building'],
        capacity: roomData['capacity'],
        type: roomData['type'],
        floor: roomData['floor'],
        equipment: roomData['equipment'],
        description: roomData['description'],
        isAvailable: roomData['isAvailable'],
        updatedAt: DateTime.now(),
      );

      await RoomService.updateRoom(roomId, updatedRoom);
      print('✅ AdminProvider: Đã cập nhật room $roomId');
      await loadRooms();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi cập nhật room: $e');
      _setError('Lỗi khi cập nhật phòng học: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteRoom(String roomId) async {
    _setLoading(true);
    _clearError();
    try {
      print('🏢 AdminProvider: Đang xóa room $roomId...');
      await RoomService.deleteRoom(roomId);
      print('✅ AdminProvider: Đã xóa room $roomId');
      await loadRooms();
    } catch (e) {
      print('❌ AdminProvider: Lỗi khi xóa room: $e');
      _setError('Lỗi khi xóa phòng học: $e');
    } finally {
      _setLoading(false);
    }
  }
}










