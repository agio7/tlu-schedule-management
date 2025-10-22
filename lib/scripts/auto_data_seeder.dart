import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/users.dart';
import '../models/departments.dart';
import '../models/subjects.dart';
import '../models/rooms.dart';
import '../models/classrooms.dart';
import '../models/students.dart';
import '../models/semesters.dart';
import '../models/course_sections.dart';
import '../models/schedules.dart';
import '../models/attendance.dart';
import '../models/leave_requests.dart';
import '../models/makeup_requests.dart';

class AutoDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedAllData() async {
    try {
      print('🌱 Bắt đầu seed dữ liệu...');

      // 1. Tạo Departments
      final departments = await _seedDepartments();
      print('✅ Đã tạo ${departments.length} departments');

      // 2. Tạo Users
      final users = await _seedUsers(departments);
      print('✅ Đã tạo ${users.length} users');

      // 3. Tạo Subjects
      final subjects = await _seedSubjects(departments);
      print('✅ Đã tạo ${subjects.length} subjects');

      // 4. Tạo Rooms
      final rooms = await _seedRooms();
      print('✅ Đã tạo ${rooms.length} rooms');

      // 5. Tạo Classrooms
      final classrooms = await _seedClassrooms(departments);
      print('✅ Đã tạo ${classrooms.length} classrooms');

      // 6. Tạo Students
      final students = await _seedStudents(classrooms);
      print('✅ Đã tạo ${students.length} students');

      // 7. Tạo Semesters
      final semesters = await _seedSemesters();
      print('✅ Đã tạo ${semesters.length} semesters');

      // 8. Tạo CourseSections
      final courseSections = await _seedCourseSections(subjects, users, semesters, classrooms, rooms);
      print('✅ Đã tạo ${courseSections.length} course sections');

      // 9. Tạo Schedules
      final schedules = await _seedSchedules(courseSections, rooms);
      print('✅ Đã tạo ${schedules.length} schedules');

      // 10. Tạo Attendance
      await _seedAttendance(schedules, students);
      print('✅ Đã tạo attendance records');

      // 11. Tạo LeaveRequests
      await _seedLeaveRequests(schedules, users);
      print('✅ Đã tạo leave requests');

      // 12. Tạo MakeupRequests
      await _seedMakeupRequests(schedules, users);
      print('✅ Đã tạo makeup requests');

      print('🎉 Hoàn thành seed dữ liệu!');
    } catch (e) {
      print('❌ Lỗi khi seed dữ liệu: $e');
    }
  }

  static Future<List<String>> _seedDepartments() async {
    final departments = [
      Departments(
        id: '',
        name: 'Khoa Công nghệ Thông tin',
        code: 'CNTT',
        description: 'Khoa chuyên về Công nghệ Thông tin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Departments(
        id: '',
        name: 'Khoa Kinh tế',
        code: 'KT',
        description: 'Khoa chuyên về Kinh tế',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> departmentIds = [];
    for (final dept in departments) {
      final docRef = await _firestore.collection('departments').add(dept.toJson());
      departmentIds.add(docRef.id);
    }
    return departmentIds;
  }

  static Future<List<String>> _seedUsers(List<String> departmentIds) async {
    final users = [
      Users(
        id: '',
        email: 'admin@tlu.edu.vn',
        fullName: 'Admin System',
        role: 'admin',
        departmentId: departmentIds[0],
        employeeId: 'EMP001',
        academicRank: 'Giáo sư',
        avatar: null,
        specialization: 'Quản trị hệ thống',
        phoneNumber: '0123456789',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Users(
        id: '',
        email: 'teacher1@tlu.edu.vn',
        fullName: 'Nguyễn Văn A',
        role: 'teacher',
        departmentId: departmentIds[0],
        employeeId: 'EMP002',
        academicRank: 'Tiến sĩ',
        avatar: null,
        specialization: 'Lập trình Flutter',
        phoneNumber: '0123456788',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> userIds = [];
    for (final user in users) {
      final docRef = await _firestore.collection('users').add(user.toJson());
      userIds.add(docRef.id);
    }
    return userIds;
  }

  static Future<List<String>> _seedSubjects(List<String> departmentIds) async {
    final subjects = [
      Subjects(
        id: '',
        name: 'Lập trình Flutter',
        code: 'FLUTTER001',
        departmentId: departmentIds[0],
        credits: 3,
        totalHours: 45,
        description: 'Môn học về phát triển ứng dụng di động với Flutter',
        prerequisites: ['DART001', 'MOBILE001'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Subjects(
        id: '',
        name: 'Cơ sở dữ liệu',
        code: 'DB001',
        departmentId: departmentIds[0],
        credits: 3,
        totalHours: 45,
        description: 'Môn học về thiết kế và quản lý cơ sở dữ liệu',
        prerequisites: ['PROG001'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> subjectIds = [];
    for (final subject in subjects) {
      final docRef = await _firestore.collection('subjects').add(subject.toJson());
      subjectIds.add(docRef.id);
    }
    return subjectIds;
  }

  static Future<List<String>> _seedRooms() async {
    final rooms = [
      Rooms(
        id: '',
        'Phòng Lab 101',
        'LAB101',
        'Tòa A',
        30,
        'lab',
        1,
        'Phòng thực hành máy tính',
        ['Máy tính', 'Máy chiếu', 'Bảng thông minh'],
        DateTime.now(),
        DateTime.now(),
      ),
      Rooms(
        id: '',
        'Phòng Học 201',
        'H201',
        'Tòa B',
        50,
        'lecture',
        2,
        'Phòng học lý thuyết',
        ['Máy chiếu', 'Bảng thông minh'],
        DateTime.now(),
        DateTime.now(),
      ),
    ];

    final List<String> roomIds = [];
    for (final room in rooms) {
      final docRef = await _firestore.collection('rooms').add(room.toJson());
      roomIds.add(docRef.id);
    }
    return roomIds;
  }

  static Future<List<String>> _seedClassrooms(List<String> departmentIds) async {
    final classrooms = [
      Classrooms(
        id: '',
        name: 'Lớp CNTT K66',
        code: 'CNTT66',
        departmentId: departmentIds[0],
        academicYear: '2024-2025',
        description: 'Lớp Công nghệ Thông tin khóa 66',
        studentCount: 40,
        semester: 'Học kỳ 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> classroomIds = [];
    for (final classroom in classrooms) {
      final docRef = await _firestore.collection('classrooms').add(classroom.toJson());
      classroomIds.add(docRef.id);
    }
    return classroomIds;
  }

  static Future<List<String>> _seedStudents(List<String> classroomIds) async {
    final students = [
      Students(
        id: '',
        email: 'student1@tlu.edu.vn',
        fullName: 'Nguyễn Văn B',
        studentId: 'SV001',
        classroomId: classroomIds[0],
        dateOfBirth: DateTime(2000, 1, 1),
        phoneNumber: '0123456787',
        address: 'Hà Nội',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> studentIds = [];
    for (final student in students) {
      final docRef = await _firestore.collection('students').add(student.toJson());
      studentIds.add(docRef.id);
    }
    return studentIds;
  }

  static Future<List<String>> _seedSemesters() async {
    final semesters = [
      Semesters(
        id: '',
        name: 'Học kỳ 1 - 2024',
        academicYear: '2024-2025',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> semesterIds = [];
    for (final semester in semesters) {
      final docRef = await _firestore.collection('semesters').add(semester.toJson());
      semesterIds.add(docRef.id);
    }
    return semesterIds;
  }

  static Future<List<String>> _seedCourseSections(
    List<String> subjectIds,
    List<String> userIds,
    List<String> semesterIds,
    List<String> classroomIds,
    List<String> roomIds,
  ) async {
    final courseSections = [
      CourseSections(
        id: '',
        subjectId: subjectIds[0],
        teacherId: userIds[1],
        semesterId: semesterIds[0],
        classroomId: classroomIds[0],
        roomId: roomIds[0],
        schedule: 'Thứ 2, 7:00-9:00',
        maxStudents: 40,
        currentStudents: 35,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> sectionIds = [];
    for (final section in courseSections) {
      final docRef = await _firestore.collection('courseSections').add(section.toJson());
      sectionIds.add(docRef.id);
    }
    return sectionIds;
  }

  static Future<List<String>> _seedSchedules(List<String> sectionIds, List<String> roomIds) async {
    final schedules = [
      Schedules(
        id: '',
        courseSectionId: sectionIds[0],
        date: DateTime(2024, 1, 15),
        startTime: DateTime(2024, 1, 15, 7, 0),
        endTime: DateTime(2024, 1, 15, 9, 0),
        roomId: roomIds[0],
        status: 'scheduled',
        notes: 'Buổi học đầu tiên',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final List<String> scheduleIds = [];
    for (final schedule in schedules) {
      final docRef = await _firestore.collection('schedules').add(schedule.toJson());
      scheduleIds.add(docRef.id);
    }
    return scheduleIds;
  }

  static Future<void> _seedAttendance(List<String> scheduleIds, List<String> studentIds) async {
    for (final scheduleId in scheduleIds) {
      for (final studentId in studentIds) {
        final attendance = Attendance(
          id: '',
          scheduleId: scheduleId,
          studentId: studentId,
          status: 'present',
          timestamp: DateTime.now(),
          notes: 'Có mặt đúng giờ',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('attendance').add(attendance.toJson());
      }
    }
  }

  static Future<void> _seedLeaveRequests(List<String> scheduleIds, List<String> userIds) async {
    for (final scheduleId in scheduleIds) {
      final leaveRequest = LeaveRequests(
        id: '',
        teacherId: userIds[1],
        scheduleId: scheduleId,
        reason: 'Nghỉ ốm',
        status: LeaveRequestStatus.pending,
        approverId: null,
        approvedDate: null,
        approverNotes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('leaveRequests').add(leaveRequest.toJson());
    }
  }

  static Future<void> _seedMakeupRequests(List<String> scheduleIds, List<String> userIds) async {
    for (final scheduleId in scheduleIds) {
      final makeupRequest = MakeupRequests(
        id: '',
        teacherId: userIds[1],
        originalScheduleId: scheduleId,
        requestedDate: DateTime(2024, 1, 20),
        requestedTime: DateTime(2024, 1, 20, 7, 0),
        reason: 'Bù buổi học đã nghỉ',
        status: MakeupRequestStatus.pending,
        approverId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('makeupRequests').add(makeupRequest.toJson());
    }
  }
}


