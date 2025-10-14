import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/department.dart';
import '../models/subject.dart';
import '../models/classroom.dart';
import '../models/room.dart';
import '../models/schedule.dart';
import '../models/attendance.dart';
import '../models/leave_request.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== USERS ==========
  static Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  static Future<User?> getUser(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<User>> getUsers() {
    return _firestore.collection('users').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => User.fromJson(doc.data()),
      ).toList(),
    );
  }

  // ========== DEPARTMENTS ==========
  static Future<void> createDepartment(Department department) async {
    await _firestore.collection('departments').doc(department.id).set(department.toJson());
  }

  static Future<Department?> getDepartment(String departmentId) async {
    DocumentSnapshot doc = await _firestore.collection('departments').doc(departmentId).get();
    if (doc.exists) {
      return Department.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<Department>> getDepartments() {
    return _firestore.collection('departments').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => Department.fromJson(doc.data()),
      ).toList(),
    );
  }

  // ========== SUBJECTS ==========
  static Future<void> createSubject(Subject subject) async {
    await _firestore.collection('subjects').doc(subject.id).set(subject.toJson());
  }

  static Future<Subject?> getSubject(String subjectId) async {
    DocumentSnapshot doc = await _firestore.collection('subjects').doc(subjectId).get();
    if (doc.exists) {
      return Subject.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<Subject>> getSubjects() {
    return _firestore.collection('subjects').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => Subject.fromJson(doc.data()),
      ).toList(),
    );
  }

  // ========== CLASSROOMS ==========
  static Future<void> createClassroom(Classroom classroom) async {
    await _firestore.collection('classrooms').doc(classroom.id).set(classroom.toJson());
  }

  static Future<Classroom?> getClassroom(String classroomId) async {
    DocumentSnapshot doc = await _firestore.collection('classrooms').doc(classroomId).get();
    if (doc.exists) {
      return Classroom.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<Classroom>> getClassrooms() {
    return _firestore.collection('classrooms').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => Classroom.fromJson(doc.data()),
      ).toList(),
    );
  }

  // ========== ROOMS ==========
  static Future<void> createRoom(Room room) async {
    await _firestore.collection('rooms').doc(room.id).set(room.toJson());
  }

  static Future<Room?> getRoom(String roomId) async {
    DocumentSnapshot doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      return Room.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<Room>> getRooms() {
    return _firestore.collection('rooms').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => Room.fromJson(doc.data()),
      ).toList(),
    );
  }

  // ========== SCHEDULES ==========
  static Future<void> createSchedule(Schedule schedule) async {
    await _firestore.collection('schedules').doc(schedule.id).set(schedule.toJson());
  }

  static Future<Schedule?> getSchedule(String scheduleId) async {
    DocumentSnapshot doc = await _firestore.collection('schedules').doc(scheduleId).get();
    if (doc.exists) {
      return Schedule.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<Schedule>> getSchedules() {
    return _firestore.collection('schedules').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => Schedule.fromJson(doc.data()),
      ).toList(),
    );
  }

  static Stream<List<Schedule>> getSchedulesByTeacher(String teacherId) {
    return _firestore
        .collection('schedules')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(
            (doc) => Schedule.fromJson(doc.data()),
          ).toList(),
        );
  }

  // ========== ATTENDANCE ==========
  static Future<void> createAttendance(Attendance attendance) async {
    await _firestore.collection('attendance').doc(attendance.id).set(attendance.toJson());
  }

  static Future<Attendance?> getAttendance(String attendanceId) async {
    DocumentSnapshot doc = await _firestore.collection('attendance').doc(attendanceId).get();
    if (doc.exists) {
      return Attendance.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<Attendance>> getAttendanceBySchedule(String scheduleId) {
    return _firestore
        .collection('attendance')
        .where('scheduleId', isEqualTo: scheduleId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(
            (doc) => Attendance.fromJson(doc.data()),
          ).toList(),
        );
  }

  // ========== LEAVE REQUESTS ==========
  static Future<void> createLeaveRequest(LeaveRequest leaveRequest) async {
    await _firestore.collection('leaveRequests').doc(leaveRequest.id).set(leaveRequest.toJson());
  }

  static Future<LeaveRequest?> getLeaveRequest(String leaveRequestId) async {
    DocumentSnapshot doc = await _firestore.collection('leaveRequests').doc(leaveRequestId).get();
    if (doc.exists) {
      return LeaveRequest.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  static Stream<List<LeaveRequest>> getLeaveRequests() {
    return _firestore.collection('leaveRequests').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => LeaveRequest.fromJson(doc.data()),
      ).toList(),
    );
  }

  static Stream<List<LeaveRequest>> getLeaveRequestsByTeacher(String teacherId) {
    return _firestore
        .collection('leaveRequests')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(
            (doc) => LeaveRequest.fromJson(doc.data()),
          ).toList(),
        );
  }
}
