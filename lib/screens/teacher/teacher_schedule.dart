import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/lesson_card.dart';

class TeacherSchedule extends StatefulWidget {
  const TeacherSchedule({super.key});

  @override
  State<TeacherSchedule> createState() => _TeacherScheduleState();
}

class _TeacherScheduleState extends State<TeacherSchedule> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    // Setup real-time data streams
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.userData?.id != null) {
        context.read<LessonProvider>().setupRealtimeStreams(authProvider.userData!.id);
      } else {
        context.read<LessonProvider>().setupAllRealtimeStreams();
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
        title: const Text('Lịch giảng dạy'),
        elevation: 0,
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          final allLessons = lessonProvider.lessons;
          
          // Filter lessons based on selected filter
          List<dynamic> filteredLessons = allLessons;
          if (_selectedFilter == 'Đã học') {
            filteredLessons = allLessons.where((l) => l.isCompleted).toList();
          } else if (_selectedFilter == 'Sắp tới') {
            filteredLessons = allLessons.where((l) => !l.isCompleted).toList();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Date Picker
                Container(
                  margin: const EdgeInsets.all(16),
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
                    children: [
                      const Text(
                        'Chọn ngày xem lịch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF6B46C1)),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Row(
                    children: [
                      _buildFilterTab('Tất cả', allLessons.length),
                      _buildFilterTab('Đã học', allLessons.where((l) => l.isCompleted).length),
                      _buildFilterTab('Sắp tới', allLessons.where((l) => !l.isCompleted).length),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Lessons List
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFF6B46C1)),
                            const SizedBox(width: 8),
                            Text(
                              'Lịch giảng dạy - ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (filteredLessons.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
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
                        ...filteredLessons.map((lesson) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: LessonCard(
                              lesson: lesson,
                              onTap: () {
                                // Navigate to lesson detail
                              },
                            ),
                          );
                        }).toList(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildFilterTab(String label, int count) {
    final isSelected = _selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B46C1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
