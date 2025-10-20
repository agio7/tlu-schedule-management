import 'package:flutter/material.dart';

import 'dashboard/admin_dashboard_screen.dart';
import 'schedule/schedule_management_screen.dart';
import 'approvals/approvals_screen.dart';
import 'management/management_screen.dart';
import 'reports/reports_screen.dart';

class MobileAdminDashboard extends StatefulWidget {
  const MobileAdminDashboard({super.key});

  @override
  State<MobileAdminDashboard> createState() => _MobileAdminDashboardState();
}

class _MobileAdminDashboardState extends State<MobileAdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    ScheduleManagementScreen(),
    ApprovalsScreen(),
    ManagementScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Phòng Đào Tạo'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                // TODO: Logout
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
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
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Lịch trình',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Phê duyệt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Quản lý',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Báo cáo',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hành động nhanh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickActionTile(
              icon: Icons.schedule,
              title: 'Tạo lịch trình',
              subtitle: 'Thêm lịch học mới',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create schedule
              },
            ),
            _buildQuickActionTile(
              icon: Icons.notifications,
              title: 'Gửi thông báo',
              subtitle: 'Thông báo đến giảng viên',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to send notification
              },
            ),
            _buildQuickActionTile(
              icon: Icons.approval,
              title: 'Duyệt yêu cầu',
              subtitle: 'Xem yêu cầu chờ duyệt',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 2; // Navigate to approvals
                });
              },
            ),
            _buildQuickActionTile(
              icon: Icons.analytics,
              title: 'Xem báo cáo',
              subtitle: 'Thống kê và báo cáo',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 4; // Navigate to reports
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
        child: Icon(icon, color: const Color(0xFF1976D2)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// Removed placeholder pages; using real admin screens above
