import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'web_admin_dashboard.dart';
import 'mobile_admin_dashboard.dart';

class ResponsiveAdminWrapper extends StatelessWidget {
  const ResponsiveAdminWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect platform và screen size
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Web: width > 768px hoặc đang chạy trên web
    if (isWeb || screenWidth > 768) {
      return const WebAdminDashboard();
    } else {
      // Mobile: width <= 768px
      return const MobileAdminDashboard();
    }
  }
}


