import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../models/leave_request.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'tháng';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Setup real-time data streams
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final lessonProvider = context.read<LessonProvider>();
      
      // Kiểm tra nếu chưa có dữ liệu, force load
      final hasData = lessonProvider.lessons.isNotEmpty;
      
      if (authProvider.userData?.id != null) {
        // Nếu chưa có dữ liệu, force setup lại
        if (!hasData) {
          lessonProvider.setupRealtimeStreams(authProvider.userData!.id, force: true);
        } else {
          lessonProvider.setupRealtimeStreams(authProvider.userData!.id);
        }
        
        // Fallback: Load data directly if no data after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (lessonProvider.lessons.isEmpty && !lessonProvider.isLoading) {
            lessonProvider.loadLessonsByTeacher(authProvider.userData!.id);
          }
        });
      } else {
        // Nếu chưa có dữ liệu, force setup lại
        if (!hasData) {
          lessonProvider.setupAllRealtimeStreams(force: true);
        } else {
          lessonProvider.setupAllRealtimeStreams();
        }
        
        // Fallback: Load all data if no data after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (lessonProvider.lessons.isEmpty && !lessonProvider.isLoading) {
            lessonProvider.loadLessons();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: const Text('Báo cáo thống kê'),
        elevation: 0,
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          final allLessons = lessonProvider.lessons;
          final completedLessons = lessonProvider.getCompletedLessons();
          final upcomingLessons = lessonProvider.getUpcomingLessons();
          final leaveRequests = lessonProvider.leaveRequests;

          // Debug: In thông tin requests
          print('📊 Reports Screen - Total requests: ${leaveRequests.length}');
          for (var req in leaveRequests) {
            print('   - Request ID: ${req.id}, Type: "${req.type}", Status: ${req.status}');
          }

          // Calculate statistics
          final totalLessons = allLessons.length;
          final completedCount = completedLessons.length;
          final upcomingCount = upcomingLessons.length;
          final leaveCount = leaveRequests.where((r) => r.type == 'leave').length;
          final makeupCount = leaveRequests.where((r) => r.type == 'makeup').length;
          
          print('📊 Leave count: $leaveCount, Makeup count: $makeupCount');

          // Calculate total teaching hours
          double totalHours = 0;
          for (final lesson in completedLessons) {
            final startTime = lesson.startTime.split(':');
            final endTime = lesson.endTime.split(':');
            final startMinutes = int.parse(startTime[0]) * 60 + int.parse(startTime[1]);
            final endMinutes = int.parse(endTime[0]) * 60 + int.parse(endTime[1]);
            totalHours += (endMinutes - startMinutes) / 60;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Chọn thời gian báo cáo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPeriod,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF6B46C1)),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'tháng', child: Text('Tháng')),
                                DropdownMenuItem(value: 'quý', child: Text('Quý')),
                                DropdownMenuItem(value: 'năm', child: Text('Năm')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeriod = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                DateTime? pickedDate;
                                if (_selectedPeriod == 'tháng') {
                                  pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                } else if (_selectedPeriod == 'quý') {
                                  // For quarter selection, we'll use month picker
                                  pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                } else {
                                  // For year selection
                                  pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                }

                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDate = pickedDate!;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getDateDisplayText(),
                                        style: const TextStyle(
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, color: Color(0xFF6B46C1)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Statistics Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      'Tổng buổi học',
                      totalLessons.toString(),
                      Icons.school,
                      const Color(0xFF6B46C1),
                    ),
                    _buildStatCard(
                      'Đã hoàn thành',
                      completedCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Sắp tới',
                      upcomingCount.toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Tổng giờ dạy',
                      '${totalHours.toStringAsFixed(1)}h',
                      Icons.access_time,
                      Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Leave Statistics
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thống kê nghỉ dạy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildLeaveStatItem(
                              'Buổi nghỉ',
                              leaveCount.toString(),
                              Icons.event_busy,
                              Colors.red,
                            ),
                          ),
                          Expanded(
                            child: _buildLeaveStatItem(
                              'Buổi bù',
                              makeupCount.toString(),
                              Icons.event_available,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Leave Requests
                if (leaveRequests.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đăng ký nghỉ gần đây',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...leaveRequests.map((request) {
                          final lesson = lessonProvider.getLessonById(request.lessonId);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  request.type == 'leave' ? Icons.event_busy : Icons.event_available,
                                  color: request.type == 'leave' ? Colors.red[600] : Colors.blue[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson?.subject ?? 'Buổi học không tìm thấy',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${request.type == 'leave' ? 'Nghỉ dạy' : 'Dạy bù'} - ${request.reason}',
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                        style: const TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(request.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(request.status),
                                    style: TextStyle(
                                      color: _getStatusColor(request.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDateDisplayText() {
    if (_selectedPeriod == 'tháng') {
      return DateFormat('MM/yyyy').format(_selectedDate);
    } else if (_selectedPeriod == 'quý') {
      final quarter = ((_selectedDate.month - 1) / 3).floor() + 1;
      return 'Q$quarter/${_selectedDate.year}';
    } else {
      return _selectedDate.year.toString();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }
}