import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/teacher/dashboard_screen.dart';
import 'screens/teacher/calendar_screen.dart';
import 'screens/teacher/lesson_detail_screen.dart';
import 'screens/teacher/lesson_attendance_screen.dart';
import 'screens/teacher/attendance_screen.dart';
import 'screens/teacher/leave_registration_screen.dart';
import 'screens/teacher/reports_screen.dart';
import 'auth/login_screen.dart';

import 'providers/lesson_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Khởi tạo định dạng ngày tháng tiếng Việt
    await initializeDateFormatting('vi', null);

    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing app: $e');
    // Vẫn chạy app ngay cả khi Firebase lỗi
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'TLU Schedule Management',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6B46C1),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            routerConfig: _router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

// ================= GoRouter =================
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Kiểm tra authentication status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentPath = state.uri.path;
    
    // Nếu chưa đăng nhập và không phải trang login
    if (!authProvider.isAuthenticated && currentPath != '/login') {
      return '/login';
    }
    
    // Nếu đã đăng nhập và đang ở trang login
    if (authProvider.isAuthenticated && currentPath == '/login') {
      return '/dashboard';
    }
    
    return null; // Không redirect
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Lỗi: ${state.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/lesson-attendance/:lessonId',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId']!;
        return LessonAttendanceScreen(lessonId: lessonId);
      },
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
