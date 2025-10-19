import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/shared/login_screen.dart';
import 'screens/shared/role_based_dashboard.dart';
import 'providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Schedule Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2), // TLU Blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (authProvider.isAuthenticated && authProvider.userData != null) {
            return RoleBasedDashboard(
              userRole: authProvider.userData!.role,
              userName: authProvider.userData!.fullName,
              userEmail: authProvider.userData!.email,
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}



