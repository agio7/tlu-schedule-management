# Hướng dẫn tạo dữ liệu mẫu từ Firebase Console

## Cách 1: Tạo dữ liệu trực tiếp từ Firebase Console

### Bước 1: Truy cập Firebase Console
1. Mở trình duyệt và truy cập: https://console.firebase.google.com/
2. Chọn project `tlu-schedule-management`
3. Vào **Firestore Database**

### Bước 2: Tạo collection `leaveRequests`

1. **Tạo collection mới:**
   - Click **"Start collection"**
   - Collection ID: `leaveRequests`

2. **Tạo document đầu tiên:**
   - Document ID: `req001` (để tránh lỗi substring)
   - Fields:
     ```
     teacherId: "teacher1@tlu.edu.vn"
     scheduleId: "schedule_001"
     reason: "Nghỉ ốm"
     attachments: [] (array, empty)
     status: "pending"
     requestDate: [Timestamp] (chọn ngày hiện tại)
     createdAt: [Timestamp] (chọn ngày hiện tại)
     updatedAt: [Timestamp] (chọn ngày hiện tại)
     ```

3. **Tạo document thứ hai:**
   - Document ID: `req002`
   - Fields:
     ```
     teacherId: "teacher2@tlu.edu.vn"
     scheduleId: "schedule_002"
     reason: "Họp khoa"
     attachments: [] (array, empty)
     status: "approved"
     requestDate: [Timestamp] (chọn ngày hôm qua)
     approvedDate: [Timestamp] (chọn ngày hôm qua)
     approverNotes: "Đã duyệt bởi admin"
     createdAt: [Timestamp] (chọn ngày hôm qua)
     updatedAt: [Timestamp] (chọn ngày hôm qua)
     ```

4. **Tạo document thứ ba:**
   - Document ID: `req003`
   - Fields:
     ```
     teacherId: "teacher1@tlu.edu.vn"
     scheduleId: "schedule_003"
     reason: "Công tác"
     attachments: [] (array, empty)
     status: "rejected"
     requestDate: [Timestamp] (chọn ngày hôm kia)
     approverNotes: "Lịch bù trùng với lịch khác"
     createdAt: [Timestamp] (chọn ngày hôm kia)
     updatedAt: [Timestamp] (chọn ngày hôm kia)
     ```

### Bước 3: Tạo collection `users` (nếu chưa có)

1. **Tạo collection `users`:**
   - Collection ID: `users`

2. **Tạo document cho admin:**
   - Document ID: `admin001`
   - Fields:
     ```
     email: "admin@tlu.edu.vn"
     fullName: "Admin TLU"
     role: "admin"
     departmentId: "dept_001"
     phoneNumber: "0123456789"
     createdAt: [Timestamp] (ngày hiện tại)
     updatedAt: [Timestamp] (ngày hiện tại)
     ```

3. **Tạo document cho teacher:**
   - Document ID: `teacher001`
   - Fields:
     ```
     email: "teacher1@tlu.edu.vn"
     fullName: "Nguyễn Văn A"
     role: "teacher"
     departmentId: "dept_001"
     phoneNumber: "0123456780"
     employeeId: "GV001"
     specialization: "Công nghệ thông tin"
     createdAt: [Timestamp] (ngày hiện tại)
     updatedAt: [Timestamp] (ngày hiện tại)
     ```

### Bước 4: Tạo các collection khác (tùy chọn)

1. **Collection `schedules`:**
   - Document ID: `sched001`
   - Fields:
     ```
     subjectId: "subj_001"
     classroomId: "class_001"
     teacherId: "teacher1@tlu.edu.vn"
     roomId: "room_001"
     startTime: [Timestamp] (ngày mai, 7:00)
     endTime: [Timestamp] (ngày mai, 9:00)
     sessionNumber: 1
     content: "Bài 1: Giới thiệu về lập trình"
     status: "scheduled"
     notes: "Buổi học đầu tiên"
     createdAt: [Timestamp] (ngày hiện tại)
     updatedAt: [Timestamp] (ngày hiện tại)
     ```

2. **Collection `departments`:**
   - Document ID: `dept001`
   - Fields:
     ```
     name: "Khoa Công nghệ thông tin"
     code: "CNTT"
     description: "Khoa chuyên về công nghệ thông tin"
     createdAt: [Timestamp] (ngày hiện tại)
     updatedAt: [Timestamp] (ngày hiện tại)
     ```

3. **Collection `subjects`:**
   - Document ID: `subj001`
   - Fields:
     ```
     name: "Lập trình C++"
     code: "LTC001"
     credits: 3
     departmentId: "dept_001"
     createdAt: [Timestamp] (ngày hiện tại)
     updatedAt: [Timestamp] (ngày hiện tại)
     ```

4. **Collection `classrooms`:**
   - Document ID: `class001`
   - Fields:
     ```
     name: "CNTT K66"
     code: "CNTT66"
     departmentId: "dept_001"
     studentCount: 30
     createdAt: [Timestamp] (ngày hiện tại)
     updatedAt: [Timestamp] (ngày hiện tại)
     ```

5. **Collection `rooms`:**
   - Document ID: `room001`
   - Fields:
     ```
     name: "Phòng A101"
     code: "A101"
     capacity: 50
     type: "lecture"
     equipment: ["Projector", "Whiteboard"] (array)
     createdAt: [Timestamp] (ngày hiện tại)
     updatedAt: [Timestamp] (ngày hiện tại)
     ```

## Cách 2: Sử dụng Firebase CLI (nếu có)

```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Login vào Firebase
firebase login

# Khởi tạo project
firebase init firestore

# Tạo file firestore.rules và firestore.indexes.json
# Sau đó deploy
firebase deploy --only firestore
```

## Lưu ý quan trọng

1. **Document ID**: Sử dụng ID ngắn (3-8 ký tự) để tránh lỗi substring
2. **Timestamp**: Luôn sử dụng Timestamp type trong Firebase Console
3. **Array**: Sử dụng Array type cho các field như `attachments`, `equipment`
4. **String**: Sử dụng String type cho text
5. **Number**: Sử dụng Number type cho số

## Kiểm tra dữ liệu

Sau khi tạo xong, bạn có thể:
1. Chạy ứng dụng Flutter
2. Đăng nhập với `admin@tlu.edu.vn`
3. Kiểm tra admin dashboard để xem dữ liệu thật

## Troubleshooting

- **Lỗi "Permission denied"**: Kiểm tra Firestore Security Rules
- **Lỗi "Index required"**: Tạo index trong Firebase Console hoặc sử dụng query đơn giản hơn
- **Lỗi "RangeError"**: Đảm bảo Document ID có ít nhất 8 ký tự hoặc sửa code substring

