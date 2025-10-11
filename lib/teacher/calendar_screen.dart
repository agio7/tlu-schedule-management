import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/lesson_provider.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/lesson_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedSubject = 'Tất cả';
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: const Text('Lịch Giảng Dạy'),
        elevation: 0,
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          final allLessons = lessonProvider.lessons;
          final subjects = ['Tất cả', ...allLessons.map((l) => l.subject).toSet().toList()];
          
          // Filter lessons based on selected subject
          List<dynamic> filteredLessons = allLessons;
          if (_selectedSubject != 'Tất cả') {
            filteredLessons = allLessons.where((l) => l.subject == _selectedSubject).toList();
          }
          
          // Filter by status
          if (_selectedFilter == 'Đã học') {
            filteredLessons = filteredLessons.where((l) => l.isCompleted).toList();
          } else if (_selectedFilter == 'Sắp tới') {
            filteredLessons = filteredLessons.where((l) => !l.isCompleted).toList();
          }

          return Column(
            children: [
              // Calendar Widget
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month/Year Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                              });
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            DateFormat('MMMM yyyy', 'vi').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                              });
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    
                    // Calendar Grid
                    _buildCalendarGrid(),
                  ],
                ),
              ),
              
              // Subject Filter
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedSubject,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value!;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildFilterTab('Tất cả', filteredLessons.length),
                    _buildFilterTab('Đã học', filteredLessons.where((l) => l.isCompleted).length),
                    _buildFilterTab('Sắp tới', filteredLessons.where((l) => !l.isCompleted).length),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lessons List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Lịch môn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredLessons.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredLessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = filteredLessons[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: LessonCard(
                                      lesson: lesson,
                                      onTap: () {
                                        context.go('/lesson-detail/${lesson.id}');
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = firstWeekday - 1 + daysInMonth;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: day == 'T7' || day == 'CN' ? Colors.red : Colors.grey[700],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Calendar days
          ...List.generate((totalCells / 7).ceil(), (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final cellIndex = weekIndex * 7 + dayIndex;
                final dayNumber = cellIndex - firstWeekday + 2;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                
                final isToday = dayNumber == DateTime.now().day && 
                               _selectedDate.month == DateTime.now().month &&
                               _selectedDate.year == DateTime.now().year;
                final isWeekend = dayIndex >= 5;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
                      });
                    },
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFF6B46C1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            color: isToday 
                                ? Colors.white 
                                : isWeekend 
                                    ? Colors.red 
                                    : Colors.black87,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
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
