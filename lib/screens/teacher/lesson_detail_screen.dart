import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lesson_provider.dart';
import '../../models/lesson.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId;
  
  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final TextEditingController _contentController = TextEditingController();
  final List<String> _attendanceList = [];

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  void _loadLessonData() {
    final lessonProvider = context.read<LessonProvider>();
    final lesson = lessonProvider.getLessonById(widget.lessonId);
    
    if (lesson != null) {
      _contentController.text = lesson.content ?? '';
      _attendanceList.addAll(lesson.attendanceList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: const Text('Chi tiết buổi học'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveLesson,
            icon: const Icon(Icons.save),
            tooltip: 'Lưu thay đổi',
          ),
        ],
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          final lesson = lessonProvider.getLessonById(widget.lessonId);
          
          if (lesson == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Không tìm thấy buổi học',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.subject,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${lesson.className} - ${lesson.room}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lesson.startTime} - ${lesson.endTime}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: lesson.isCompleted ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          lesson.isCompleted ? 'Đã hoàn thành' : 'Sắp tới',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Content Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nội dung buổi học',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Nhập nội dung buổi học...',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6B46C1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Attendance Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách điểm danh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_attendanceList.isEmpty)
                        const Text(
                          'Chưa có sinh viên nào điểm danh',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        )
                      else
                        ..._attendanceList.map((studentId) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  studentId,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: lesson.isCompleted ? null : _markCompleted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B46C1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Đánh dấu hoàn thành'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saveLesson,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B46C1),
                          side: const BorderSide(color: Color(0xFF6B46C1)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Lưu thay đổi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveLesson() async {
    final lessonProvider = context.read<LessonProvider>();
    
    // Save content
    if (_contentController.text.isNotEmpty) {
      await lessonProvider.updateLessonContent(widget.lessonId, _contentController.text);
    }
    
    // Save attendance
    if (_attendanceList.isNotEmpty) {
      await lessonProvider.updateAttendance(widget.lessonId, _attendanceList);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu thay đổi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _markCompleted() async {
    final lessonProvider = context.read<LessonProvider>();
    await lessonProvider.markLessonCompleted(widget.lessonId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu hoàn thành'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
