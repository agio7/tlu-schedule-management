import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/lesson_provider.dart';

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
  final List<String> _students = [
    'Nguyễn Văn A',
    'Trần Thị B',
    'Lê Văn C',
    'Phạm Thị D',
    'Hoàng Văn E',
    'Vũ Thị F',
    'Đặng Văn G',
    'Bùi Thị H',
    'Phan Văn I',
    'Ngô Thị K',
  ];

  final Set<String> _presentStudents = <String>{};

  @override
  void initState() {
    super.initState();
    // Initialize with existing attendance if any
    _presentStudents.addAll(widget.lesson.attendanceList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
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
                        '${_presentStudents.length}/${_students.length}',
                        style: const TextStyle(
                          color: Color(0xFF6B46C1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _students.isNotEmpty ? _presentStudents.length / _students.length : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Student List
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh sách sinh viên',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final isPresent = _presentStudents.contains(student);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isPresent ? Colors.green[50] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPresent ? Colors.green[200]! : Colors.grey[200]!,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: isPresent ? Colors.green[100] : Colors.grey[200],
                              child: Text(
                                student.split(' ').last.substring(0, 1),
                                style: TextStyle(
                                  color: isPresent ? Colors.green[700] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              student,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isPresent ? Colors.green[800] : const Color(0xFF374151),
                              ),
                            ),
                            trailing: Checkbox(
                              value: isPresent,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _presentStudents.add(student);
                                  } else {
                                    _presentStudents.remove(student);
                                  }
                                });
                              },
                              activeColor: const Color(0xFF6B46C1),
                            ),
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

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _presentStudents.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Xóa tất cả'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu điểm danh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}