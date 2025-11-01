import 'package:flutter/material.dart';
import 'login_screen.dart';
// import '../admin/admin_dashboard.dart'; // Xóa import này

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard,
              size: 100,
              color: Color(0xFF1976D2),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chào mừng đến với Dashboard!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Đăng nhập thành công!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            // Đã xóa nút AdminDashboard tại đây
            // Nếu muốn thêm nút tới giao diện trưởng bộ môn thì thay bằng dòng dưới:
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const DepartmentHeadDashboard(),
            //       ),
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            //   ),
            //   child: const Text(
            //     'Vào Dashboard Trưởng bộ môn',
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
