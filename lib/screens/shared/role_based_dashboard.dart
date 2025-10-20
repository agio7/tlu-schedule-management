import 'package:flutter/material.dart';
import '../admin/admin_dashboard.dart';
import 'login_screen.dart'; // For logout fallback

class RoleBasedDashboard extends StatelessWidget {
  final String userRole;
  final String userName;
  final String userEmail;

  const RoleBasedDashboard({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    Widget dashboard;

    switch (userRole) {
      case 'admin':
        dashboard = const AdminDashboard();
        break;
      case 'department_head':
        dashboard = const Center(child: Text('Department Head Dashboard - Coming Soon'));
        break;
      case 'teacher':
        dashboard = const Center(child: Text('Teacher Dashboard - Coming Soon'));
        break;
      default:
        // Fallback for unknown roles or not logged in
        dashboard = const LoginScreen();
        break;
    }
    return dashboard;
  }
}











