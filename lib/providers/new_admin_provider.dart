import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/user_service.dart';
import '../services/subject_service.dart';
import '../services/classroom_service.dart';
import '../services/room_service.dart';
import '../services/schedule_service.dart';
import '../services/leave_request_service.dart';
import '../models/users.dart';
import '../models/subjects.dart';
import '../models/classrooms.dart';
import '../models/rooms.dart';
import '../models/schedules.dart';
import '../models/leave_requests.dart';

class AdminProvider with ChangeNotifier {
  Map<String, int> _dashboardStats = {};
  List<Users> _users = [];
  List<Subjects> _subjects = [];
  List<Classrooms> _classrooms = [];
  List<Rooms> _rooms = [];
  List<Schedules> _schedules = [];
  List<LeaveRequests> _leaveRequests = [];
  List<LeaveRequests> _pendingLeaveRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, int> get dashboardStats => _dashboardStats;
  List<Users> get users => _users;
  List<Subjects> get subjects => _subjects;
  List<Classrooms> get classrooms => _classrooms;
  List<Rooms> get rooms => _rooms;
  List<Schedules> get schedules => _schedules;
  List<LeaveRequests> get leaveRequests => _leaveRequests;
  List<LeaveRequests> get pendingLeaveRequests => _pendingLeaveRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load dashboard statistics
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

  // Load users by role
  Future<void> loadUsersByRole(String role) async {
    _setLoading(true);
    _clearError();
    try {
      print('👥 AdminProvider: Đang load users với role: $role...');
      UserService.getUsersByRoleStream(role).listen((users) {
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

  // Load teachers
  Future<void> loadTeachers() async {
    await loadUsersByRole('teacher');
  }

  // Load subjects
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

  // Load classrooms
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

  // Load rooms
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

  // Load schedules
  Future<void> loadSchedules() async {
    _setLoading(true);
    _clearError();
    try {
      print('📅 AdminProvider: Đang load schedules...');
      ScheduleService.getSchedulesStream().listen((schedules) {
        _schedules = schedules;
        print('✅ AdminProvider: Loaded ${schedules.length} schedules');
        _setLoading(false);
      }, onError: (e) {
        _setError('Không thể tải danh sách lịch học: $e');
        print('❌ Error loading schedules: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách lịch học: $e');
      print('❌ Error setting up schedules stream: $e');
      _setLoading(false);
    }
  }

  // Load leave requests
  Future<void> loadLeaveRequests() async {
    _setLoading(true);
    _clearError();
    try {
      print('📝 AdminProvider: Đang load leave requests...');
      LeaveRequestService.getLeaveRequestsStream().listen((requests) {
        _leaveRequests = requests;
        _pendingLeaveRequests = requests.where((r) => r.status.toString().contains('pending')).toList();
        print('✅ AdminProvider: Loaded ${requests.length} leave requests');
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

  // Get leave requests by status
  List<LeaveRequests> getLeaveRequestsByStatus(String status) {
    return _leaveRequests.where((request) => 
      request.status.toString().contains(status)
    ).toList();
  }

  // Add user
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = Users(
        id: '', // Will be set by service
        email: userData['email'] ?? '',
        fullName: userData['fullName'] ?? '',
        role: userData['role'] ?? 'teacher',
        departmentId: userData['departmentId'],
        employeeId: userData['employeeId'],
        academicRank: userData['academicRank'],
        avatar: userData['avatar'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await UserService.addUser(user);
      await loadUsersByRole(user.role);
      
      print('✅ AdminProvider: Added user successfully');
    } catch (e) {
      _setError('Không thể thêm người dùng: $e');
      print('❌ Error adding user: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add subject
  Future<void> addSubject(Map<String, dynamic> subjectData) async {
    try {
      _setLoading(true);
      _clearError();
      
      final subject = Subjects(
        id: '', // Will be set by service
        name: subjectData['name'] ?? '',
        code: subjectData['code'] ?? '',
        departmentId: subjectData['departmentId'] ?? '',
        credits: subjectData['credits'] ?? 0,
        totalHours: subjectData['totalHours'] ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await SubjectService.addSubject(subject);
      await loadSubjects();
      
      print('✅ AdminProvider: Added subject successfully');
    } catch (e) {
      _setError('Không thể thêm môn học: $e');
      print('❌ Error adding subject: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add classroom
  Future<void> addClassroom(Map<String, dynamic> classroomData) async {
    try {
      _setLoading(true);
      _clearError();
      
      final classroom = Classrooms(
        id: '', // Will be set by service
        name: classroomData['name'] ?? '',
        code: classroomData['code'] ?? '',
        departmentId: classroomData['departmentId'] ?? '',
        academicYear: classroomData['academicYear'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await ClassroomService.addClassroom(classroom);
      await loadClassrooms();
      
      print('✅ AdminProvider: Added classroom successfully');
    } catch (e) {
      _setError('Không thể thêm lớp học: $e');
      print('❌ Error adding classroom: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add room
  Future<void> addRoom(Map<String, dynamic> roomData) async {
    try {
      _setLoading(true);
      _clearError();
      
      final room = Rooms(
        id: '', // Will be set by service
        name: roomData['name'] ?? '',
        code: roomData['code'] ?? '',
        building: roomData['building'],
        capacity: roomData['capacity'] ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await RoomService.addRoom(room);
      await loadRooms();
      
      print('✅ AdminProvider: Added room successfully');
    } catch (e) {
      _setError('Không thể thêm phòng học: $e');
      print('❌ Error adding room: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Approve leave request
  Future<void> approveLeaveRequest(String leaveRequestId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AdminService.approveLeaveRequest(leaveRequestId, 'admin');
      await loadLeaveRequests();
      
      print('✅ AdminProvider: Approved leave request successfully');
    } catch (e) {
      _setError('Không thể duyệt yêu cầu: $e');
      print('❌ Error approving leave request: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reject leave request
  Future<void> rejectLeaveRequest(String leaveRequestId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AdminService.rejectLeaveRequest(leaveRequestId, 'admin');
      await loadLeaveRequests();
      
      print('✅ AdminProvider: Rejected leave request successfully');
    } catch (e) {
      _setError('Không thể từ chối yêu cầu: $e');
      print('❌ Error rejecting leave request: $e');
    } finally {
      _setLoading(false);
    }
  }
}
