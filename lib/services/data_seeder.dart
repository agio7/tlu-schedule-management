import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class DataSeeder {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Seed users data
  static Future<void> seedUsers() async {
    try {
      final users = [
        {
          'email': 'admin@tlu.edu.vn',
          'fullName': 'Quản trị viên',
          'role': 'admin',
          'department': 'IT',
          'phone': '0123456789',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'email': 'teacher1@tlu.edu.vn',
          'fullName': 'Nguyễn Văn A',
          'role': 'teacher',
          'department': 'CNTT',
          'phone': '0123456780',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'email': 'teacher2@tlu.edu.vn',
          'fullName': 'Trần Thị B',
          'role': 'teacher',
          'department': 'CNPM',
          'phone': '0123456781',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var user in users) {
        await _firestore.collection('users').add(user);
      }
      print('Users seeded successfully');
    } catch (e) {
      print('Error seeding users: $e');
    }
  }

  // Seed departments data
  static Future<void> seedDepartments() async {
    try {
      final departments = [
        {
          'name': 'Khoa Công nghệ thông tin',
          'code': 'CNTT',
          'description': 'Khoa chuyên về công nghệ thông tin',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Khoa Công nghệ phần mềm',
          'code': 'CNPM',
          'description': 'Khoa chuyên về phát triển phần mềm',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Khoa Kỹ thuật máy tính',
          'code': 'KTMT',
          'description': 'Khoa chuyên về kỹ thuật máy tính',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var dept in departments) {
        await _firestore.collection('departments').add(dept);
      }
      print('Departments seeded successfully');
    } catch (e) {
      print('Error seeding departments: $e');
    }
  }

  // Seed subjects data
  static Future<void> seedSubjects() async {
    try {
      final subjects = [
        {
          'name': 'Phân tích thiết kế hệ thống',
          'code': 'PTTKHT',
          'credits': 3,
          'department': 'CNTT',
          'description': 'Môn học về phân tích và thiết kế hệ thống thông tin',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Công nghệ phần mềm',
          'code': 'CNPM',
          'credits': 3,
          'department': 'CNPM',
          'description': 'Môn học về quy trình phát triển phần mềm',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Lập trình web',
          'code': 'LTW',
          'credits': 3,
          'department': 'CNTT',
          'description': 'Môn học về lập trình ứng dụng web',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Cơ sở dữ liệu',
          'code': 'CSDL',
          'credits': 3,
          'department': 'CNTT',
          'description': 'Môn học về thiết kế và quản lý cơ sở dữ liệu',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var subject in subjects) {
        await _firestore.collection('subjects').add(subject);
      }
      print('Subjects seeded successfully');
    } catch (e) {
      print('Error seeding subjects: $e');
    }
  }

  // Seed classrooms data
  static Future<void> seedClassrooms() async {
    try {
      final classrooms = [
        {
          'name': 'CNPM-K14',
          'code': 'CNPM-K14',
          'year': 2024,
          'department': 'CNPM',
          'studentCount': 40,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'CNTT-K14',
          'code': 'CNTT-K14',
          'year': 2024,
          'department': 'CNTT',
          'studentCount': 35,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'CNPM-K15',
          'code': 'CNPM-K15',
          'year': 2025,
          'department': 'CNPM',
          'studentCount': 38,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'CNTT-K15',
          'code': 'CNTT-K15',
          'year': 2025,
          'department': 'CNTT',
          'studentCount': 42,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var classroom in classrooms) {
        await _firestore.collection('classrooms').add(classroom);
      }
      print('Classrooms seeded successfully');
    } catch (e) {
      print('Error seeding classrooms: $e');
    }
  }

  // Seed rooms data
  static Future<void> seedRooms() async {
    try {
      final rooms = [
        {
          'name': 'Phòng A107',
          'code': 'A107',
          'capacity': 50,
          'type': 'lecture',
          'building': 'Tòa A',
          'floor': 1,
          'equipment': ['Máy chiếu', 'Bảng trắng', 'Máy tính'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Phòng A108',
          'code': 'A108',
          'capacity': 45,
          'type': 'lecture',
          'building': 'Tòa A',
          'floor': 1,
          'equipment': ['Máy chiếu', 'Bảng trắng'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Phòng B203',
          'code': 'B203',
          'capacity': 60,
          'type': 'lecture',
          'building': 'Tòa B',
          'floor': 2,
          'equipment': ['Máy chiếu', 'Bảng trắng', 'Máy tính', 'Hệ thống âm thanh'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Phòng C202',
          'code': 'C202',
          'capacity': 40,
          'type': 'lab',
          'building': 'Tòa C',
          'floor': 2,
          'equipment': ['Máy tính', 'Máy chiếu', 'Bảng trắng'],
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var room in rooms) {
        await _firestore.collection('rooms').add(room);
      }
      print('Rooms seeded successfully');
    } catch (e) {
      print('Error seeding rooms: $e');
    }
  }

  // Seed lessons data
  static Future<void> seedLessons() async {
    try {
      final lessons = [
        {
          'subject': 'Phân tích thiết kế hệ thống',
          'className': 'CNPM-K14',
          'date': DateTime(2025, 1, 20, 7, 30),
          'startTime': '07:30',
          'endTime': '09:30',
          'room': 'A107',
          'status': 'completed',
          'sessionNumber': 1,
          'sessionTitle': 'Giới thiệu môn học',
          'content': 'Nội dung buổi học đầu tiên về phân tích thiết kế hệ thống',
          'attendanceList': ['SV001', 'SV002', 'SV003'],
          'isCompleted': true,
          'teacherId': 'teacher_001',
          'notes': 'Buổi học đầu tiên',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'subject': 'Công nghệ phần mềm',
          'className': 'CNTT-K14',
          'date': DateTime(2025, 1, 22, 13, 30),
          'startTime': '13:30',
          'endTime': '15:30',
          'room': 'B203',
          'status': 'upcoming',
          'sessionNumber': 2,
          'sessionTitle': 'Quy trình phát triển phần mềm',
          'content': 'Giới thiệu về các quy trình phát triển phần mềm',
          'attendanceList': [],
          'isCompleted': false,
          'teacherId': 'teacher_002',
          'notes': 'Buổi học thứ 2',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'subject': 'Lập trình web',
          'className': 'CNPM-K15',
          'date': DateTime(2025, 1, 25, 7, 30),
          'startTime': '07:30',
          'endTime': '09:30',
          'room': 'C202',
          'status': 'upcoming',
          'sessionNumber': 1,
          'sessionTitle': 'Giới thiệu HTML/CSS',
          'content': 'Học về HTML và CSS cơ bản',
          'attendanceList': [],
          'isCompleted': false,
          'teacherId': 'teacher_001',
          'notes': 'Buổi học đầu tiên',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var lesson in lessons) {
        await _firestore.collection('lessons').add(lesson);
      }
      print('Lessons seeded successfully');
    } catch (e) {
      print('Error seeding lessons: $e');
    }
  }

  // Seed leave requests data
  static Future<void> seedLeaveRequests() async {
    try {
      final leaveRequests = [
        {
          'lessonId': 'lesson_001',
          'type': 'leave',
          'reason': 'Ốm đau',
          'startTime': '07:30',
          'endTime': '09:30',
          'additionalNotes': 'Bị cảm cúm, không thể dạy được',
          'status': 'pending',
          'teacherId': 'teacher_001',
          'requestDate': DateTime.now(),
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'lessonId': 'lesson_002',
          'type': 'makeup',
          'reason': 'Công tác',
          'makeupDate': DateTime(2025, 1, 28, 7, 30),
          'startTime': '07:30',
          'endTime': '09:30',
          'additionalNotes': 'Dạy bù vào cuối tuần',
          'status': 'approved',
          'teacherId': 'teacher_002',
          'requestDate': DateTime.now().subtract(const Duration(days: 2)),
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var request in leaveRequests) {
        await _firestore.collection('leaveRequests').add(request);
      }
      print('Leave requests seeded successfully');
    } catch (e) {
      print('Error seeding leave requests: $e');
    }
  }

  // Seed all data
  static Future<void> seedAllData() async {
    try {
      print('Starting data seeding...');
      
      await seedUsers();
      await seedDepartments();
      await seedSubjects();
      await seedClassrooms();
      await seedRooms();
      await seedLessons();
      await seedLeaveRequests();
      
      print('All data seeded successfully!');
    } catch (e) {
      print('Error seeding all data: $e');
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      final collections = ['users', 'departments', 'subjects', 'classrooms', 'rooms', 'lessons', 'leaveRequests'];
      
      for (String collection in collections) {
        final QuerySnapshot snapshot = await _firestore.collection(collection).get();
        final WriteBatch batch = _firestore.batch();
        
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
        print('Cleared $collection collection');
      }
      
      print('All data cleared successfully!');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
