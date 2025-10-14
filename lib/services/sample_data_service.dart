import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/department.dart';
import '../models/subject.dart';
import '../models/classroom.dart';
import '../models/room.dart';
import '../models/schedule.dart';
import 'database_service.dart';

class SampleDataService {
  static Future<void> createSampleData() async {
    print('🚀 Bắt đầu tạo dữ liệu mẫu...');

    // 1. Tạo Departments
    await _createDepartments();
    
    // 2. Tạo Users
    await _createUsers();
    
    // 3. Tạo Subjects
    await _createSubjects();
    
    // 4. Tạo Classrooms
    await _createClassrooms();
    
    // 5. Tạo Rooms
    await _createRooms();
    
    // 6. Tạo Schedules
    await _createSchedules();

    print('✅ Hoàn thành tạo dữ liệu mẫu!');
  }

  static Future<void> _createDepartments() async {
    final departments = [
      Department(
        id: 'dept_001',
        name: 'Khoa Công nghệ Thông tin',
        code: 'CNTT',
        description: 'Khoa Công nghệ Thông tin - Trường Đại học Thủy lợi',
        headId: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Department(
        id: 'dept_002',
        name: 'Khoa Kỹ thuật Xây dựng',
        code: 'KTXD',
        description: 'Khoa Kỹ thuật Xây dựng - Trường Đại học Thủy lợi',
        headId: 'user_002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Department(
        id: 'dept_003',
        name: 'Khoa Kinh tế',
        code: 'KT',
        description: 'Khoa Kinh tế - Trường Đại học Thủy lợi',
        headId: 'user_003',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var dept in departments) {
      await DatabaseService.createDepartment(dept);
    }
    print('✅ Đã tạo ${departments.length} departments');
  }

  static Future<void> _createUsers() async {
    final users = [
      User(
        id: 'user_001',
        email: 'admin@tlu.edu.vn',
        fullName: 'Nguyễn Văn Admin',
        role: 'admin',
        departmentId: 'dept_001',
        phoneNumber: '0123456789',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      User(
        id: 'user_002',
        email: 'head.cntt@tlu.edu.vn',
        fullName: 'Trần Thị Trưởng Khoa CNTT',
        role: 'department_head',
        departmentId: 'dept_001',
        phoneNumber: '0123456790',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      User(
        id: 'user_003',
        email: 'teacher1@tlu.edu.vn',
        fullName: 'Lê Văn Giảng Viên 1',
        role: 'teacher',
        departmentId: 'dept_001',
        phoneNumber: '0123456791',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      User(
        id: 'user_004',
        email: 'teacher2@tlu.edu.vn',
        fullName: 'Phạm Thị Giảng Viên 2',
        role: 'teacher',
        departmentId: 'dept_001',
        phoneNumber: '0123456792',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var user in users) {
      await DatabaseService.createUser(user);
    }
    print('✅ Đã tạo ${users.length} users');
  }

  static Future<void> _createSubjects() async {
    final subjects = [
      Subject(
        id: 'subj_001',
        name: 'Lập trình Flutter',
        code: 'FLUTTER001',
        departmentId: 'dept_001',
        credits: 3,
        totalHours: 45,
        description: 'Môn học lập trình ứng dụng di động với Flutter',
        prerequisites: 'Lập trình Java',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Subject(
        id: 'subj_002',
        name: 'Cơ sở dữ liệu',
        code: 'CSDL001',
        departmentId: 'dept_001',
        credits: 3,
        totalHours: 45,
        description: 'Môn học về thiết kế và quản lý cơ sở dữ liệu',
        prerequisites: 'Tin học cơ sở',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Subject(
        id: 'subj_003',
        name: 'Phát triển Web',
        code: 'WEB001',
        departmentId: 'dept_001',
        credits: 3,
        totalHours: 45,
        description: 'Môn học phát triển ứng dụng web',
        prerequisites: 'HTML, CSS, JavaScript',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var subject in subjects) {
      await DatabaseService.createSubject(subject);
    }
    print('✅ Đã tạo ${subjects.length} subjects');
  }

  static Future<void> _createClassrooms() async {
    final classrooms = [
      Classroom(
        id: 'class_001',
        name: 'Lớp CNTT K66',
        code: 'CNTT66',
        departmentId: 'dept_001',
        year: 2024,
        semester: 'Học kỳ 1',
        studentCount: 45,
        description: 'Lớp Công nghệ Thông tin khóa 66',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Classroom(
        id: 'class_002',
        name: 'Lớp CNTT K67',
        code: 'CNTT67',
        departmentId: 'dept_001',
        year: 2024,
        semester: 'Học kỳ 1',
        studentCount: 42,
        description: 'Lớp Công nghệ Thông tin khóa 67',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var classroom in classrooms) {
      await DatabaseService.createClassroom(classroom);
    }
    print('✅ Đã tạo ${classrooms.length} classrooms');
  }

  static Future<void> _createRooms() async {
    final rooms = [
      Room(
        id: 'room_001',
        name: 'Phòng A101',
        code: 'A101',
        building: 'Tòa A',
        capacity: 50,
        type: 'lecture',
        equipment: ['Máy chiếu', 'Bảng trắng', 'Micro'],
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Room(
        id: 'room_002',
        name: 'Phòng Lab B201',
        code: 'B201',
        building: 'Tòa B',
        capacity: 30,
        type: 'lab',
        equipment: ['Máy tính', 'Máy chiếu', 'Bảng trắng'],
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Room(
        id: 'room_003',
        name: 'Phòng C301',
        code: 'C301',
        building: 'Tòa C',
        capacity: 40,
        type: 'lecture',
        equipment: ['Máy chiếu', 'Bảng trắng'],
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var room in rooms) {
      await DatabaseService.createRoom(room);
    }
    print('✅ Đã tạo ${rooms.length} rooms');
  }

  static Future<void> _createSchedules() async {
    final now = DateTime.now();
    final schedules = [
      Schedule(
        id: 'sched_001',
        subjectId: 'subj_001',
        classroomId: 'class_001',
        teacherId: 'user_003',
        roomId: 'room_001',
        startTime: DateTime(now.year, now.month, now.day + 1, 8, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        sessionNumber: 1,
        content: 'Giới thiệu Flutter và Dart',
        status: ScheduleStatus.scheduled,
        notes: 'Buổi học đầu tiên',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Schedule(
        id: 'sched_002',
        subjectId: 'subj_001',
        classroomId: 'class_001',
        teacherId: 'user_003',
        roomId: 'room_002',
        startTime: DateTime(now.year, now.month, now.day + 3, 8, 0),
        endTime: DateTime(now.year, now.month, now.day + 3, 10, 0),
        sessionNumber: 2,
        content: 'Widget và Layout trong Flutter',
        status: ScheduleStatus.scheduled,
        notes: 'Thực hành lab',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Schedule(
        id: 'sched_003',
        subjectId: 'subj_002',
        classroomId: 'class_002',
        teacherId: 'user_004',
        roomId: 'room_003',
        startTime: DateTime(now.year, now.month, now.day + 2, 14, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 16, 0),
        sessionNumber: 1,
        content: 'Giới thiệu Cơ sở dữ liệu',
        status: ScheduleStatus.scheduled,
        notes: 'Lý thuyết',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var schedule in schedules) {
      await DatabaseService.createSchedule(schedule);
    }
    print('✅ Đã tạo ${schedules.length} schedules');
  }
}
