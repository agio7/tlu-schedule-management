import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Script để tạo dữ liệu mẫu trong Firestore
class FirestoreDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Tạo dữ liệu mẫu cho users
  static Future<void> seedUsers() async {
    print('🌱 Đang tạo dữ liệu mẫu cho users...');
    
    final users = [
      {
        'email': 'admin@tlu.edu.vn',
        'fullName': 'Admin TLU',
        'role': 'admin',
        'departmentId': 'dept_001',
        'phoneNumber': '0123456789',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'teacher1@tlu.edu.vn',
        'fullName': 'Nguyễn Văn A',
        'role': 'teacher',
        'departmentId': 'dept_001',
        'phoneNumber': '0123456780',
        'employeeId': 'GV001',
        'specialization': 'Công nghệ thông tin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'teacher2@tlu.edu.vn',
        'fullName': 'Trần Thị B',
        'role': 'teacher',
        'departmentId': 'dept_001',
        'phoneNumber': '0123456781',
        'employeeId': 'GV002',
        'specialization': 'Khoa học máy tính',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'depthead1@tlu.edu.vn',
        'fullName': 'Lê Văn C',
        'role': 'department_head',
        'departmentId': 'dept_001',
        'phoneNumber': '0123456782',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var user in users) {
      await _firestore.collection('users').add(user);
      print('✅ Đã tạo user: ${user['email']}');
    }
  }

  // Tạo dữ liệu mẫu cho schedules
  static Future<void> seedSchedules() async {
    print('🌱 Đang tạo dữ liệu mẫu cho schedules...');
    
    final now = DateTime.now();
    final schedules = [
      {
        'subjectId': 'subj_001',
        'classroomId': 'class_001',
        'teacherId': 'teacher1@tlu.edu.vn',
        'roomId': 'room_001',
        'startTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 7))),
        'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 9))),
        'sessionNumber': 1,
        'content': 'Bài 1: Giới thiệu về lập trình',
        'status': 'scheduled',
        'notes': 'Buổi học đầu tiên',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'subjectId': 'subj_002',
        'classroomId': 'class_002',
        'teacherId': 'teacher2@tlu.edu.vn',
        'roomId': 'room_002',
        'startTime': Timestamp.fromDate(now.add(const Duration(days: 2, hours: 9))),
        'endTime': Timestamp.fromDate(now.add(const Duration(days: 2, hours: 11))),
        'sessionNumber': 2,
        'content': 'Bài 2: Cấu trúc dữ liệu',
        'status': 'scheduled',
        'notes': 'Buổi học thứ hai',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var schedule in schedules) {
      await _firestore.collection('schedules').add(schedule);
      print('✅ Đã tạo schedule: ${schedule['content']}');
    }
  }

  // Tạo dữ liệu mẫu cho leaveRequests
  static Future<void> seedLeaveRequests() async {
    print('🌱 Đang tạo dữ liệu mẫu cho leaveRequests...');
    
    final now = DateTime.now();
    final leaveRequests = [
      {
        'teacherId': 'teacher1@tlu.edu.vn',
        'scheduleId': 'schedule_001',
        'reason': 'Nghỉ ốm',
        'attachments': [],
        'status': 'pending',
        'requestDate': Timestamp.fromDate(now),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'teacherId': 'teacher2@tlu.edu.vn',
        'scheduleId': 'schedule_002',
        'reason': 'Họp khoa',
        'attachments': [],
        'status': 'approved',
        'requestDate': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'approvedDate': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'approverNotes': 'Đã duyệt bởi admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'teacherId': 'teacher1@tlu.edu.vn',
        'scheduleId': 'schedule_003',
        'reason': 'Công tác',
        'attachments': [],
        'status': 'rejected',
        'requestDate': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'approverNotes': 'Lịch bù trùng với lịch khác',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var request in leaveRequests) {
      // Tạo document với ID ngắn để tránh lỗi substring
      final docRef = await _firestore.collection('leaveRequests').add(request);
      print('✅ Đã tạo leaveRequest: ${request['reason']} với ID: ${docRef.id}');
    }
  }

  // Tạo dữ liệu mẫu cho các collection khác
  static Future<void> seedOtherCollections() async {
    print('🌱 Đang tạo dữ liệu mẫu cho các collection khác...');
    
    // Departments
    final departments = [
      {
        'name': 'Khoa Công nghệ thông tin',
        'code': 'CNTT',
        'description': 'Khoa chuyên về công nghệ thông tin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var dept in departments) {
      await _firestore.collection('departments').add(dept);
      print('✅ Đã tạo department: ${dept['name']}');
    }

    // Subjects
    final subjects = [
      {
        'name': 'Lập trình C++',
        'code': 'LTC001',
        'credits': 3,
        'departmentId': 'dept_001',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Cấu trúc dữ liệu',
        'code': 'CTDL001',
        'credits': 3,
        'departmentId': 'dept_001',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var subject in subjects) {
      await _firestore.collection('subjects').add(subject);
      print('✅ Đã tạo subject: ${subject['name']}');
    }

    // Classrooms
    final classrooms = [
      {
        'name': 'CNTT K66',
        'code': 'CNTT66',
        'departmentId': 'dept_001',
        'studentCount': 30,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'CNTT K67',
        'code': 'CNTT67',
        'departmentId': 'dept_001',
        'studentCount': 28,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var classroom in classrooms) {
      await _firestore.collection('classrooms').add(classroom);
      print('✅ Đã tạo classroom: ${classroom['name']}');
    }

    // Rooms
    final rooms = [
      {
        'name': 'Phòng A101',
        'code': 'A101',
        'capacity': 50,
        'type': 'lecture',
        'equipment': ['Projector', 'Whiteboard'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Phòng A102',
        'code': 'A102',
        'capacity': 40,
        'type': 'lab',
        'equipment': ['Computers', 'Projector'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var room in rooms) {
      await _firestore.collection('rooms').add(room);
      print('✅ Đã tạo room: ${room['name']}');
    }
  }

  // Chạy tất cả seed functions
  static Future<void> seedAllData() async {
    try {
      print('🚀 Bắt đầu tạo dữ liệu mẫu...');
      
      await seedUsers();
      await seedSchedules();
      await seedLeaveRequests();
      await seedOtherCollections();
      
      print('🎉 Hoàn thành tạo dữ liệu mẫu!');
    } catch (e) {
      print('❌ Lỗi khi tạo dữ liệu mẫu: $e');
    }
  }
}

// Hàm main để chạy script
Future<void> main() async {
  await FirestoreDataSeeder.initializeFirebase();
  await FirestoreDataSeeder.seedAllData();
}
