import 'package:flutter/material.dart';

class TeacherSchedule extends StatefulWidget {
  const TeacherSchedule({super.key});

  @override
  State<TeacherSchedule> createState() => _TeacherScheduleState();
}

class _TeacherScheduleState extends State<TeacherSchedule> {
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'week'; // week, month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch dạy cá nhân'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedView = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('Xem theo tuần'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('Xem theo tháng'),
              ),
            ],
            child: const Icon(Icons.view_module),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Picker
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _getFormattedDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day + 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
                IconButton(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
          ),

          // Schedule Content
          Expanded(
            child: _selectedView == 'week' ? _buildWeekView() : _buildMonthView(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final weekDays = _getWeekDays(_selectedDate);

    return ListView.builder(
      itemCount: weekDays.length,
      itemBuilder: (context, index) {
        final day = weekDays[index];
        final isToday = _isSameDay(day, DateTime.now());
        final isSelected = _isSameDay(day, _selectedDate);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1976D2).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Day Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF1976D2) : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _getDayName(day.weekday),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${day.day}/${day.month}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isToday ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Hôm nay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Classes for this day
              _buildDayClasses(day),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 35, // 5 weeks
      itemBuilder: (context, index) {
        final day = DateTime(_selectedDate.year, _selectedDate.month, index - 6);
        final isCurrentMonth = day.month == _selectedDate.month;
        final isToday = _isSameDay(day, DateTime.now());

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = day;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCurrentMonth
                  ? (isToday ? const Color(0xFF1976D2) : Colors.white)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isToday ? const Color(0xFF1976D2) : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isCurrentMonth
                      ? (isToday ? Colors.white : Colors.black87)
                      : Colors.grey,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayClasses(DateTime day) {
    final classes = _getClassesForDay(day);

    if (classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Không có lịch dạy',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      children: classes.map((classInfo) => _buildClassCard(classInfo)).toList(),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classInfo) {
    Color statusColor;
    IconData statusIcon;

    switch (classInfo['status']) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'upcoming':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classInfo['subject'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${classInfo['class']} - ${classInfo['room']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                classInfo['time'],
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                _getStatusText(classInfo['status']),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> _getClassesForDay(DateTime day) {
    // Mock data - replace with real data
    final mockClasses = {
      '2024-01-15': [
        {
          'subject': 'Lập trình Java',
          'class': 'CNTT01',
          'room': 'A101',
          'time': '08:00-10:00',
          'status': 'completed',
        },
        {
          'subject': 'Cơ sở dữ liệu',
          'class': 'CNTT02',
          'room': 'A102',
          'time': '10:30-12:30',
          'status': 'upcoming',
        },
      ],
      '2024-01-16': [
        {
          'subject': 'Thực hành Java',
          'class': 'CNTT01',
          'room': 'Lab A',
          'time': '14:00-16:00',
          'status': 'upcoming',
        },
      ],
    };

    final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return mockClasses[dateKey] ?? [];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(int weekday) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[weekday % 7];
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Đã dạy';
      case 'cancelled':
        return 'Đã hủy';
      case 'upcoming':
        return 'Sắp tới';
      default:
        return 'Không xác định';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}