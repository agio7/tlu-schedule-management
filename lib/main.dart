import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/teacher/dashboard_screen.dart';
import 'screens/teacher/calendar_screen.dart';
import 'screens/teacher/lesson_detail_screen.dart';
import 'screens/teacher/attendance_screen.dart';
import 'screens/teacher/leave_registration_screen.dart';
import 'screens/teacher/reports_screen.dart';
import 'providers/lesson_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LessonProvider()),
      ],
      child: MaterialApp.router(
        title: 'TLU Schedule Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B46C1), // Purple theme
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/lesson-detail/:lessonId',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId']!;
        return LessonDetailScreen(lessonId: lessonId);
      },
    ),
    GoRoute(
      path: '/attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/leave-registration',
      builder: (context, state) => const LeaveRegistrationScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
  ],
);