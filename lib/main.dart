import 'package:flutter/material.dart';

import 'package:tlu_schedule_management/teacher/teacher_dashboard.dart';
import 'auth/login_screen.dart' hide AdminDashboard;
//import 'admin/admin_dashboard.dart';

void main() {
  runApp(const ScheduleApp());
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Lịch trình Giảng dạy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TeacherDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}