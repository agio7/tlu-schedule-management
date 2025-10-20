import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedSemester = 'Học kỳ 1 - 2024';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Báo cáo & Thống kê',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kết xuất và thống kê dữ liệu để thanh toán hoặc đánh giá',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Bộ lọc thời gian
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bộ lọc thời gian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Từ ngày'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Đến ngày'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSemester,
                    decoration: const InputDecoration(
                      labelText: 'Hoặc chọn học kỳ',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Học kỳ 1 - 2024',
                      'Học kỳ 2 - 2024',
                      'Học kỳ hè - 2024',
                    ].map((semester) => DropdownMenuItem(
                      value: semester,
                      child: Text(semester),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSemester = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Danh sách loại báo cáo
          const Text(
            'Loại báo cáo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView(
              children: [
                _buildReportCard(
                  'Báo cáo tiến độ giảng dạy',
                  'Hoàn thành, còn lại, nghỉ, bù',
                  Icons.trending_up,
                  Colors.blue,
                  () => _showReportPreview('Tiến độ giảng dạy'),
                ),
                _buildReportCard(
                  'Thống kê giờ giảng',
                  'Phục vụ thanh toán lương giảng viên',
                  Icons.access_time,
                  Colors.green,
                  () => _showReportPreview('Giờ giảng'),
                ),
                _buildReportCard(
                  'Tổng hợp tình hình nghỉ - dạy bù',
                  'Thống kê các trường hợp nghỉ và dạy bù',
                  Icons.schedule,
                  Colors.orange,
                  () => _showReportPreview('Nghỉ - Dạy bù'),
                ),
                _buildReportCard(
                  'Báo cáo chuyên cần sinh viên',
                  'Thống kê điểm danh và chuyên cần',
                  Icons.people,
                  Colors.purple,
                  () => _showReportPreview('Chuyên cần sinh viên'),
                ),
                _buildReportCard(
                  'Báo cáo sử dụng phòng học',
                  'Thống kê tần suất sử dụng phòng',
                  Icons.room,
                  Colors.teal,
                  () => _showReportPreview('Sử dụng phòng học'),
                ),
                _buildReportCard(
                  'Báo cáo tổng hợp học kỳ',
                  'Tổng kết toàn bộ hoạt động học kỳ',
                  Icons.summarize,
                  Colors.indigo,
                  () => _showReportPreview('Tổng hợp học kỳ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showReportPreview(String reportType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Báo cáo: $reportType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thời gian: ${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}'),
            const SizedBox(height: 16),
            const Text('Dữ liệu mẫu:'),
            const SizedBox(height: 8),
            _buildSampleData(reportType),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportReport(reportType);
            },
            icon: const Icon(Icons.download),
            label: const Text('Kết xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleData(String reportType) {
    switch (reportType) {
      case 'Tiến độ giảng dạy':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• Tổng số buổi: 120'),
            const Text('• Đã dạy: 95 (79%)'),
            const Text('• Còn lại: 20 (17%)'),
            const Text('• Nghỉ: 3 (2%)'),
            const Text('• Dạy bù: 2 (2%)'),
          ],
        );
      case 'Giờ giảng':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• Nguyễn Văn A: 45 giờ'),
            const Text('• Trần Thị B: 38 giờ'),
            const Text('• Lê Văn C: 42 giờ'),
            const Text('• Tổng: 125 giờ'),
          ],
        );
      case 'Nghỉ - Dạy bù':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• Tổng yêu cầu nghỉ: 15'),
            const Text('• Đã duyệt: 12'),
            const Text('• Đã từ chối: 2'),
            const Text('• Chờ duyệt: 1'),
            const Text('• Đã dạy bù: 10'),
          ],
        );
      case 'Chuyên cần sinh viên':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• CNTT K66: 95%'),
            const Text('• CNTT K67: 92%'),
            const Text('• CNTT K68: 88%'),
            const Text('• Trung bình: 92%'),
          ],
        );
      case 'Sử dụng phòng học':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• A101: 85%'),
            const Text('• A102: 78%'),
            const Text('• A103: 92%'),
            const Text('• Trung bình: 85%'),
          ],
        );
      case 'Tổng hợp học kỳ':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• Tổng giảng viên: 25'),
            const Text('• Tổng lớp học: 45'),
            const Text('• Tổng môn học: 120'),
            const Text('• Tổng phòng học: 30'),
            const Text('• Tỷ lệ hoàn thành: 95%'),
          ],
        );
      default:
        return const Text('Không có dữ liệu');
    }
  }

  void _exportReport(String reportType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn định dạng xuất'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Xuất PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang xuất file PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Xuất Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang xuất file Excel...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}




