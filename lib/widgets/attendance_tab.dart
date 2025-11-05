import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../models/user.dart';
import '../providers/lesson_provider.dart';
import '../services/student_service.dart';

class AttendanceTab extends StatefulWidget {
  final Lesson lesson;

  const AttendanceTab({
    super.key,
    required this.lesson,
  });

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  List<User> _students = [];
  final Set<String> _presentStudents = <String>{};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    // Initialize with existing attendance if any
    _presentStudents.addAll(widget.lesson.attendanceList);
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Thử lấy theo className trước
      List<User> students = await StudentService.getStudentsByClassName(widget.lesson.className);
      
      // Nếu không có, thử lấy theo classroomId
      if (students.isEmpty && widget.lesson.classroomId != null) {
        students = await StudentService.getStudentsByClassroomId(widget.lesson.classroomId!);
      }

      // Nếu vẫn không có, lấy tất cả sinh viên (fallback)
      if (students.isEmpty) {
        students = await StudentService.getAllStudents();
      }

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải danh sách sinh viên: $e';
        _isLoading = false;
      });
      print('Error loading students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Điểm danh sinh viên',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B46C1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tổng: ${_students.length} sinh viên',
                  style: const TextStyle(
                    color: Color(0xFF6B46C1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm sinh viên...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Student List Table
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6B46C1),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadStudents,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : _students.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Không có sinh viên nào',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                // Table Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child: Text(
                                          'STT',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          'Mã SV',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Họ tên',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          'Trạng thái',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Student List
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _students.length,
                                    itemBuilder: (context, index) {
                                      final student = _students[index];
                                      // Sử dụng studentId từ user hoặc tạo từ index
                                      final studentId = student.id.length <= 10 
                                          ? student.id 
                                          : 'SV${(index + 1).toString().padLeft(3, '0')}';
                                      // Kiểm tra attendance theo fullName (tương thích với dữ liệu cũ) hoặc studentId
                                      final isPresent = _presentStudents.contains(student.fullName) || 
                                                        _presentStudents.contains(student.id);

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.grey[200]!),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 50,
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                studentId,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                student.fullName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: isPresent,
                                                    onChanged: (widget.lesson.status == 'upcoming' || widget.lesson.status == 'ongoing') 
                                                        ? (value) {
                                                            setState(() {
                                                              if (value == true) {
                                                                // Lưu theo fullName để tương thích với dữ liệu cũ
                                                                _presentStudents.add(student.fullName);
                                                              } else {
                                                                _presentStudents.remove(student.fullName);
                                                                _presentStudents.remove(student.id);
                                                              }
                                                            });
                                                          }
                                                        : null,
                                                    activeColor: const Color(0xFF6B46C1),
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  Text(
                                                    isPresent ? 'Có mặt' : 'Vắng',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isPresent ? Colors.green[600] : Colors.red[600],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
            ),
          ),

          const SizedBox(height: 20),

          // Save Button
          if (widget.lesson.status == 'upcoming' || widget.lesson.status == 'ongoing')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<LessonProvider>().updateAttendance(
                    widget.lesson.id,
                    _presentStudents.toList(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu điểm danh'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Lưu điểm danh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}