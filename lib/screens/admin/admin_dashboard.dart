import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/login_screen.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const ScheduleManagementScreen(),
    const TeacherManagementScreen(),
    const ClassroomManagementScreen(),
    const SubjectManagementScreen(),
    const RoomManagementScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    // Simple client-side guard: only allow admin role to view this screen
    if (!(auth.isAuthenticated && auth.userData != null && auth.userData!.role == 'admin')) {
      return const Scaffold(
        body: Center(child: Text('Bạn không có quyền truy cập trang Admin.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Phòng Đào Tạo'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
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
            icon: Icon(Icons.schedule),
            label: 'Lịch trình',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Giảng viên',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Lớp học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Môn học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room),
            label: 'Phòng học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Báo cáo',
          ),
        ],
      ),
    );
  }
}

// Trang chủ Admin
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan hệ thống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Tổng giảng viên',
                  '25',
                  Icons.person,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Tổng lớp học',
                  '45',
                  Icons.school,
                  Colors.green,
                ),
                _buildStatCard(
                  'Tổng môn học',
                  '120',
                  Icons.book,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Tổng phòng học',
                  '30',
                  Icons.room,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Lịch trình hôm nay',
                  '15',
                  Icons.schedule,
                  Colors.red,
                ),
                _buildStatCard(
                  'Yêu cầu nghỉ dạy',
                  '3',
                  Icons.pending_actions,
                  Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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
      ),
    );
  }
}

// Màn hình quản lý lịch trình
class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý Lịch trình',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Thêm lịch trình mới
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm mới'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.schedule, color: Colors.white),
                    ),
                    title: Text('Lịch trình ${index + 1}'),
                    subtitle: Text('Môn: Toán học - Lớp: CNTT K66'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình quản lý giảng viên
class TeacherManagementScreen extends StatelessWidget {
  const TeacherManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý Giảng viên',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Thêm giảng viên mới
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Thêm mới'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('Giảng viên ${index + 1}'),
                    subtitle: Text('Khoa: Công nghệ thông tin'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình quản lý lớp học
class ClassroomManagementScreen extends StatelessWidget {
  const ClassroomManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý Lớp học',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Thêm lớp học mới
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm mới'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.school, color: Colors.white),
                    ),
                    title: Text('Lớp CNTT K6${index + 1}'),
                    subtitle: Text('Số sinh viên: ${30 + index * 5}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình quản lý môn học
class SubjectManagementScreen extends StatelessWidget {
  const SubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý Môn học',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Thêm môn học mới
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm mới'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final subjects = ['Toán học', 'Lập trình', 'Cơ sở dữ liệu', 'Mạng máy tính', 'Hệ điều hành'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.book, color: Colors.white),
                    ),
                    title: Text(subjects[index]),
                    subtitle: Text('Số tín chỉ: ${3 + index}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình quản lý phòng học
class RoomManagementScreen extends StatelessWidget {
  const RoomManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý Phòng học',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Thêm phòng học mới
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm mới'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.room, color: Colors.white),
                    ),
                    title: Text('Phòng A${index + 1}01'),
                    subtitle: Text('Sức chứa: ${40 + index * 10} chỗ'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình báo cáo
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Báo cáo & Thống kê',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildReportCard(
                  'Báo cáo giờ giảng',
                  'Thống kê số giờ giảng của từng giảng viên',
                  Icons.analytics,
                  () {
                    // TODO: Xem báo cáo giờ giảng
                  },
                ),
                _buildReportCard(
                  'Báo cáo nghỉ dạy',
                  'Thống kê các trường hợp nghỉ dạy và dạy bù',
                  Icons.pending_actions,
                  () {
                    // TODO: Xem báo cáo nghỉ dạy
                  },
                ),
                _buildReportCard(
                  'Báo cáo chuyên cần',
                  'Thống kê chuyên cần của sinh viên',
                  Icons.people,
                  () {
                    // TODO: Xem báo cáo chuyên cần
                  },
                ),
                _buildReportCard(
                  'Báo cáo sử dụng phòng',
                  'Thống kê sử dụng phòng học',
                  Icons.room,
                  () {
                    // TODO: Xem báo cáo sử dụng phòng
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1976D2),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
