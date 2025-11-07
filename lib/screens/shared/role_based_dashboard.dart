import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin/responsive_admin_wrapper.dart';
import '../teacher/teacher_dashboard.dart';
import '../department_head/department_head_simple_screen.dart';
import '../../auth/login_screen.dart';
import '../../providers/auth_provider.dart';

class RoleBasedDashboard extends StatelessWidget {
  const RoleBasedDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final user = auth.userData;

    if (!auth.isAuthenticated || user == null) {
      return const LoginScreen();
    }

    switch (user.role) {
      case 'admin':
        return const ResponsiveAdminWrapper();
      case 'department_head':
        return const DepartmentHeadSimpleScreen();
      case 'teacher':
        return const TeacherDashboard();
      default:
        return const LoginScreen();
    }
  }
}











