import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/lesson_provider.dart';
import '../../widgets/bottom_navigation.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
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
          final todayLessons = lessonProvider.getTodayLessons();
          final ongoingLessons = todayLessons.where((lesson) => lesson.status == 'ongoing').toList();
          final upcomingLessons = todayLessons.where((lesson) => lesson.status == 'upcoming').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Date Header
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
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'vi').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hôm nay có ${todayLessons.length} buổi học',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Ongoing Lessons
                if (ongoingLessons.isNotEmpty) ...[
                  const Text(
                    'Buổi học đang diễn ra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ongoingLessons.map((lesson) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildAttendanceCard(lesson, isOngoing: true),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Upcoming Lessons
                if (upcomingLessons.isNotEmpty) ...[
                  const Text(
                    'Buổi học sắp tới',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...upcomingLessons.map((lesson) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildAttendanceCard(lesson, isOngoing: false),
                    );
                  }),
                ],

                // No lessons today
                if (todayLessons.isEmpty) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.event_available,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hôm nay không có buổi học nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bạn có thể xem lịch học trong tab Lịch',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/calendar'),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Xem lịch học'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildAttendanceCard(dynamic lesson, {required bool isOngoing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOngoing ? Colors.blue[200]! : Colors.grey[200]!,
          width: 2,
        ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOngoing ? Colors.blue[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOngoing ? 'Đang diễn ra' : 'Sắp tới',
                  style: TextStyle(
                    color: isOngoing ? Colors.blue[700] : Colors.orange[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${lesson.startTime} - ${lesson.endTime}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            lesson.subject,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.people, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                'Lớp: ${lesson.className}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                'Phòng: ${lesson.room}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Attendance Status
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 20,
                color: lesson.attendanceList.isNotEmpty ? Colors.green[600] : Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                lesson.attendanceList.isNotEmpty
                    ? 'Đã điểm danh (${lesson.attendanceList.length} sinh viên)'
                    : 'Chưa điểm danh',
                style: TextStyle(
                  fontSize: 14,
                  color: lesson.attendanceList.isNotEmpty ? Colors.green[600] : Colors.grey[600],
                  fontWeight: lesson.attendanceList.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/lesson-detail/${lesson.id}');
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Xem chi tiết'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to attendance tab in lesson detail
                    context.go('/lesson-detail/${lesson.id}');
                  },
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('Điểm danh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B46C1),
                    side: const BorderSide(color: Color(0xFF6B46C1)),
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