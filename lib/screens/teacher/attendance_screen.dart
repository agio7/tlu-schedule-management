import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Setup và load dữ liệu khi màn hình được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final lessonProvider = context.read<LessonProvider>();
      
      // Kiểm tra nếu chưa có dữ liệu, force load
      final hasData = lessonProvider.lessons.isNotEmpty;
      
      if (authProvider.userData?.id != null) {
        // Nếu chưa có dữ liệu, force setup lại
        if (!hasData) {
          lessonProvider.setupRealtimeStreams(authProvider.userData!.id, force: true);
        } else {
          lessonProvider.setupRealtimeStreams(authProvider.userData!.id);
        }
        
        // Fallback: Load data directly if no data after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (lessonProvider.lessons.isEmpty && !lessonProvider.isLoading) {
            lessonProvider.loadLessonsByTeacher(authProvider.userData!.id);
          }
        });
      } else {
        // Nếu chưa có dữ liệu, force setup lại
        if (!hasData) {
          lessonProvider.setupAllRealtimeStreams(force: true);
        } else {
          lessonProvider.setupAllRealtimeStreams();
        }
        
        // Fallback: Load all data if no data after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (lessonProvider.lessons.isEmpty && !lessonProvider.isLoading) {
            lessonProvider.loadLessons();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: const Text('Điểm danh'),
        elevation: 0,
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          final lessons = lessonProvider.lessons;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Quản lý điểm danh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Theo dõi và quản lý điểm danh sinh viên',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Lessons List
                if (lessons.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có buổi học nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...lessons.map((lesson) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to lesson attendance screen
                        context.go('/lesson-attendance/${lesson.id}');
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lesson.subject,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: lesson.isCompleted ? Colors.green : Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    lesson.isCompleted ? 'Đã học' : 'Sắp tới',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${lesson.className} - ${lesson.room}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lesson.startTime} - ${lesson.endTime}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }
}

