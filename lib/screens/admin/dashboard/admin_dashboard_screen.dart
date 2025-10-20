import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../models/leave_request.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadDashboardStats();
      adminProvider.loadPendingLeaveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading && adminProvider.dashboardStats.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (adminProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${adminProvider.errorMessage}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      adminProvider.loadDashboardStats();
                      adminProvider.loadPendingLeaveRequests();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với thông tin admin
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 30,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tình hình hôm nay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phòng Đào Tạo - TLU',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Thông báo
                        },
                        icon: const Icon(Icons.notifications, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Thẻ Thống kê nhanh từ dữ liệu thật
                const Text(
                  'Thống kê nhanh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildStatCard(
                      'Yêu cầu chờ duyệt',
                      '${adminProvider.dashboardStats['pendingLeaveRequests'] ?? 0}',
                      Icons.pending_actions,
                      Colors.red,
                      'Cần xử lý gấp',
                    ),
                    _buildStatCard(
                      'Tổng giảng viên',
                      '${adminProvider.dashboardStats['totalTeachers'] ?? 0}',
                      Icons.person,
                      Colors.green,
                      'Đã đăng ký',
                    ),
                    _buildStatCard(
                      'Tổng lịch trình',
                      '${adminProvider.dashboardStats['totalSchedules'] ?? 0}',
                      Icons.trending_up,
                      Colors.blue,
                      'Trong hệ thống',
                    ),
                    _buildStatCard(
                      'Tổng phòng học',
                      '${adminProvider.dashboardStats['totalRooms'] ?? 0}',
                      Icons.schedule,
                      Colors.orange,
                      'Có sẵn',
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Yêu cầu cần xử lý gấp từ dữ liệu thật
                const Text(
                  'Yêu cầu cần xử lý gấp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Hiển thị danh sách yêu cầu nghỉ phép thật
                if (adminProvider.pendingLeaveRequests.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: Colors.green[300],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Không có yêu cầu nào chờ duyệt',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...adminProvider.pendingLeaveRequests.take(3).map((request) => 
                    _buildQuickRequestCardFromData(request, context)
                  ).toList(),
                
                const SizedBox(height: 24),
                
                // Cảnh báo Tiến độ (có thể thêm logic thật sau)
                const Text(
                  'Cảnh báo Tiến độ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildAlertCard(
                  'Có ${adminProvider.dashboardStats['pendingLeaveRequests'] ?? 0} yêu cầu nghỉ phép chờ duyệt',
                  Icons.warning,
                  Colors.orange,
                ),
                _buildAlertCard(
                  'Tổng ${adminProvider.dashboardStats['totalSchedules'] ?? 0} lịch trình trong hệ thống',
                  Icons.info,
                  Colors.blue,
                ),
                if ((adminProvider.dashboardStats['pendingLeaveRequests'] ?? 0) > 5)
                  _buildAlertCard(
                    'Có nhiều yêu cầu nghỉ phép cần xử lý',
                    Icons.error,
                    Colors.red,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRequestCardFromData(LeaveRequest request, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF1976D2),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yêu cầu nghỉ phép #${request.id.length > 8 ? request.id.substring(0, 8) : request.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Giảng viên: ${request.teacherId}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.red[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ngày tạo: ${_formatDate(request.createdAt)}',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info, size: 16, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lý do: ${request.reason}',
                    style: TextStyle(color: Colors.orange[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRequest(request.id, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Duyệt'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _rejectRequest(request.id, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: IconButton(
          onPressed: () {
            // TODO: Xem chi tiết cảnh báo
          },
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _approveRequest(String requestId, BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.updateLeaveRequestStatus(requestId, 'approved', 'Đã duyệt bởi admin');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã duyệt yêu cầu')),
    );
  }

  void _rejectRequest(String requestId, BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.updateLeaveRequestStatus(requestId, 'rejected', 'Từ chối bởi admin');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã từ chối yêu cầu')),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hành động nhanh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF1976D2)),
              title: const Text('Nhập/Sinh lịch trình'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to schedule import
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFF1976D2)),
              title: const Text('Tạo thông báo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create notification
              },
            ),
          ],
        ),
      ),
    );
  }
}