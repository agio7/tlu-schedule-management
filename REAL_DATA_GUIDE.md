# Hướng dẫn sử dụng dữ liệu thật từ Firestore

## Tổng quan

Hệ thống admin dashboard đã được cập nhật để sử dụng dữ liệu thật từ Firestore thay vì dữ liệu mô phỏng. Tất cả các màn hình admin sẽ hiển thị dữ liệu thực từ database.

## Cấu trúc dữ liệu

### Collections trong Firestore:

1. **users** - Thông tin người dùng
   - `email`: Email đăng nhập
   - `fullName`: Họ tên đầy đủ
   - `role`: Vai trò (admin, teacher, department_head)
   - `departmentId`: ID khoa/phòng ban
   - `phoneNumber`: Số điện thoại
   - `employeeId`: Mã số giảng viên (cho teacher)
   - `specialization`: Chuyên ngành (cho teacher)

2. **schedules** - Lịch trình giảng dạy
   - `subjectId`: ID môn học
   - `classroomId`: ID lớp học
   - `teacherId`: ID giảng viên
   - `roomId`: ID phòng học
   - `startTime`: Thời gian bắt đầu
   - `endTime`: Thời gian kết thúc
   - `sessionNumber`: Số thứ tự buổi học
   - `content`: Nội dung buổi học
   - `status`: Trạng thái (scheduled, completed, cancelled, makeUp)

3. **leaveRequests** - Yêu cầu nghỉ phép
   - `teacherId`: ID giảng viên
   - `scheduleId`: ID lịch trình
   - `reason`: Lý do nghỉ
   - `attachments`: Danh sách file đính kèm
   - `status`: Trạng thái (pending, approved, rejected, cancelled)
   - `approverId`: ID người duyệt
   - `approverNotes`: Ghi chú của người duyệt
   - `requestDate`: Ngày yêu cầu
   - `approvedDate`: Ngày duyệt

4. **departments** - Khoa/phòng ban
5. **subjects** - Môn học
6. **classrooms** - Lớp học
7. **rooms** - Phòng học

## Cách tạo dữ liệu mẫu

### Sử dụng script tự động:

```bash
# Chạy script tạo dữ liệu mẫu
dart lib/scripts/firestore_data_seeder.dart
```

### Tạo dữ liệu thủ công:

1. Truy cập Firebase Console
2. Vào Firestore Database
3. Tạo các collection và document theo cấu trúc trên

## Các tính năng đã cập nhật

### 1. Admin Dashboard Screen
- **Thống kê nhanh**: Hiển thị số liệu thật từ Firestore
  - Yêu cầu chờ duyệt
  - Tổng giảng viên
  - Tổng lịch trình
  - Tổng phòng học

- **Yêu cầu cần xử lý gấp**: Hiển thị danh sách yêu cầu nghỉ phép thật
- **Cảnh báo tiến độ**: Dựa trên dữ liệu thật

### 2. Approvals Screen
- **Tab Chờ duyệt**: Hiển thị yêu cầu có status = 'pending'
- **Tab Đã duyệt**: Hiển thị yêu cầu có status = 'approved'
- **Tab Đã từ chối**: Hiển thị yêu cầu có status = 'rejected'

### 3. AdminProvider
- `loadDashboardStats()`: Tải thống kê từ Firestore
- `loadLeaveRequests()`: Tải danh sách yêu cầu nghỉ phép
- `loadPendingLeaveRequests()`: Tải yêu cầu chờ duyệt
- `updateLeaveRequestStatus()`: Cập nhật trạng thái yêu cầu

### 4. AdminService
- `getDashboardStats()`: Query thống kê từ Firestore
- `getLeaveRequestsStream()`: Stream yêu cầu nghỉ phép
- `getLeaveRequestsByStatusStream()`: Stream theo trạng thái
- `updateLeaveRequestStatus()`: Cập nhật trạng thái

## Debug và Monitoring

### Log messages:
- `📊 AdminService: Đang lấy thống kê dashboard...`
- `👥 AdminService: Lấy stream users với role: teacher`
- `📝 AdminService: Lấy stream leave requests...`
- `✅ AdminService: [Action] completed`

### Error handling:
- Hiển thị CircularProgressIndicator khi đang tải
- Hiển thị error message khi có lỗi
- Nút "Thử lại" để reload dữ liệu

## Lưu ý quan trọng

1. **Firestore Security Rules**: Đảm bảo rules cho phép admin đọc/ghi dữ liệu
2. **Network connectivity**: Cần kết nối internet để truy cập Firestore
3. **Authentication**: Admin phải đăng nhập để truy cập dữ liệu
4. **Real-time updates**: Dữ liệu sẽ tự động cập nhật khi có thay đổi

## Troubleshooting

### Lỗi "Permission denied":
- Kiểm tra Firestore Security Rules
- Đảm bảo user đã đăng nhập với role admin

### Lỗi "Network request failed":
- Kiểm tra kết nối internet
- Kiểm tra Firebase configuration

### Dữ liệu không hiển thị:
- Kiểm tra console logs
- Đảm bảo có dữ liệu trong Firestore
- Kiểm tra collection names và field names

## Next Steps

1. Cập nhật Schedule Management Screen để sử dụng dữ liệu thật
2. Cập nhật Management Screen để quản lý users/subjects/rooms
3. Cập nhật Reports Screen để tạo báo cáo từ dữ liệu thật
4. Thêm tính năng export/import dữ liệu
5. Thêm tính năng backup/restore dữ liệu

