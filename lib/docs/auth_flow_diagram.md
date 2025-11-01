# 🔐 LUỒNG HOẠT ĐỘNG PHÂN QUYỀN TLU SCHEDULE MANAGEMENT

## 📊 SƠ ĐỒ LUỒNG AUTHENTICATION & AUTHORIZATION

```
┌─────────────────────────────────────────────────────────────────┐
│                        🚀 APP STARTUP                          │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    📱 MAIN.DART                                │
│  • Firebase.initializeApp()                                   │
│  • MultiProvider setup                                        │
│  • AuthProvider + AdminProvider                               │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                     🎯 APP.DART                               │
│  Consumer<AuthProvider> kiểm tra trạng thái:                  │
│  • isLoading? → Loading Screen                                │
│  • isAuthenticated + userData? → RoleBasedDashboard           │
│  • else → LoginScreen                                         │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                🔐 LOGIN SCREEN                                │
│  User nhập email/password → AuthProvider.signIn()             │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                🔍 AUTH PROVIDER                               │
│  • _setLoading(true)                                          │
│  • AuthService.signInWithRetry()                              │
│  • Nếu thành công: _userData = result['userData']             │
│  • _isAuthenticated = true                                     │
│  • notifyListeners() → UI rebuild                             │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                🛡️ AUTH SERVICE                                │
│  • Firebase Auth: signInWithEmailAndPassword()                │
│  • Lấy UID từ Firebase Auth                                   │
│  • Tìm user data trong Firestore theo UID                    │
│  • Trả về Users model với role                                │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│              🎭 ROLE-BASED DASHBOARD                           │
│  switch(userRole):                                             │
│  • 'admin' → AdminDashboard                                   │
│  • 'department_head' → DepartmentHeadDashboard               │
│  • 'teacher' → TeacherDashboard                              │
│  • default → LoginScreen                                      │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                🏢 ADMIN DASHBOARD                              │
│  ✅ ROLE GUARD: Kiểm tra auth.userData.role == 'admin'       │
│  • Nếu không phải admin → "Không có quyền truy cập"          │
│  • Nếu là admin → ResponsiveAdminWrapper                     │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│            📱 RESPONSIVE ADMIN WRAPPER                        │
│  • Detect platform (Web/Mobile)                              │
│  • Web: WebAdminDashboard                                     │
│  • Mobile: MobileAdminDashboard                               │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│              🛠️ ADMIN MANAGEMENT SCREENS                       │
│  ❌ THIẾU ROLE GUARDS:                                        │
│  • CRUD Screens (Users, Subjects, Classrooms, etc.)          │
│  • Import Screens                                             │
│  • Management Screens                                         │
│  • Reports Screens                                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              👨‍🏫 TEACHER DASHBOARD                           │
│  ❌ THIẾU ROLE GUARD:                                         │
│  • Không kiểm tra role                                        │
│  • Ai cũng có thể truy cập                                    │
│  • Chỉ hiển thị "Coming Soon"                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│            👥 DEPARTMENT HEAD DASHBOARD                        │
│  ❌ THIẾU ROLE GUARD:                                         │
│  • Không kiểm tra role                                        │
│  • Ai cũng có thể truy cập                                    │
│  • Chỉ hiển thị "Coming Soon"                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 CHI TIẾT LUỒNG HOẠT ĐỘNG

### **BƯỚC 1: KHỞI TẠO APP**
```dart
// main.dart
void main() async {
  // 1. Khởi tạo Firebase
  await Firebase.initializeApp();
  
  // 2. Setup Providers
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => AdminProvider()),
    ],
    child: MaterialApp(home: MyApp()),
  );
}
```

### **BƯỚC 2: KIỂM TRA TRẠNG THÁI AUTH**
```dart
// app.dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) {
      return LoadingScreen();
    }
    
    if (authProvider.isAuthenticated && authProvider.userData != null) {
      return RoleBasedDashboard(
        userRole: authProvider.userData!.role,
        userName: authProvider.userData!.fullName,
        userEmail: authProvider.userData!.email,
      );
    }
    
    return LoginScreen();
  },
)
```

### **BƯỚC 3: ĐĂNG NHẬP**
```dart
// login_screen.dart
Future<void> _handleLogin(AuthProvider auth) async {
  await auth.signInWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );
}
```

### **BƯỚC 4: XỬ LÝ AUTHENTICATION**
```dart
// auth_provider.dart
Future<bool> signInWithEmailAndPassword({...}) async {
  _setLoading(true);
  
  final result = await AuthService.signInWithRetry(email: email, password: password);
  
  if (result['success']) {
    _userData = result['userData'];        // Users model với role
    _isAuthenticated = true;
    notifyListeners();                     // Trigger UI rebuild
    return true;
  } else {
    _setError(result['message']);
    return false;
  }
}
```

### **BƯỚC 5: AUTH SERVICE**
```dart
// auth_service.dart
static Future<Map<String, dynamic>> signInWithEmailAndPassword({...}) async {
  // 1. Firebase Auth
  final userCredential = await _auth.signInWithEmailAndPassword(
    email: email, password: password
  );
  
  // 2. Lấy UID
  final String uid = userCredential.user!.uid;
  
  // 3. Tìm user data trong Firestore
  final userModel = await getUsersDataFromFirestore(uid);
  
  // 4. Trả về Users model với role
  return {'success': true, 'userData': userModel};
}
```

### **BƯỚC 6: ROLE-BASED ROUTING**
```dart
// role_based_dashboard.dart
Widget build(BuildContext context) {
  switch (userRole) {
    case 'admin':
      return AdminDashboard();
    case 'department_head':
      return DepartmentHeadDashboard();
    case 'teacher':
      return TeacherDashboard();
    default:
      return LoginScreen();
  }
}
```

### **BƯỚC 7: ROLE GUARDS (CHỈ ADMIN CÓ)**
```dart
// admin_dashboard.dart
Widget build(BuildContext context) {
  final auth = Provider.of<AuthProvider>(context, listen: true);
  
  // ✅ ROLE GUARD
  if (!(auth.isAuthenticated && auth.userData != null && auth.userData!.role == 'admin')) {
    return Scaffold(
      body: Center(child: Text('Bạn không có quyền truy cập trang Admin.')),
    );
  }
  
  return ResponsiveAdminWrapper();
}
```

## ⚠️ VẤN ĐỀ HIỆN TẠI

### **1. THIẾU ROLE GUARDS:**
- ❌ **Teacher Dashboard** - Không có role guard
- ❌ **Department Head Dashboard** - Không có role guard  
- ❌ **CRUD Screens** - Không có role guard
- ❌ **Management Screens** - Không có role guard

### **2. DASHBOARD CHƯA HOÀN THIỆN:**
- ❌ **Teacher Dashboard** - Chỉ hiển thị "Coming Soon"
- ❌ **Department Head Dashboard** - Chỉ hiển thị "Coming Soon"

### **3. BẢO MẬT KHÔNG ĐẦY ĐỦ:**
- ❌ Bất kỳ ai cũng có thể truy cập Teacher/Department Head screens
- ❌ Không có permission-based access control
- ❌ Không có department-based access control

## 🛠️ KHUYẾN NGHỊ CẢI THIỆN

### **1. THÊM ROLE GUARDS CHO TẤT CẢ SCREENS:**
```dart
// Ví dụ cho Teacher Dashboard
Widget build(BuildContext context) {
  final auth = Provider.of<AuthProvider>(context, listen: true);
  
  // ✅ THÊM ROLE GUARD
  if (!(auth.isAuthenticated && auth.userData != null && 
       (auth.userData!.role == 'teacher' || auth.userData!.role == 'admin'))) {
    return Scaffold(
      body: Center(child: Text('Bạn không có quyền truy cập trang này.')),
    );
  }
  
  return TeacherDashboardContent();
}
```

### **2. TẠO PERMISSION SYSTEM:**
```dart
// utils/permission_helper.dart
class PermissionHelper {
  static bool hasPermission(String permission, String userRole) {
    switch (userRole) {
      case 'admin':
        return true; // Admin có tất cả quyền
      case 'department_head':
        return ['view_schedules', 'manage_teachers'].contains(permission);
      case 'teacher':
        return ['view_schedules', 'view_own_schedule'].contains(permission);
      default:
        return false;
    }
  }
}
```

### **3. IMPLEMENT MIDDLEWARE:**
```dart
// middleware/auth_middleware.dart
class AuthMiddleware {
  static Widget requireRole(String requiredRole, Widget child) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated || auth.userData?.role != requiredRole) {
          return UnauthorizedScreen();
        }
        return child;
      },
    );
  }
}
```

## 🎯 KẾT LUẬN

**Luồng phân quyền hiện tại:**
- ✅ **Authentication** - Hoạt động tốt
- ✅ **Role-based routing** - Có cơ bản
- ✅ **Admin role guard** - Đã có
- ❌ **Teacher/Department Head guards** - Thiếu
- ❌ **Permission system** - Chưa có
- ❌ **Department-based access** - Chưa có

**Cần cải thiện:** Thêm role guards cho tất cả screens và implement permission system chi tiết hơn.



