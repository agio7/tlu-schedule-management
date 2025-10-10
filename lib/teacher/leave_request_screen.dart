import 'package:flutter/material.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedClass = 'CNTT01';
  String _selectedSubject = 'Lập trình Java';
  DateTime _selectedDate = DateTime.now();
  String _selectedReason = 'Bệnh';
  String _selectedTimeSlot = '08:00-10:00';
  bool _isUrgent = false;

  final List<String> _reasons = [
    'Bệnh',
    'Công việc cá nhân',
    'Hội nghị/Hội thảo',
    'Nghỉ phép',
    'Lý do khác',
  ];

  final List<String> _timeSlots = [
    '08:00-10:00',
    '10:30-12:30',
    '14:00-16:00',
    '16:30-18:30',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký nghỉ dạy'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Information
              _buildSectionHeader('Thông tin lớp học'),
              _buildClassInfoCard(),
              const SizedBox(height: 24),

              // Leave Details
              _buildSectionHeader('Chi tiết nghỉ dạy'),
              _buildLeaveDetailsCard(),
              const SizedBox(height: 24),

              // Reason and Notes
              _buildSectionHeader('Lý do và ghi chú'),
              _buildReasonCard(),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitLeaveRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Gửi đơn nghỉ dạy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recent Requests
              _buildSectionHeader('Đơn nghỉ dạy gần đây'),
              _buildRecentRequests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildClassInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.class_, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Text(
                  'Lớp: $_selectedClass',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.book, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Text(
                  'Môn: $_selectedSubject',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Text(
                  'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.edit),
                  label: const Text('Thay đổi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Time Slot
            DropdownButtonFormField<String>(
              value: _selectedTimeSlot,
              decoration: const InputDecoration(
                labelText: 'Ca học',
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
              ),
              items: _timeSlots.map((slot) {
                return DropdownMenuItem(
                  value: slot,
                  child: Text(slot),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimeSlot = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Urgent Checkbox
            CheckboxListTile(
              title: const Text('Đơn nghỉ khẩn cấp'),
              subtitle: const Text('Cần phê duyệt ngay lập tức'),
              value: _isUrgent,
              onChanged: (value) {
                setState(() {
                  _isUrgent = value!;
                });
              },
              activeColor: const Color(0xFF1976D2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Reason Dropdown
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: const InputDecoration(
                labelText: 'Lý do nghỉ dạy',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
              items: _reasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Reason Details
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Chi tiết lý do',
                hintText: 'Mô tả chi tiết lý do nghỉ dạy...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập chi tiết lý do';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Additional Notes
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú thêm (tùy chọn)',
                hintText: 'Thông tin bổ sung...',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequests() {
    final recentRequests = [
      {
        'date': '15/01/2024',
        'class': 'CNTT02',
        'subject': 'Cơ sở dữ liệu',
        'reason': 'Bệnh',
        'status': 'approved',
        'timeSlot': '10:30-12:30',
      },
      {
        'date': '12/01/2024',
        'class': 'CNTT01',
        'subject': 'Lập trình Java',
        'reason': 'Hội nghị',
        'status': 'pending',
        'timeSlot': '08:00-10:00',
      },
      {
        'date': '10/01/2024',
        'class': 'CNTT03',
        'subject': 'Mạng máy tính',
        'reason': 'Công việc cá nhân',
        'status': 'rejected',
        'timeSlot': '14:00-16:00',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentRequests.length,
      itemBuilder: (context, index) {
        final request = recentRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, String> request) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (request['status']) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Đã duyệt';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Chờ duyệt';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Từ chối';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Không xác định';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text('${request['class']} - ${request['subject']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ngày: ${request['date']} - ${request['timeSlot']}'),
            Text('Lý do: ${request['reason']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => _showRequestDetails(request),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitLeaveRequest() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận đơn nghỉ dạy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lớp: $_selectedClass'),
              Text('Môn: $_selectedSubject'),
              Text('Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              Text('Ca: $_selectedTimeSlot'),
              Text('Lý do: $_selectedReason'),
              if (_isUrgent) const Text('Khẩn cấp: Có'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessMessage();
              },
              child: const Text('Gửi đơn'),
            ),
          ],
        ),
      );
    }
  }

  void _showRequestDetails(Map<String, String> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết đơn nghỉ dạy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lớp: ${request['class']}'),
            Text('Môn: ${request['subject']}'),
            Text('Ngày: ${request['date']}'),
            Text('Ca: ${request['timeSlot']}'),
            Text('Lý do: ${request['reason']}'),
            Text('Trạng thái: ${request['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi đơn nghỉ dạy thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

