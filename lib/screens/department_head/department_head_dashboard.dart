import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/login_screen.dart';

class DepartmentHeadDashboard extends StatelessWidget {
  const DepartmentHeadDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userData?.fullName ?? 'Trưởng bộ môn';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Trưởng bộ môn'),
        backgroundColor: Colors.indigo, // Màu sắc riêng cho trưởng bộ môn
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
              Icons.group_work,
              size: 100,
              color: Colors.indigo,
            ),
            const SizedBox(height: 20),
            Text(
              'Chào mừng Trưởng bộ môn',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Đây là giao diện dành cho trưởng bộ môn.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}