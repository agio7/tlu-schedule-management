import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_rules_setup.dart';

class FirebaseResetAndSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Xóa tất cả dữ liệu cũ và tạo lại với schema mới
  static Future<void> resetAndSetupNewDatabase() async {
    try {
      print('🗑️ Bắt đầu xóa dữ liệu cũ...');
      
      // 1. Xóa tất cả collections cũ
      await _deleteAllCollections();
      
      // 2. Cấu hình Security Rules
      await FirestoreRulesSetup.setupTemporaryRules();
      
      // 3. Tạo admin user mới (nếu cần)
      await _createAdminUser();
      
      // 4. Tạo dữ liệu mẫu với schema mới
      await _createNewSchemaData();
      
      print('✅ Hoàn thành reset và setup database mới!');
    } catch (e) {
      print('❌ Lỗi reset database: $e');
    }
  }

  /// Xóa tất cả collections trong Firestore
  static Future<void> _deleteAllCollections() async {
    try {
      print('🗑️ Đang xóa collections cũ...');
      
      // Danh sách collections cần xóa
      final collectionsToDelete = [
        'users',
        'departments', 
        'subjects',
        'rooms',
        'classrooms',
        'students',
        'semesters',
        'courseSections',
        'schedules',
        'attendance',
        'leaveRequests',
        'makeupRequests',
        // Thêm các collections cũ nếu có
        'teachers',
        'subjects_old',
        'classrooms_old',
        'rooms_old',
        'schedules_old',
        'leave_requests_old',
        'user_old',
        'department_old',
        'subject_old',
        'classroom_old',
        'room_old',
        'schedule_old',
        'leave_request_old',
      ];

      for (final collectionName in collectionsToDelete) {
        try {
          await _deleteCollection(collectionName);
          print('✅ Đã xóa collection: $collectionName');
        } catch (e) {
          print('⚠️ Không tìm thấy collection: $collectionName');
        }
      }
      
      print('✅ Hoàn thành xóa collections cũ');
    } catch (e) {
      print('❌ Lỗi xóa collections: $e');
    }
  }

  /// Xóa một collection hoàn toàn
  static Future<void> _deleteCollection(String collectionName) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection(collectionName).get();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      // Collection có thể không tồn tại, bỏ qua lỗi
    }
  }

  /// Tạo admin user mới
  static Future<void> _createAdminUser() async {
    try {
      print('👤 Kiểm tra admin user...');
      
      // Kiểm tra admin user đã tồn tại chưa
      try {
        final existingUser = await _auth.signInWithEmailAndPassword(
          email: 'admin@tlu.edu.vn',
          password: 'admin123',
        );
        if (existingUser.user != null) {
          print('✅ Admin user đã tồn tại');
          return;
        }
      } catch (e) {
        // User không tồn tại, tạo mới
        print('👤 Tạo admin user mới...');
        
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@tlu.edu.vn',
          password: 'admin123',
        );
        
        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName('Admin System');
          print('✅ Đã tạo admin user mới');
        }
      }
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('✅ Admin user đã tồn tại');
      } else {
        print('❌ Lỗi tạo admin user: $e');
      }
    }
  }

  /// Tạo dữ liệu mẫu với schema mới
  static Future<void> _createNewSchemaData() async {
    try {
      print('📊 Tạo dữ liệu mẫu với schema mới...');
      
      // 1. Tạo Departments
      final departmentIds = await _createDepartments();
      
      // 2. Tạo Users (bao gồm admin)
      final userIds = await _createUsers(departmentIds);
      
      // 3. Tạo Subjects
      final subjectIds = await _createSubjects(departmentIds);
      
      // 4. Tạo Rooms
      final roomIds = await _createRooms();
      
      // 5. Tạo Classrooms
      final classroomIds = await _createClassrooms(departmentIds);
      
      // 6. Tạo Students
      final studentIds = await _createStudents(classroomIds);
      
      // 7. Tạo Semesters
      final semesterIds = await _createSemesters();
      
      // 8. Tạo CourseSections
      final courseSectionIds = await _createCourseSections(subjectIds, userIds, semesterIds, classroomIds, roomIds);
      
      // 9. Tạo Schedules
      final scheduleIds = await _createSchedules(courseSectionIds, roomIds);
      
      // 10. Tạo Attendance
      await _createAttendance(scheduleIds, studentIds);
      
      // 11. Tạo LeaveRequests
      await _createLeaveRequests(scheduleIds, userIds);
      
      // 12. Tạo MakeupRequests
      await _createMakeupRequests(scheduleIds, userIds);
      
      print('✅ Hoàn thành tạo dữ liệu mẫu');
    } catch (e) {
      print('❌ Lỗi tạo dữ liệu mẫu: $e');
    }
  }

  static Future<List<String>> _createDepartments() async {
    final departments = [
      {
        'name': 'Khoa Công nghệ Thông tin',
        'code': 'CNTT',
        'description': 'Khoa chuyên về Công nghệ Thông tin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Khoa Kinh tế',
        'code': 'KT',
        'description': 'Khoa chuyên về Kinh tế',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Khoa Ngoại ngữ',
        'code': 'NN',
        'description': 'Khoa chuyên về Ngoại ngữ',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> departmentIds = [];
    for (final dept in departments) {
      final docRef = await _firestore.collection('departments').add(dept);
      departmentIds.add(docRef.id);
    }
    return departmentIds;
  }

  static Future<List<String>> _createUsers(List<String> departmentIds) async {
    final users = [
      {
        'email': 'admin@tlu.edu.vn',
        'fullName': 'Admin System',
        'role': 'admin',
        'departmentId': departmentIds[0],
        'employeeId': 'EMP001',
        'academicRank': 'Giáo sư',
        'avatar': null,
        'specialization': 'Quản trị hệ thống',
        'phoneNumber': '0123456789',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'teacher1@tlu.edu.vn',
        'fullName': 'Nguyễn Văn A',
        'role': 'teacher',
        'departmentId': departmentIds[0],
        'employeeId': 'EMP002',
        'academicRank': 'Tiến sĩ',
        'avatar': null,
        'specialization': 'Lập trình Flutter',
        'phoneNumber': '0123456788',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'teacher2@tlu.edu.vn',
        'fullName': 'Trần Thị B',
        'role': 'teacher',
        'departmentId': departmentIds[0],
        'employeeId': 'EMP003',
        'academicRank': 'Thạc sĩ',
        'avatar': null,
        'specialization': 'Cơ sở dữ liệu',
        'phoneNumber': '0123456787',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> userIds = [];
    for (final user in users) {
      final docRef = await _firestore.collection('users').add(user);
      userIds.add(docRef.id);
    }
    return userIds;
  }

  static Future<List<String>> _createSubjects(List<String> departmentIds) async {
    final subjects = [
      {
        'name': 'Lập trình Flutter',
        'code': 'FLUTTER001',
        'departmentId': departmentIds[0],
        'credits': 3,
        'totalHours': 45,
        'description': 'Môn học về phát triển ứng dụng di động với Flutter',
        'prerequisites': ['DART001', 'MOBILE001'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Cơ sở dữ liệu',
        'code': 'DB001',
        'departmentId': departmentIds[0],
        'credits': 3,
        'totalHours': 45,
        'description': 'Môn học về thiết kế và quản lý cơ sở dữ liệu',
        'prerequisites': ['PROG001'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Lập trình Web',
        'code': 'WEB001',
        'departmentId': departmentIds[0],
        'credits': 3,
        'totalHours': 45,
        'description': 'Môn học về phát triển ứng dụng web',
        'prerequisites': ['HTML001', 'CSS001'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> subjectIds = [];
    for (final subject in subjects) {
      final docRef = await _firestore.collection('subjects').add(subject);
      subjectIds.add(docRef.id);
    }
    return subjectIds;
  }

  static Future<List<String>> _createRooms() async {
    final rooms = [
      {
        'name': 'Phòng Lab 101',
        'code': 'LAB101',
        'building': 'Tòa A',
        'capacity': 30,
        'type': 'lab',
        'floor': 1,
        'description': 'Phòng thực hành máy tính',
        'equipment': ['Máy tính', 'Máy chiếu', 'Bảng thông minh'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Phòng Học 201',
        'code': 'H201',
        'building': 'Tòa B',
        'capacity': 50,
        'type': 'lecture',
        'floor': 2,
        'description': 'Phòng học lý thuyết',
        'equipment': ['Máy chiếu', 'Bảng thông minh'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Phòng Hội thảo 301',
        'code': 'HT301',
        'building': 'Tòa C',
        'capacity': 20,
        'type': 'seminar',
        'floor': 3,
        'description': 'Phòng hội thảo nhỏ',
        'equipment': ['Máy chiếu', 'Bảng trắng'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> roomIds = [];
    for (final room in rooms) {
      final docRef = await _firestore.collection('rooms').add(room);
      roomIds.add(docRef.id);
    }
    return roomIds;
  }

  static Future<List<String>> _createClassrooms(List<String> departmentIds) async {
    final classrooms = [
      {
        'name': 'Lớp CNTT K66',
        'code': 'CNTT66',
        'departmentId': departmentIds[0],
        'academicYear': '2024-2025',
        'description': 'Lớp Công nghệ Thông tin khóa 66',
        'studentCount': 40,
        'semester': 'Học kỳ 1',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Lớp CNTT K67',
        'code': 'CNTT67',
        'departmentId': departmentIds[0],
        'academicYear': '2024-2025',
        'description': 'Lớp Công nghệ Thông tin khóa 67',
        'studentCount': 35,
        'semester': 'Học kỳ 1',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> classroomIds = [];
    for (final classroom in classrooms) {
      final docRef = await _firestore.collection('classrooms').add(classroom);
      classroomIds.add(docRef.id);
    }
    return classroomIds;
  }

  static Future<List<String>> _createStudents(List<String> classroomIds) async {
    final students = [
      {
        'email': 'student1@tlu.edu.vn',
        'fullName': 'Nguyễn Văn B',
        'studentId': 'SV001',
        'classroomId': classroomIds[0],
        'dateOfBirth': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'phoneNumber': '0123456787',
        'address': 'Hà Nội',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'student2@tlu.edu.vn',
        'fullName': 'Trần Thị C',
        'studentId': 'SV002',
        'classroomId': classroomIds[0],
        'dateOfBirth': Timestamp.fromDate(DateTime(2000, 2, 1)),
        'phoneNumber': '0123456786',
        'address': 'TP.HCM',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> studentIds = [];
    for (final student in students) {
      final docRef = await _firestore.collection('students').add(student);
      studentIds.add(docRef.id);
    }
    return studentIds;
  }

  static Future<List<String>> _createSemesters() async {
    final semesters = [
      {
        'name': 'Học kỳ 1 - 2024',
        'academicYear': '2024-2025',
        'startDate': Timestamp.fromDate(DateTime(2024, 9, 1)),
        'endDate': Timestamp.fromDate(DateTime(2024, 12, 31)),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Học kỳ 2 - 2024',
        'academicYear': '2024-2025',
        'startDate': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'endDate': Timestamp.fromDate(DateTime(2025, 4, 30)),
        'isActive': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> semesterIds = [];
    for (final semester in semesters) {
      final docRef = await _firestore.collection('semesters').add(semester);
      semesterIds.add(docRef.id);
    }
    return semesterIds;
  }

  static Future<List<String>> _createCourseSections(
    List<String> subjectIds,
    List<String> userIds,
    List<String> semesterIds,
    List<String> classroomIds,
    List<String> roomIds,
  ) async {
    final courseSections = [
      {
        'subjectId': subjectIds[0],
        'teacherId': userIds[1],
        'semesterId': semesterIds[0],
        'classroomId': classroomIds[0],
        'roomId': roomIds[0],
        'schedule': 'Thứ 2, 7:00-9:00',
        'maxStudents': 40,
        'currentStudents': 35,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'subjectId': subjectIds[1],
        'teacherId': userIds[2],
        'semesterId': semesterIds[0],
        'classroomId': classroomIds[1],
        'roomId': roomIds[1],
        'schedule': 'Thứ 3, 9:00-11:00',
        'maxStudents': 35,
        'currentStudents': 30,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> courseSectionIds = [];
    for (final section in courseSections) {
      final docRef = await _firestore.collection('courseSections').add(section);
      courseSectionIds.add(docRef.id);
    }
    return courseSectionIds;
  }

  static Future<List<String>> _createSchedules(List<String> courseSectionIds, List<String> roomIds) async {
    final schedules = [
      {
        'courseSectionId': courseSectionIds[0],
        'date': Timestamp.fromDate(DateTime(2024, 1, 15)),
        'startTime': Timestamp.fromDate(DateTime(2024, 1, 15, 7, 0)),
        'endTime': Timestamp.fromDate(DateTime(2024, 1, 15, 9, 0)),
        'roomId': roomIds[0],
        'status': 'scheduled',
        'notes': 'Buổi học đầu tiên',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'courseSectionId': courseSectionIds[1],
        'date': Timestamp.fromDate(DateTime(2024, 1, 16)),
        'startTime': Timestamp.fromDate(DateTime(2024, 1, 16, 9, 0)),
        'endTime': Timestamp.fromDate(DateTime(2024, 1, 16, 11, 0)),
        'roomId': roomIds[1],
        'status': 'scheduled',
        'notes': 'Buổi học thứ hai',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    final List<String> scheduleIds = [];
    for (final schedule in schedules) {
      final docRef = await _firestore.collection('schedules').add(schedule);
      scheduleIds.add(docRef.id);
    }
    return scheduleIds;
  }

  static Future<void> _createAttendance(List<String> scheduleIds, List<String> studentIds) async {
    for (final scheduleId in scheduleIds) {
      for (final studentId in studentIds) {
        final attendance = {
          'scheduleId': scheduleId,
          'studentId': studentId,
          'status': 'present',
          'timestamp': FieldValue.serverTimestamp(),
          'notes': 'Có mặt đúng giờ',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('attendance').add(attendance);
      }
    }
  }

  static Future<void> _createLeaveRequests(List<String> scheduleIds, List<String> userIds) async {
    for (final scheduleId in scheduleIds) {
      final leaveRequest = {
        'teacherId': userIds[1],
        'scheduleId': scheduleId,
        'reason': 'Nghỉ ốm',
        'status': 'pending',
        'approverId': null,
        'approvedDate': null,
        'approverNotes': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('leaveRequests').add(leaveRequest);
    }
  }

  static Future<void> _createMakeupRequests(List<String> scheduleIds, List<String> userIds) async {
    for (final scheduleId in scheduleIds) {
      final makeupRequest = {
        'teacherId': userIds[1],
        'originalScheduleId': scheduleId,
        'requestedDate': Timestamp.fromDate(DateTime(2024, 1, 20)),
        'requestedTime': Timestamp.fromDate(DateTime(2024, 1, 20, 7, 0)),
        'reason': 'Bù buổi học đã nghỉ',
        'status': 'pending',
        'approverId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('makeupRequests').add(makeupRequest);
    }
  }
}
