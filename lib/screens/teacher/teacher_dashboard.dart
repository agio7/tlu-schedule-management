import 'package:flutter/material.dart';
import 'teacher_schedule.dart';
import 'attendance_screen.dart';
import 'leave_request_screen.dart';
import 'makeup_class_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TeacherHome(),
    const TeacherSchedule(),
    const AttendanceScreen(),
    const LeaveRequestScreen(),
    const MakeupClassScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch dạy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Điểm danh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_busy),
            label: 'Nghỉ dạy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Dạy bù',
          ),
        ],
      ),
    );
  }
}

class TeacherHome extends StatelessWidget {
  const TeacherHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Giảng viên'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, Thầy/Cô!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nguyễn Văn A - Khoa Công nghệ Thông tin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Today's Schedule
            const Text(
              'Lịch dạy hôm nay',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            _buildTodaySchedule(),
            const SizedBox(height: 24),

            // Quick Stats
            const Text(
              'Thống kê cá nhân',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Buổi đã dạy', '12', Icons.check_circle, Colors.green),
                _buildStatCard('Buổi còn lại', '8', Icons.schedule, Colors.blue),
                _buildStatCard('Buổi nghỉ', '2', Icons.event_busy, Colors.orange),
                _buildStatCard('Dạy bù', '1', Icons.sync, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Thao tác nhanh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  'Điểm danh',
                  Icons.people_alt,
                  Colors.blue,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                  ),
                ),
                _buildActionCard(
                  'Đăng ký nghỉ',
                  Icons.event_busy,
                  Colors.orange,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeaveRequestScreen()),
                  ),
                ),
                _buildActionCard(
                  'Dạy bù',
                  Icons.schedule,
                  Colors.green,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MakeupClassScreen()),
                  ),
                ),
                _buildActionCard(
                  'Xem lịch',
                  Icons.calendar_today,
                  Colors.purple,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherSchedule()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    final todayClasses = [
      {
        'time': '08:00 - 10:00',
        'subject': 'Lập trình Java',
        'class': 'CNTT01',
        'room': 'A101',
        'status': 'completed'
      },
      {
        'time': '10:30 - 12:30',
        'subject': 'Cơ sở dữ liệu',
        'class': 'CNTT02',
        'room': 'A102',
        'status': 'upcoming'
      },
      {
        'time': '14:00 - 16:00',
        'subject': 'Thực hành Java',
        'class': 'CNTT01',
        'room': 'Lab A',
        'status': 'upcoming'
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todayClasses.length,
        itemBuilder: (context, index) {
          final classInfo = todayClasses[index];
          Color statusColor;
          IconData statusIcon;

          switch (classInfo['status']) {
            case 'completed':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
              break;
            case 'upcoming':
              statusColor = Colors.blue;
              statusIcon = Icons.schedule;
              break;
            default:
              statusColor = Colors.grey;
              statusIcon = Icons.help;
          }

          return ListTile(
            leading: Icon(statusIcon, color: statusColor),
            title: Text(classInfo['subject']!),
            subtitle: Text('${classInfo['class']} - ${classInfo['room']}'),
            trailing: Text(
              classInfo['time']!,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _showClassDetails(context, classInfo),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClassDetails(BuildContext context, Map<String, String> classInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classInfo['subject']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lớp: ${classInfo['class']}'),
            Text('Phòng: ${classInfo['room']}'),
            Text('Thời gian: ${classInfo['time']}'),
            Text('Trạng thái: ${classInfo['status'] == 'completed' ? 'Đã hoàn thành' : 'Sắp tới'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Bạn có 2 thông báo mới'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to login
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}