# 🎯 HƯỚNG DẪN QUY TRÌNH SINH LỊCH TỰ ĐỘNG

## 📋 TỔNG QUAN

Quy trình "Sinh Lịch Tự Động" là một hệ thống thông minh biến **CourseSections** (Công thức) thành **Schedules** (Sản phẩm) một cách tự động.

## 🔄 QUY TRÌNH HOẠT ĐỘNG

### **BƯỚC 1: ĐẦU VÀO - CourseSections (Công thức)**

```
CourseSections {
  id: "sec_it4420_01"
  subjectId: "subj_it4420"        // Môn gì?
  teacherId: "teacher_001"        // Ai dạy?
  classroomId: "class_65cntt1"    // Lớp nào?
  roomId: "room_c1_301"           // Phòng nào?
  semesterId: "sem_2425_1"        // Học kỳ nào?
  totalSessions: 16                // Cần bao nhiêu buổi?
  scheduleString: "Thứ 2, Tiết 1-3; Thứ 5, Tiết 7-9"  // Lịch học hàng tuần
}
```

### **BƯỚC 2: XỬ LÝ - ScheduleGenerator Service**

#### **2.1. Phân tích ScheduleString**
```
Input: "Thứ 2, Tiết 1-3; Thứ 5, Tiết 7-9"
Output: [
  {dayOfWeek: 1, periods: [1, 2, 3]},  // Thứ 2, Tiết 1-3
  {dayOfWeek: 4, periods: [7, 8, 9]}   // Thứ 5, Tiết 7-9
]
```

#### **2.2. Tính toán thời gian**
```
Tiết 1: 07:00 - 07:50
Tiết 2: 07:55 - 08:45
Tiết 3: 08:50 - 09:40
Tiết 7: 12:55 - 13:45
Tiết 8: 13:50 - 14:40
Tiết 9: 15:00 - 15:50
```

#### **2.3. Vòng lặp sinh lịch**
```
Tuần 1 (Bắt đầu từ 2024-09-02):
  - Thứ 2 (2024-09-02): Tạo Schedules sessionNumber: 1, 2, 3
  - Thứ 5 (2024-09-05): Tạo Schedules sessionNumber: 4, 5, 6

Tuần 2 (Bắt đầu từ 2024-09-09):
  - Thứ 2 (2024-09-09): Tạo Schedules sessionNumber: 7, 8, 9
  - Thứ 5 (2024-09-12): Tạo Schedules sessionNumber: 10, 11, 12

... (Tiếp tục đến tuần 8)
```

### **BƯỚC 3: ĐẦU RA - Schedules (Sản phẩm)**

```
Schedules {
  id: "sched_sec_it4420_01_001"
  courseSectionId: "sec_it4420_01"     // Liên kết với CourseSection
  sessionNumber: 1                      // Buổi thứ mấy?
  startTime: "2024-09-02 07:00:00"   // Giờ bắt đầu chính xác
  endTime: "2024-09-02 09:40:00"     // Giờ kết thúc chính xác
  status: "scheduled"                 // Trạng thái ban đầu
  content: ""                         // Nội dung (trống, chờ GV nhập)
}
```

## 🛠️ CÁC COMPONENT CHÍNH

### **1. ScheduleGeneratorService**
- **Chức năng**: Engine chính xử lý logic sinh lịch
- **Input**: CourseSection ID
- **Output**: List<Schedules>
- **File**: `lib/services/schedule_generator_service.dart`

### **2. ScheduleString Parser**
- **Chức năng**: Phân tích chuỗi lịch học
- **Input**: "Thứ 2, Tiết 1-3; Thứ 5, Tiết 7-9"
- **Output**: List<ScheduleRule>
- **Method**: `_parseScheduleString()`

### **3. Time Calculator**
- **Chức năng**: Tính toán thời gian chính xác
- **Input**: List<int> periods
- **Output**: List<TimeSlot>
- **Method**: `_calculateTimeSlots()`

### **4. CourseSectionsScreen**
- **Chức năng**: UI quản lý phân công giảng dạy
- **Features**: 
  - Xem danh sách CourseSections
  - Sinh lịch tự động
  - Xem lịch chi tiết
- **File**: `lib/screens/admin/schedule_management/course_sections_screen.dart`

## 📊 VÍ DỤ CỤ THỂ

### **Input CourseSection:**
```json
{
  "id": "sec_it4420_01",
  "subjectId": "subj_it4420",
  "teacherId": "teacher_001",
  "classroomId": "class_65cntt1",
  "roomId": "room_c1_301",
  "semesterId": "sem_2425_1",
  "totalSessions": 16,
  "scheduleString": "Thứ 2, Tiết 1-3; Thứ 5, Tiết 7-9"
}
```

### **Output Schedules (16 buổi):**
```
Buổi 1: T2 02/09/2024 07:00 - 09:40
Buổi 2: T2 02/09/2024 07:00 - 09:40
Buổi 3: T2 02/09/2024 07:00 - 09:40
Buổi 4: T5 05/09/2024 12:55 - 15:50
Buổi 5: T5 05/09/2024 12:55 - 15:50
Buổi 6: T5 05/09/2024 12:55 - 15:50
...
Buổi 16: T5 28/11/2024 12:55 - 15:50
```

## 🧪 TESTING

### **Test Script**
- **File**: `lib/scripts/test_schedule_generation.dart`
- **Chức năng**: Test toàn bộ quy trình sinh lịch
- **UI Test**: `lib/screens/admin/schedule_management/schedule_test_screen.dart`

### **Cách chạy test:**
1. Mở app
2. Vào Admin → Management → Quản lý Phân công
3. Click "Test Sinh Lịch"
4. Xem kết quả trong logs

## 🎯 LỢI ÍCH

### **1. Tự động hóa hoàn toàn**
- Không cần nhập từng buổi học thủ công
- Giảm thiểu lỗi nhập liệu
- Tiết kiệm thời gian

### **2. Linh hoạt**
- Hỗ trợ nhiều lịch học khác nhau
- Dễ dàng thay đổi lịch học
- Tự động tính toán thời gian

### **3. Chính xác**
- Tính toán thời gian chính xác đến phút
- Tự động xử lý ngày tháng
- Tránh xung đột lịch học

## 🔧 CÁCH SỬ DỤNG

### **1. Tạo CourseSection**
```dart
final courseSection = await CourseSectionService.createCourseSection({
  'subjectId': 'subj_it4420',
  'teacherId': 'teacher_001',
  'classroomId': 'class_65cntt1',
  'roomId': 'room_c1_301',
  'semesterId': 'sem_2425_1',
  'totalSessions': 16,
  'scheduleString': 'Thứ 2, Tiết 1-3; Thứ 5, Tiết 7-9',
});
```

### **2. Sinh lịch tự động**
```dart
final schedules = await ScheduleGeneratorService.generateSchedulesFromCourseSection(
  courseSection.id
);
```

### **3. Xem kết quả**
```dart
for (final schedule in schedules) {
  print('Buổi ${schedule.sessionNumber}: ${schedule.startTime} - ${schedule.endTime}');
}
```

## 🚀 TƯƠNG LAI

### **Các tính năng có thể mở rộng:**
1. **Import CSV/Excel** - Tự động tạo CourseSections từ file
2. **Xung đột lịch học** - Kiểm tra và cảnh báo xung đột
3. **Lịch học linh hoạt** - Hỗ trợ lịch học không đều
4. **Thông báo** - Gửi thông báo lịch học cho giảng viên
5. **Export** - Xuất lịch học ra PDF/Excel

---

**🎉 Quy trình sinh lịch tự động đã sẵn sàng sử dụng!**


















