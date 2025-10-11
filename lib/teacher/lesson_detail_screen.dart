import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lesson_provider.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/lesson_content_tab.dart';
import '../widgets/attendance_tab.dart';
import '../widgets/leave_registration_tab.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        final lesson = lessonProvider.getLessonById(widget.lessonId);
        
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              title: const Text('Chi tiết buổi học'),
            ),
            body: const Center(
              child: Text('Không tìm thấy buổi học'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: const Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            title: const Text('Chi tiết buổi học'),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Lesson Information Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.subject,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lesson details row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.access_time,
                            '${lesson.startTime} - ${lesson.endTime}',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.calendar_today,
                            DateFormat('dd/MM/yyyy').format(lesson.date),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.school,
                            'Lớp: ${lesson.className}',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.location_on,
                            'Phòng: ${lesson.room}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF6B46C1),
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: const Color(0xFF6B46C1),
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Nội dung'),
                    Tab(text: 'Điểm danh'),
                    Tab(text: 'Nghỉ/Bù'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    LessonContentTab(lesson: lesson),
                    AttendanceTab(lesson: lesson),
                    LeaveRegistrationTab(lesson: lesson),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavigation(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}
