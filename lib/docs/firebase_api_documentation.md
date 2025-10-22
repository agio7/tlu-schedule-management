# Firebase API Documentation

## 🔐 Authentication APIs

### Sign In
```dart
// Method: AuthService.signInWithEmailAndPassword
// Parameters: email (String), password (String)
// Returns: Map<String, dynamic> with success status and user data
// Example:
final result = await AuthService.signInWithEmailAndPassword(
  email: 'admin@tlu.edu.vn',
  password: 'admin123',
);
```

### Sign Out
```dart
// Method: AuthService.signOut
// Parameters: None
// Returns: void
// Example:
await AuthService.signOut();
```

### Get Current User
```dart
// Method: AuthService.getCurrentFirebaseUser
// Parameters: None
// Returns: firebase.User?
// Example:
final user = AuthService.getCurrentFirebaseUser();
```

## 📊 Firestore APIs

### Users Collection
```dart
// Collection: users
// Document ID: Firebase Auth UID
// Fields:
// - email: String
// - fullName: String
// - role: String (admin, teacher, student)
// - departmentId: String?
// - employeeId: String?
// - academicRank: String?
// - avatar: String?
// - specialization: String?
// - phoneNumber: String?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Departments Collection
```dart
// Collection: departments
// Document ID: Auto-generated
// Fields:
// - name: String
// - description: String?
// - headId: String?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Subjects Collection
```dart
// Collection: subjects
// Document ID: Auto-generated
// Fields:
// - name: String
// - code: String
// - credits: int
// - departmentId: String
// - description: String?
// - prerequisites: List<String>?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Classrooms Collection
```dart
// Collection: classrooms
// Document ID: Auto-generated
// Fields:
// - name: String
// - capacity: int
// - departmentId: String
// - description: String?
// - studentCount: int?
// - semester: String?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Rooms Collection
```dart
// Collection: rooms
// Document ID: Auto-generated
// Fields:
// - name: String
// - capacity: int
// - type: String?
// - floor: int?
// - description: String?
// - equipment: List<String>?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Students Collection
```dart
// Collection: students
// Document ID: Auto-generated
// Fields:
// - studentId: String
// - fullName: String
// - email: String
// - departmentId: String
// - classroomId: String?
// - phoneNumber: String?
// - address: String?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Semesters Collection
```dart
// Collection: semesters
// Document ID: Auto-generated
// Fields:
// - name: String
// - startDate: Timestamp
// - endDate: Timestamp
// - isActive: bool
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### CourseSections Collection
```dart
// Collection: courseSections
// Document ID: Auto-generated
// Fields:
// - subjectId: String
// - teacherId: String
// - semesterId: String
// - classroomId: String?
// - schedule: Map<String, dynamic>
// - maxStudents: int
// - currentStudents: int
// - status: String (active, inactive, completed)
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Schedules Collection
```dart
// Collection: schedules
// Document ID: Auto-generated
// Fields:
// - courseSectionId: String
// - roomId: String
// - dayOfWeek: int (1-7)
// - startTime: String (HH:mm)
// - endTime: String (HH:mm)
// - semesterId: String
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### Attendance Collection
```dart
// Collection: attendance
// Document ID: Auto-generated
// Fields:
// - studentId: String
// - scheduleId: String
// - date: Timestamp
// - status: String (present, absent, late, excused)
// - notes: String?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### LeaveRequests Collection
```dart
// Collection: leaveRequests
// Document ID: Auto-generated
// Fields:
// - teacherId: String
// - scheduleId: String
// - reason: String
// - startDate: Timestamp
// - endDate: Timestamp
// - status: String (pending, approved, rejected)
// - approvedBy: String?
// - approvedAt: Timestamp?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

### MakeupRequests Collection
```dart
// Collection: makeupRequests
// Document ID: Auto-generated
// Fields:
// - teacherId: String
// - originalScheduleId: String
// - newScheduleId: String
// - reason: String
// - status: String (pending, approved, rejected)
// - approvedBy: String?
// - approvedAt: Timestamp?
// - createdAt: Timestamp
// - updatedAt: Timestamp
```

## 🔧 Service Methods

### AuthService
- `signInWithEmailAndPassword(email, password)`
- `signOut()`
- `getCurrentFirebaseUser()`
- `userStream`

### AdminService
- `getAllUsers()`
- `getAllDepartments()`
- `getAllSubjects()`
- `getAllClassrooms()`
- `getAllRooms()`
- `getAllStudents()`
- `getAllSemesters()`
- `getAllCourseSections()`
- `getAllSchedules()`
- `getAllAttendance()`
- `getAllLeaveRequests()`
- `getAllMakeupRequests()`

### UserService
- `getUserById(id)`
- `updateUser(id, data)`
- `deleteUser(id)`

### DepartmentService
- `createDepartment(data)`
- `updateDepartment(id, data)`
- `deleteDepartment(id)`

### SubjectService
- `createSubject(data)`
- `updateSubject(id, data)`
- `deleteSubject(id)`

### ClassroomService
- `createClassroom(data)`
- `updateClassroom(id, data)`
- `deleteClassroom(id)`

### RoomService
- `createRoom(data)`
- `updateRoom(id, data)`
- `deleteRoom(id)`

### StudentService
- `createStudent(data)`
- `updateStudent(id, data)`
- `deleteStudent(id)`

### SemesterService
- `createSemester(data)`
- `updateSemester(id, data)`
- `deleteSemester(id)`

### CourseSectionService
- `createCourseSection(data)`
- `updateCourseSection(id, data)`
- `deleteCourseSection(id)`

### ScheduleService
- `createSchedule(data)`
- `updateSchedule(id, data)`
- `deleteSchedule(id)`

### AttendanceService
- `createAttendance(data)`
- `updateAttendance(id, data)`
- `deleteAttendance(id)`

### LeaveRequestService
- `createLeaveRequest(data)`
- `updateLeaveRequestStatus(id, status, approvedBy)`
- `deleteLeaveRequest(id)`

### MakeupRequestService
- `createMakeupRequest(data)`
- `updateMakeupRequestStatus(id, status, approvedBy)`
- `deleteMakeupRequest(id)`

## 🧪 Testing Examples

### Test Authentication
```dart
// Test sign in
final result = await AuthService.signInWithEmailAndPassword(
  email: 'admin@tlu.edu.vn',
  password: 'admin123',
);
assert(result['success'] == true);
assert(result['user'] != null);
```

### Test Firestore Operations
```dart
// Test create department
final department = await DepartmentService.createDepartment({
  'name': 'Công nghệ thông tin',
  'description': 'Khoa CNTT',
});
assert(department != null);
assert(department.name == 'Công nghệ thông tin');
```

### Test CRUD Operations
```dart
// Test create, read, update, delete
final subject = await SubjectService.createSubject({
  'name': 'Lập trình Flutter',
  'code': 'FLUTTER001',
  'credits': 3,
  'departmentId': 'dept123',
});

final retrieved = await SubjectService.getSubjectById(subject.id);
assert(retrieved.name == 'Lập trình Flutter');

await SubjectService.updateSubject(subject.id, {
  'credits': 4,
});

await SubjectService.deleteSubject(subject.id);
```
