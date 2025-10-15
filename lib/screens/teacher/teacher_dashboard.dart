import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/login_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userData?.fullName ?? 'Giảng viên';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang của Giảng viên'),
        backgroundColor: Colors.teal, // Màu sắc riêng cho giảng viên
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Đăng xuất và quay về màn hình đăng nhập
              authProvider.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
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
              Icons.person_pin_rounded,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            Text(
              'Chào mừng Giảng viên',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Đây là giao diện dành cho giảng viên.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}