import 'package:flutter/material.dart';
import '../department_head/department_head_simple_screen.dart';
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
        // Không còn dashboard cho admin, chuyển về login hoặc một placeholder
        dashboard = const LoginScreen();
        break;
      case 'department_head':
        dashboard = const DepartmentHeadSimpleScreen();
        break;
      case 'teacher':
        dashboard = const Center(child: Text('Teacher Dashboard - Coming Soon'));
        break;
      default:
        dashboard = const LoginScreen();
        break;
    }
    return dashboard;
  }
}











