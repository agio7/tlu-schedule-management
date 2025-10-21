# TLU Schedule Management - Hệ thống quản lý lịch giảng dạy

## Tổng quan
Ứng dụng Flutter quản lý lịch giảng dạy cho Trưởng Bộ môn với giao diện hiện đại và tích hợp Firebase.

## Tính năng chính

### 🏠 Tổng quan
- Dashboard với các KPI cards hiển thị số liệu tổng quan
- Biểu đồ tiến độ giảng dạy theo giảng viên
- Danh sách yêu cầu chờ duyệt
- Quản lý dữ liệu mẫu (tạo/xóa/refresh)

### 📅 Lịch dạy
- Xem danh sách lịch giảng dạy
- Bộ lọc theo giảng viên, môn học, trạng thái
- Hiển thị thông tin chi tiết từng buổi dạy

### ✅ Phê duyệt
- **Tab Chờ duyệt**: Xử lý yêu cầu nghỉ và đăng ký dạy bù
- **Tab Đã duyệt**: Xem các yêu cầu đã được phê duyệt
- **Tab Từ chối**: Xem các yêu cầu bị từ chối
- Nút phê duyệt/từ chối cho từng yêu cầu

### 📊 Thống kê
- Báo cáo giờ giảng theo giảng viên
- Thống kê điểm danh
- Thống kê nghỉ/dạy bù
- Tiến độ giảng dạy
- Xuất báo cáo (Excel/PDF)

### 👥 Giảng viên
- Danh sách giảng viên với thông tin chi tiết
- Tìm kiếm theo tên, email
- Lọc theo môn học
- Hiển thị tiến độ giảng dạy

### ⚠️ Cảnh báo
- Quản lý các cảnh báo hệ thống
- Phân loại theo mức độ và trạng thái
- Cập nhật trạng thái xử lý

## Cấu trúc dữ liệu

### Giảng viên (Lecturer)
- Tên, chức danh, email, số điện thoại
- Môn giảng dạy
- Số giờ kế hoạch và thực tế

### Lịch dạy (ScheduleItem)
- Giảng viên, môn học, lớp
- Ngày, ca học, phòng
- Trạng thái: Đã dạy/Nghỉ/Dạy bù/Chưa dạy
- Điểm danh

### Yêu cầu nghỉ (LeaveRequest)
- Thông tin buổi dạy bị nghỉ
- Lý do nghỉ
- Minh chứng (URL tài liệu)
- Trạng thái: Chờ duyệt/Đã duyệt/Từ chối

### Đăng ký dạy bù (MakeupRegistration)
- Thông tin buổi nghỉ gốc
- Thông tin buổi dạy bù
- Tỷ lệ sinh viên xác nhận
- Trạng thái phê duyệt

### Cảnh báo (AlertItem)
- Loại cảnh báo: Trùng lịch/Chậm tiến độ/Nghỉ nhiều/Chưa dạy bù
- Mức độ: Cao/Trung bình/Thấp
- Trạng thái: Chưa xử lý/Đang xử lý/Đã xử lý

## Firebase Integration

### Cấu hình
- Firebase Realtime Database đã được cấu hình
- File `google-services.json` đã được thêm vào Android
- Firebase Core và Database dependencies đã được thêm

### Cấu trúc Database
```
/
├── lecturers/
│   └── {key}/
│       ├── name
│       ├── title
│       ├── email
│       ├── phone
│       ├── subject
│       ├── hoursPlanned
│       └── hoursActual
├── schedules/
│   └── {key}/
│       ├── lecturer
│       ├── subject
│       ├── className
│       ├── date (timestamp)
│       ├── session
│       ├── room
│       ├── status (enum index)
│       └── attendance
├── leaveRequests/
│   └── {key}/
│       ├── lecturer
│       ├── subject
│       ├── className
│       ├── date (timestamp)
│       ├── session
│       ├── room
│       ├── submittedAt (timestamp)
│       ├── reason
│       ├── documentUrl
│       └── status (enum index)
├── makeups/
│   └── {key}/
│       ├── lecturer
│       ├── originalDate (timestamp)
│       ├── originalSession
│       ├── makeupDate (timestamp)
│       ├── makeupSession
│       ├── makeupRoom
│       ├── studentConfirmedPercent
│       └── status (enum index)
└── alerts/
    └── {key}/
        ├── type (enum index)
        ├── detail
        ├── date (timestamp)
        ├── priority
        └── state (enum index)
```

## Cách sử dụng

### 1. Khởi chạy ứng dụng
```bash
flutter run
```

### 2. Tạo dữ liệu mẫu
- Khi mở ứng dụng lần đầu, bạn sẽ thấy thông báo "Chưa có dữ liệu"
- Nhấn **"Tạo dữ liệu mẫu"** để tạo dữ liệu vào Firebase
- Hoặc nhấn **"Tạo ngay"** để tạo dữ liệu local (nhanh hơn)

### 3. Test các chức năng
- **Tổng quan**: Xem KPI và biểu đồ
- **Lịch dạy**: Test bộ lọc và xem danh sách
- **Phê duyệt**: Test phê duyệt/từ chối yêu cầu
- **Thống kê**: Xem báo cáo và xuất file
- **Giảng viên**: Test tìm kiếm và lọc
- **Cảnh báo**: Test cập nhật trạng thái

### 4. Quản lý dữ liệu
- **Refresh**: Tải lại dữ liệu từ Firebase
- **Xóa dữ liệu**: Xóa tất cả dữ liệu (có xác nhận)

## Dữ liệu mẫu

Ứng dụng tự động tạo dữ liệu mẫu bao gồm:

### 4 Giảng viên
- Nguyễn Văn An (Tiến sĩ) - Lập trình Web
- Trần Thị Bình (Thạc sĩ) - Cơ sở dữ liệu  
- Lê Minh Cường (Tiến sĩ) - Mạng máy tính
- Phạm Thị Dung (Thạc sĩ) - Phân tích thiết kế hệ thống

### 4 Buổi dạy
- Các buổi dạy với trạng thái khác nhau
- Thông tin phòng, ca học, điểm danh

### 2 Yêu cầu nghỉ
- 1 chờ duyệt, 1 đã duyệt
- Có lý do và minh chứng

### 2 Đăng ký dạy bù
- 1 chờ duyệt, 1 đã duyệt
- Thông tin buổi nghỉ và dạy bù

### 3 Cảnh báo
- Trùng lịch (Cao, Chưa xử lý)
- Chưa dạy bù (Trung bình, Đang xử lý)
- Chậm tiến độ (Thấp, Đã xử lý)

## Công nghệ sử dụng

- **Flutter**: Framework phát triển ứng dụng
- **Firebase**: Backend và database
- **Provider**: State management
- **Material Design 3**: UI/UX design
- **Google Fonts**: Typography
- **FL Chart**: Biểu đồ và thống kê

## Cấu trúc project

```
lib/
├── main.dart              # Entry point và UI chính
├── app_state.dart         # State management và models
├── firebase_service.dart  # Firebase operations
└── README.md             # Tài liệu này
```

## Lưu ý

- Ứng dụng tự động tạo dữ liệu mẫu khi khởi động nếu chưa có dữ liệu
- Có fallback tạo dữ liệu local nếu Firebase không hoạt động
- Tất cả dữ liệu được đồng bộ với Firebase Realtime Database
- Giao diện responsive, hỗ trợ cả mobile và tablet

## Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra kết nối internet
2. Thử nhấn "Refresh" để tải lại dữ liệu
3. Sử dụng "Tạo ngay" để tạo dữ liệu local
4. Kiểm tra console log để xem lỗi chi tiết
