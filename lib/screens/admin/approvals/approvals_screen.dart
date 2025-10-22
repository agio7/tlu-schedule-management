import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../models/leave_requests.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadLeaveRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[50],
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1976D2),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1976D2),
            tabs: const [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: 'Chờ duyệt',
              ),
              Tab(
                icon: Icon(Icons.check_circle),
                text: 'Đã duyệt',
              ),
              Tab(
                icon: Icon(Icons.cancel),
                text: 'Đã từ chối',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPendingTab(),
              _buildApprovedTab(),
              _buildRejectedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adminProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${adminProvider.errorMessage}',
                  style: TextStyle(fontSize: 16, color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => adminProvider.loadLeaveRequests(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final pendingRequests = adminProvider.getLeaveRequestsByStatus('pending');
        
        if (pendingRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                const SizedBox(height: 16),
                Text(
                  'Không có yêu cầu nào chờ duyệt',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingRequests.length,
          itemBuilder: (context, index) {
            final request = pendingRequests[index];
            return _buildRequestCardFromData(request, context, 'pending');
          },
        );
      },
    );
  }

  Widget _buildApprovedTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final approvedRequests = adminProvider.getLeaveRequestsByStatus('approved');
        
        if (approvedRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                const SizedBox(height: 16),
                Text(
                  'Không có yêu cầu nào đã duyệt',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: approvedRequests.length,
          itemBuilder: (context, index) {
            final request = approvedRequests[index];
            return _buildRequestCardFromData(request, context, 'approved');
          },
        );
      },
    );
  }

  Widget _buildRejectedTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final rejectedRequests = adminProvider.getLeaveRequestsByStatus('rejected');
        
        if (rejectedRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Không có yêu cầu nào bị từ chối',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rejectedRequests.length,
          itemBuilder: (context, index) {
            final request = rejectedRequests[index];
            return _buildRequestCardFromData(request, context, 'rejected');
          },
        );
      },
    );
  }

  Widget _buildRequestCardFromData(LeaveRequests request, BuildContext context, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với thông tin giảng viên
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
                        'Yêu cầu #${request.id.length > 8 ? request.id.substring(0, 8) : request.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Giảng viên: ${request.teacherId}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Thông tin nghỉ
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
            
            // Thông tin lý do
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
            
            // Thông tin trạng thái
            if (status == 'approved' && request.approvedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Đã duyệt: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ],
                ),
              ),
            if (status == 'rejected')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, size: 16, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Đã từ chối: ${_formatDate(request.updatedAt)}',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ],
                    ),
                    if (request.approverNotes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Lý do: ${request.approverNotes}',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            
            // Nút hành động
            if (status == 'pending') ...[
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
                      onPressed: () => _showRejectionDialog(request.id, context),
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
          ],
        ),
      ),
    );
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
        return 'CHỜ DUYỆT';
      case 'approved':
        return 'ĐÃ DUYỆT';
      case 'rejected':
        return 'TỪ CHỐI';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _approveRequest(String requestId, BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.updateLeaveRequestStatus(requestId, 'approved', 'Đã duyệt bởi admin');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã duyệt yêu cầu'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRejectionDialog(String requestId, BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối yêu cầu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhập lý do từ chối:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do từ chối...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              adminProvider.updateLeaveRequestStatus(
                requestId, 
                'rejected', 
                reasonController.text.isNotEmpty ? reasonController.text : 'Từ chối bởi admin'
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã từ chối yêu cầu'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}



