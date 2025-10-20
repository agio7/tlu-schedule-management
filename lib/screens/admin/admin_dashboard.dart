import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/login_screen.dart';
import 'responsive_admin_wrapper.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    
    // Simple client-side guard: only allow admin role to view this screen
    if (!(auth.isAuthenticated && auth.userData != null && auth.userData!.role == 'admin')) {
      return const Scaffold(
        body: Center(child: Text('Bạn không có quyền truy cập trang Admin.')),
      );
    }

    return const ResponsiveAdminWrapper();
  }
}