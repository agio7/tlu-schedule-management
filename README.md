# TLU Schedule Management

Hệ thống quản lý lịch trình giảng dạy cho Trường Đại Học Thủy Lợi.

## Tính năng chính

### 🔐 Đăng nhập
- Đăng nhập với email và mật khẩu
- Xác thực qua Firebase Authentication
- Quản lý phiên đăng nhập

### 👨‍🏫 Giao diện giảng viên
- **Dashboard**: Tổng quan lịch dạy hôm nay
- **Lịch**: Xem lịch dạy theo tháng với cuộn mượt mà
- **Đăng ký nghỉ**: Đăng ký nghỉ dạy và dạy bù
- **Báo cáo**: Thống kê giảng dạy

## Công nghệ sử dụng

- **Flutter**: Framework phát triển ứng dụng
- **Firebase**: Backend và database
  - Authentication: Xác thực người dùng
  - Firestore: Lưu trữ dữ liệu
- **Provider**: State management
- **Go Router**: Navigation

## Cấu trúc dự án

```
lib/
├── auth/                    # Đăng nhập
│   └── login_screen.dart
├── models/                  # Data models
│   ├── lesson.dart
│   ├── leave_request.dart
│   └── user.dart
├── providers/              # State management
│   ├── auth_provider.dart
│   └── lesson_provider.dart
├── screens/teacher/         # Giao diện giảng viên
│   ├── dashboard_screen.dart
│   ├── calendar_screen.dart
│   ├── leave_registration_screen.dart
│   └── reports_screen.dart
├── services/               # Firebase services
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   ├── lesson_service.dart
│   ├── leave_request_service.dart
│   └── realtime_service.dart
└── widgets/                # UI components
    ├── bottom_navigation.dart
    ├── lesson_card.dart
    └── leave_registration_tab.dart
```

## Tính năng đặc biệt

### 📱 Responsive Design
- Giao diện thích ứng mọi kích thước màn hình
- Cuộn mượt mà với BouncingScrollPhysics
- Touch-friendly với kích thước phù hợp

### 🔄 Real-time Updates
- Dữ liệu tự động cập nhật từ Firebase
- Không cần refresh để thấy dữ liệu mới
- Streams cho lessons và leave requests

### 🎨 Modern UI/UX
- Material Design 3
- Gradient backgrounds
- Smooth animations
- Loading states và error handling

## Cài đặt và chạy

1. **Clone repository**
```bash
git clone [repository-url]
cd tlu-schedule-management
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Cấu hình Firebase**
- Thêm file `google-services.json` vào `android/app/`
- Cấu hình Firebase project

4. **Chạy ứng dụng**
```bash
flutter run
```

## Yêu cầu hệ thống

- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Android API 21+ / iOS 11+
- Firebase project đã cấu hình

## Liên hệ

Dự án phát triển cho Trường Đại Học Thủy Lợi.