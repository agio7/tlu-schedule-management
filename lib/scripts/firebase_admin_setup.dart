import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAdminSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Tạo admin user và setup dữ liệu mẫu
  static Future<void> setupAdminAndData() async {
    try {
      print('🔧 Bắt đầu setup Firebase Admin...');

      // 1. Tạo admin user trong Firebase Auth
      await _createAdminUser();

      // 2. Tạo admin user trong Firestore
      await _createAdminUserInFirestore();

      // 3. Tạo dữ liệu mẫu
      await _createSampleData();

      print('✅ Setup Firebase Admin hoàn tất!');
    } catch (e) {
      print('❌ Lỗi setup Firebase Admin: $e');
    }
  }

  /// Tạo admin user trong Firebase Auth
  static Future<void> _createAdminUser() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'admin@tlu.edu.vn',
        password: 'admin123',
      );
      
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName('Admin System');
        print('✅ Đã tạo admin user trong Firebase Auth');
      }
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('⚠️ Admin user đã tồn tại trong Firebase Auth');
      } else {
        print('❌ Lỗi tạo admin user: $e');
      }
    }
  }

  /// Tạo admin user trong Firestore
  static Future<void> _createAdminUserInFirestore() async {
    try {
      final adminUser = {
        'email': 'admin@tlu.edu.vn',
        'fullName': 'Admin System',
        'role': 'admin',
        'departmentId': 'dept001',
        'employeeId': 'EMP001',
        'academicRank': 'Giáo sư',
        'avatar': null,
        'specialization': 'Quản trị hệ thống',
        'phoneNumber': '0123456789',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc('admin001').set(adminUser);
      print('✅ Đã tạo admin user trong Firestore');
    } catch (e) {
      print('❌ Lỗi tạo admin user trong Firestore: $e');
    }
  }

  /// Tạo dữ liệu mẫu
  static Future<void> _createSampleData() async {
    try {
      // Tạo departments
      await _createDepartments();
      
      // Tạo subjects
      await _createSubjects();
      
      // Tạo rooms
      await _createRooms();
      
      // Tạo classrooms
      await _createClassrooms();
      
      // Tạo students
      await _createStudents();
      
      // Tạo semesters
      await _createSemesters();
      
      // Tạo course sections
      await _createCourseSections();
      
      // Tạo schedules
      await _createSchedules();
      
      // Tạo attendance
      await _createAttendance();
      
      // Tạo leave requests
      await _createLeaveRequests();
      
      // Tạo makeup requests
      await _createMakeupRequests();
      
      print('✅ Đã tạo tất cả dữ liệu mẫu');
    } catch (e) {
      print('❌ Lỗi tạo dữ liệu mẫu: $e');
    }
  }

  static Future<void> _createDepartments() async {
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
    ];

    for (final dept in departments) {
      await _firestore.collection('departments').add(dept);
    }
  }

  static Future<void> _createSubjects() async {
    final subjects = [
      {
        'name': 'Lập trình Flutter',
        'code': 'FLUTTER001',
        'departmentId': 'dept001',
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
        'departmentId': 'dept001',
        'credits': 3,
        'totalHours': 45,
        'description': 'Môn học về thiết kế và quản lý cơ sở dữ liệu',
        'prerequisites': ['PROG001'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final subject in subjects) {
      await _firestore.collection('subjects').add(subject);
    }
  }

  static Future<void> _createRooms() async {
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
    ];

    for (final room in rooms) {
      await _firestore.collection('rooms').add(room);
    }
  }

  static Future<void> _createClassrooms() async {
    final classrooms = [
      {
        'name': 'Lớp CNTT K66',
        'code': 'CNTT66',
        'departmentId': 'dept001',
        'academicYear': '2024-2025',
        'description': 'Lớp Công nghệ Thông tin khóa 66',
        'studentCount': 40,
        'semester': 'Học kỳ 1',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final classroom in classrooms) {
      await _firestore.collection('classrooms').add(classroom);
    }
  }

  static Future<void> _createStudents() async {
    final students = [
      {
        'email': 'student1@tlu.edu.vn',
        'fullName': 'Nguyễn Văn B',
        'studentId': 'SV001',
        'classroomId': 'class001',
        'dateOfBirth': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'phoneNumber': '0123456787',
        'address': 'Hà Nội',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final student in students) {
      await _firestore.collection('students').add(student);
    }
  }

  static Future<void> _createSemesters() async {
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
    ];

    for (final semester in semesters) {
      await _firestore.collection('semesters').add(semester);
    }
  }

  static Future<void> _createCourseSections() async {
    final courseSections = [
      {
        'subjectId': 'subject001',
        'teacherId': 'teacher001',
        'semesterId': 'semester001',
        'classroomId': 'class001',
        'roomId': 'room001',
        'schedule': 'Thứ 2, 7:00-9:00',
        'maxStudents': 40,
        'currentStudents': 35,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final section in courseSections) {
      await _firestore.collection('courseSections').add(section);
    }
  }

  static Future<void> _createSchedules() async {
    final schedules = [
      {
        'courseSectionId': 'section001',
        'date': Timestamp.fromDate(DateTime(2024, 1, 15)),
        'startTime': Timestamp.fromDate(DateTime(2024, 1, 15, 7, 0)),
        'endTime': Timestamp.fromDate(DateTime(2024, 1, 15, 9, 0)),
        'roomId': 'room001',
        'status': 'scheduled',
        'notes': 'Buổi học đầu tiên',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final schedule in schedules) {
      await _firestore.collection('schedules').add(schedule);
    }
  }

  static Future<void> _createAttendance() async {
    final attendance = {
      'scheduleId': 'schedule001',
      'studentId': 'student001',
      'status': 'present',
      'timestamp': FieldValue.serverTimestamp(),
      'notes': 'Có mặt đúng giờ',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('attendance').add(attendance);
  }

  static Future<void> _createLeaveRequests() async {
    final leaveRequest = {
      'teacherId': 'teacher001',
      'scheduleId': 'schedule001',
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

  static Future<void> _createMakeupRequests() async {
    final makeupRequest = {
      'teacherId': 'teacher001',
      'originalScheduleId': 'schedule001',
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


