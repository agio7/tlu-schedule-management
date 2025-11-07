import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../admin/admin_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../../auth/login_screen.dart'; // For logout fallback
=======
import '../department_head/department_head_simple_screen.dart';
import 'login_screen.dart'; // For logout fallback
>>>>>>> Hải

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
<<<<<<< HEAD

    switch (userRole) {
      case 'admin':
        dashboard = const AdminDashboard();
        break;
      case 'department_head':
        dashboard = const Center(child: Text('Department Head Dashboard - Coming Soon'));
        break;
      case 'teacher':
        dashboard = const TeacherDashboard();
        break;
      default:
        // Fallback for unknown roles or not logged in
=======
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
>>>>>>> Hải
        dashboard = const LoginScreen();
        break;
    }
    return dashboard;
  }
}











