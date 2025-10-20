import 'package:flutter/material.dart';
import 'crud/crud_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý Dữ liệu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quản lý các danh mục dữ liệu gốc của hệ thống',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildManagementCard(
                  'Quản lý Giảng viên',
                  'Quản lý thông tin giảng viên, phân công giảng dạy',
                  Icons.person,
                  Colors.blue,
                  () => _navigateToCRUD(context, 'Giảng viên'),
                ),
                _buildManagementCard(
                  'Quản lý Môn học',
                  'Quản lý danh sách môn học, chương trình đào tạo',
                  Icons.book,
                  Colors.green,
                  () => _navigateToCRUD(context, 'Môn học'),
                ),
                _buildManagementCard(
                  'Quản lý Lớp học',
                  'Quản lý thông tin lớp học, sinh viên',
                  Icons.school,
                  Colors.orange,
                  () => _navigateToCRUD(context, 'Lớp học'),
                ),
                _buildManagementCard(
                  'Quản lý Phòng học',
                  'Quản lý thông tin phòng học, thiết bị',
                  Icons.room,
                  Colors.purple,
                  () => _navigateToCRUD(context, 'Phòng học'),
                ),
                _buildManagementCard(
                  'Quản lý Khoa/Viện',
                  'Quản lý thông tin các khoa, viện trong trường',
                  Icons.business,
                  Colors.teal,
                  () => _navigateToCRUD(context, 'Khoa/Viện'),
                ),
                _buildManagementCard(
                  'Quản lý Học kỳ',
                  'Quản lý thông tin học kỳ, năm học',
                  Icons.calendar_month,
                  Colors.indigo,
                  () => _navigateToCRUD(context, 'Học kỳ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
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

  void _navigateToCRUD(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CRUDScreen(type: type),
      ),
    );
  }
}




