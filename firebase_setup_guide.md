# 🔥 HƯỚNG DẪN SETUP FIREBASE DATABASE

## 📋 **Bước 1: Tạo Collections trong Firestore**

### 1. **Collection: `users`**
```json
{
  "email": "admin@tlu.edu.vn",
  "fullName": "Admin System",
  "role": "admin",
  "departmentId": "dept001",
  "employeeId": "EMP001",
  "academicRank": "Giáo sư",
  "avatar": null,
  "specialization": "Quản trị hệ thống",
  "phoneNumber": "0123456789",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 2. **Collection: `departments`**
```json
{
  "name": "Khoa Công nghệ Thông tin",
  "code": "CNTT",
  "description": "Khoa chuyên về Công nghệ Thông tin",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 3. **Collection: `subjects`**
```json
{
  "name": "Lập trình Flutter",
  "code": "FLUTTER001",
  "departmentId": "dept001",
  "credits": 3,
  "totalHours": 45,
  "description": "Môn học về phát triển ứng dụng di động với Flutter",
  "prerequisites": ["DART001", "MOBILE001"],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 4. **Collection: `rooms`**
```json
{
  "name": "Phòng Lab 101",
  "code": "LAB101",
  "building": "Tòa A",
  "capacity": 30,
  "type": "lab",
  "floor": 1,
  "description": "Phòng thực hành máy tính",
  "equipment": ["Máy tính", "Máy chiếu", "Bảng thông minh"],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 5. **Collection: `classrooms`**
```json
{
  "name": "Lớp CNTT K66",
  "code": "CNTT66",
  "departmentId": "dept001",
  "academicYear": "2024-2025",
  "description": "Lớp Công nghệ Thông tin khóa 66",
  "studentCount": 40,
  "semester": "Học kỳ 1",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 6. **Collection: `students`**
```json
{
  "email": "student@tlu.edu.vn",
  "fullName": "Nguyễn Văn A",
  "studentId": "SV001",
  "classroomId": "class001",
  "dateOfBirth": "2000-01-01T00:00:00Z",
  "phoneNumber": "0123456789",
  "address": "Hà Nội",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 7. **Collection: `semesters`**
```json
{
  "name": "Học kỳ 1 - 2024",
  "academicYear": "2024-2025",
  "startDate": "2024-09-01T00:00:00Z",
  "endDate": "2024-12-31T00:00:00Z",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 8. **Collection: `courseSections`**
```json
{
  "subjectId": "subject001",
  "teacherId": "teacher001",
  "semesterId": "semester001",
  "classroomId": "class001",
  "roomId": "room001",
  "schedule": "Thứ 2, 7:00-9:00",
  "maxStudents": 40,
  "currentStudents": 35,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 9. **Collection: `schedules`**
```json
{
  "courseSectionId": "section001",
  "date": "2024-01-15T00:00:00Z",
  "startTime": "2024-01-15T07:00:00Z",
  "endTime": "2024-01-15T09:00:00Z",
  "roomId": "room001",
  "status": "scheduled",
  "notes": "Buổi học đầu tiên",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 10. **Collection: `attendance`**
```json
{
  "scheduleId": "schedule001",
  "studentId": "student001",
  "status": "present",
  "timestamp": "2024-01-15T07:30:00Z",
  "notes": "Có mặt đúng giờ",
  "createdAt": "2024-01-15T07:30:00Z",
  "updatedAt": "2024-01-15T07:30:00Z"
}
```

### 11. **Collection: `leaveRequests`**
```json
{
  "teacherId": "teacher001",
  "scheduleId": "schedule001",
  "reason": "Nghỉ ốm",
  "status": "pending",
  "approverId": null,
  "approvedDate": null,
  "approverNotes": null,
  "createdAt": "2024-01-15T00:00:00Z",
  "updatedAt": "2024-01-15T00:00:00Z"
}
```

### 12. **Collection: `makeupRequests`**
```json
{
  "teacherId": "teacher001",
  "originalScheduleId": "schedule001",
  "requestedDate": "2024-01-20T00:00:00Z",
  "requestedTime": "2024-01-20T07:00:00Z",
  "reason": "Bù buổi học đã nghỉ",
  "status": "pending",
  "approverId": null,
  "createdAt": "2024-01-15T00:00:00Z",
  "updatedAt": "2024-01-15T00:00:00Z"
}
```

## 🔧 **Bước 2: Cấu hình Firestore Security Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Departments collection
    match /departments/{departmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Subjects collection
    match /subjects/{subjectId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Rooms collection
    match /rooms/{roomId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Classrooms collection
    match /classrooms/{classroomId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Students collection
    match /students/{studentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Semesters collection
    match /semesters/{semesterId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // CourseSections collection
    match /courseSections/{sectionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Schedules collection
    match /schedules/{scheduleId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Attendance collection
    match /attendance/{attendanceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // LeaveRequests collection
    match /leaveRequests/{requestId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // MakeupRequests collection
    match /makeupRequests/{requestId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 🚀 **Bước 3: Tạo Indexes cho Firestore**

Tạo file `firestore.indexes.json`:
```json
{
  "indexes": [
    {
      "collectionGroup": "leaveRequests",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "role",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

## 📱 **Bước 4: Test App**

1. **Chạy app**: `flutter run`
2. **Đăng nhập**: Sử dụng email/password đã tạo trong Firebase Auth
3. **Kiểm tra dữ liệu**: Xem dữ liệu có hiển thị trong app không
4. **Test CRUD**: Thử thêm/sửa/xóa dữ liệu

## 🔍 **Bước 5: Debug nếu có lỗi**

1. **Kiểm tra Firebase Console**: Xem dữ liệu có được tạo không
2. **Kiểm tra Security Rules**: Đảm bảo rules cho phép đọc/ghi
3. **Kiểm tra Indexes**: Đảm bảo indexes đã được deploy
4. **Kiểm tra Authentication**: Đảm bảo user đã đăng nhập

## 📞 **Hỗ trợ**

Nếu gặp vấn đề, hãy:
1. Kiểm tra Firebase Console logs
2. Kiểm tra Flutter debug console
3. Kiểm tra Firestore Security Rules
4. Kiểm tra Authentication status


