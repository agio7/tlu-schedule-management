import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/lesson_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Setup real-time data streams
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.userData?.id != null) {
        context.read<LessonProvider>().setupRealtimeStreams(authProvider.userData!.id);
      } else {
        context.read<LessonProvider>().setupAllRealtimeStreams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          final todayLessons = lessonProvider.getTodayLessons();
          
          
          // Show loading indicator
          if (lessonProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu...'),
                ],
              ),
            );
          }
          
          // Show error message
          if (lessonProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    lessonProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      lessonProvider.loadLessons();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // User Info Row
                    Row(
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final userName = authProvider.userData?.fullName ?? 'Giảng viên';
                            final initials = userName.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
                            return CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final userName = authProvider.userData?.fullName ?? 'Giảng viên';
                              final role = authProvider.userData?.role ?? 'teacher';
                              final roleText = role == 'teacher' ? 'Giảng viên' : 'Quản trị viên';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Xin chào, $userName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    roleText,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            context.go('/seed-data');
                          },
                          icon: const Icon(Icons.data_usage, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () async {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            await authProvider.signOut();
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // App Logo and Title
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'TLU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Hệ thống quản lý lịch trình giảng dạy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Trường Đại Học Thủy Lợi',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


                    // Today's Schedule Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B46C1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Lịch dạy hôm nay (${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Lessons List
                          Container(
                            height: 400, // Fixed height instead of Expanded
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: todayLessons.isEmpty
                                ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Không có buổi học nào hôm nay',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: todayLessons.length,
                              itemBuilder: (context, index) {
                                final lesson = todayLessons[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: LessonCard(
                                    lesson: lesson,
                                    onTap: () {
                                      context.go('/lesson-detail/${lesson.id}');
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }
}