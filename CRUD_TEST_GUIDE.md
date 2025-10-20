# Hướng dẫn Test CRUD Functionality

## ✅ **Đã hoàn thành:**

### 1. **Services cho CRUD Operations**
- ✅ `TeacherService` - Quản lý giảng viên
- ✅ `SubjectService` - Quản lý môn học  
- ✅ `ClassroomService` - Quản lý lớp học
- ✅ `RoomService` - Quản lý phòng học

### 2. **Models đã cập nhật**
- ✅ `Teacher` - Model cho giảng viên với đầy đủ fields
- ✅ `Subject` - Model cho môn học với Firestore Timestamp support
- ✅ `Classroom` - Model cho lớp học với academic year
- ✅ `Room` - Model cho phòng học với equipment list

### 3. **CRUD Screen đã cập nhật**
- ✅ Sử dụng dữ liệu thật từ Firestore
- ✅ Form validation với error handling
- ✅ Search functionality
- ✅ Loading states và error messages
- ✅ CRUD operations (Create, Read, Update, Delete)

### 4. **AdminProvider đã cập nhật**
- ✅ Thêm methods: `addTeacher()`, `updateTeacher()`, `deleteTeacher()`
- ✅ Error handling và loading states
- ✅ Auto-reload data sau khi CRUD operations

## 🧪 **Cách Test CRUD Functionality:**

### **Bước 1: Chạy ứng dụng**
```bash
flutter run -d chrome
```

### **Bước 2: Đăng nhập Admin**
- Email: `admin@tlu.edu.vn`
- Password: (như đã setup)

### **Bước 3: Test Quản lý Giảng viên**
1. **Vào Admin Dashboard**
2. **Click "Quản lý" tab**
3. **Click "Quản lý Giảng viên"**

#### **Test Create (Thêm mới):**
1. Click nút **"+"** (FloatingActionButton)
2. Điền form:
   - **Họ và tên**: Nguyễn Văn A
   - **Email**: nguyenvana@tlu.edu.vn
   - **Số điện thoại**: 0123456789
   - **Mã giảng viên**: GV001
   - **Chuyên ngành**: Công nghệ thông tin
   - **Học hàm/Học vị**: Thạc sĩ
3. Click **"Thêm"**
4. ✅ Kiểm tra: Thông báo "Đã thêm Giảng viên thành công"
5. ✅ Kiểm tra: Giảng viên mới xuất hiện trong danh sách

#### **Test Read (Xem danh sách):**
1. ✅ Kiểm tra: Danh sách giảng viên hiển thị
2. ✅ Kiểm tra: Thông tin giảng viên hiển thị đúng (tên, email, chuyên ngành)
3. ✅ Kiểm tra: Icon và layout đẹp

#### **Test Search (Tìm kiếm):**
1. Nhập "Nguyễn" vào ô tìm kiếm
2. ✅ Kiểm tra: Chỉ hiển thị giảng viên có tên chứa "Nguyễn"
3. Xóa text tìm kiếm
4. ✅ Kiểm tra: Hiển thị lại tất cả giảng viên

#### **Test Update (Chỉnh sửa):**
1. Click **"⋮"** (PopupMenu) trên giảng viên muốn sửa
2. Click **"Chỉnh sửa"**
3. Sửa thông tin (ví dụ: đổi chuyên ngành)
4. Click **"Lưu"**
5. ✅ Kiểm tra: Thông báo "Đã cập nhật Giảng viên thành công"
6. ✅ Kiểm tra: Thông tin đã được cập nhật trong danh sách

#### **Test Delete (Xóa):**
1. Click **"⋮"** (PopupMenu) trên giảng viên muốn xóa
2. Click **"Xóa"**
3. Xác nhận xóa trong dialog
4. ✅ Kiểm tra: Thông báo "Đã xóa Giảng viên thành công"
5. ✅ Kiểm tra: Giảng viên đã bị xóa khỏi danh sách

### **Bước 4: Test Error Handling**
1. **Test validation:**
   - Thử thêm giảng viên không nhập tên → ✅ Hiển thị lỗi validation
   - Thử thêm giảng viên với email không hợp lệ → ✅ Hiển thị lỗi validation

2. **Test network error:**
   - Tắt internet và thử thêm giảng viên → ✅ Hiển thị error message với nút "Thử lại"

### **Bước 5: Test Loading States**
1. ✅ Kiểm tra: Loading spinner hiển thị khi đang tải dữ liệu
2. ✅ Kiểm tra: Loading spinner hiển thị khi đang thực hiện CRUD operations

## 🔄 **Các chức năng khác (TODO):**

### **Môn học, Lớp học, Phòng học:**
- Form và CRUD operations chưa được implement
- Cần thêm vào AdminProvider tương tự như Teacher

### **Cách implement tiếp:**
1. Thêm methods vào AdminProvider:
   ```dart
   Future<void> addSubject(Map<String, dynamic> subjectData) async { ... }
   Future<void> updateSubject(String subjectId, Map<String, dynamic> subjectData) async { ... }
   Future<void> deleteSubject(String subjectId) async { ... }
   ```

2. Cập nhật CRUDScreen để handle các loại khác:
   ```dart
   case 'Môn học':
     await adminProvider.addSubject(formData);
     break;
   ```

## 📊 **Kiểm tra dữ liệu trong Firebase Console:**

1. **Truy cập**: https://console.firebase.google.com/project/tlu-schedule-management/firestore
2. **Collection `users`**: Kiểm tra giảng viên mới được thêm với `role: "teacher"`
3. **Fields**: `email`, `fullName`, `employeeId`, `specialization`, `academicRank`, etc.

## 🎯 **Kết quả mong đợi:**

- ✅ CRUD operations hoạt động mượt mà
- ✅ Dữ liệu được lưu vào Firestore
- ✅ UI responsive và user-friendly
- ✅ Error handling tốt
- ✅ Loading states rõ ràng
- ✅ Form validation chặt chẽ

**Bây giờ bạn có thể test CRUD functionality cho giảng viên!** 🚀

