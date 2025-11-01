import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../models/course_sections.dart';
import '../../../models/schedules.dart';
import '../../../services/schedule_generator_service.dart';
import 'import_schedule_screen.dart';

class CourseSectionsScreen extends StatefulWidget {
  const CourseSectionsScreen({super.key});

  @override
  State<CourseSectionsScreen> createState() => _CourseSectionsScreenState();
}

class _CourseSectionsScreenState extends State<CourseSectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.loadCourseSections();
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Phân công Giảng dạy'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm phân công...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          // Nút thêm mới
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm Phân công'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _navigateToImport,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Danh sách
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final courseSections = adminProvider.courseSections;
        final filteredSections = _searchController.text.isEmpty
            ? courseSections
            : courseSections.where((section) =>
                section.id.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                section.scheduleString.toLowerCase().contains(_searchController.text.toLowerCase())
              ).toList();

        if (filteredSections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'Chưa có phân công nào'
                      : 'Không tìm thấy phân công nào',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (_searchController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddDialog,
                    child: const Text('Thêm phân công đầu tiên'),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredSections.length,
          itemBuilder: (context, index) {
            final section = filteredSections[index];
            return _buildCourseSectionCard(section);
          },
        );
      },
    );
  }

  Widget _buildCourseSectionCard(CourseSections section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          'Phân công ${section.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${section.totalSessions} buổi - ${section.scheduleString}',
          style: const TextStyle(color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ID:', section.id),
                _buildInfoRow('Môn học:', section.subjectId),
                _buildInfoRow('Giảng viên:', section.teacherId),
                _buildInfoRow('Lớp học:', section.classroomId),
                _buildInfoRow('Phòng học:', section.roomId),
                _buildInfoRow('Học kỳ:', section.semesterId),
                _buildInfoRow('Tổng buổi:', section.totalSessions.toString()),
                _buildInfoRow('Lịch học:', section.scheduleString),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _generateSchedules(section),
                        icon: const Icon(Icons.schedule),
                        label: const Text('Sinh Lịch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewSchedules(section),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Xem Lịch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editCourseSection(section),
                        icon: const Icon(Icons.edit),
                        label: const Text('Chỉnh sửa'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteCourseSection(section),
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    // TODO: Implement add course section dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm phân công sẽ được implement')),
    );
  }

  void _navigateToImport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImportScheduleScreen(),
      ),
    );
  }

  void _generateSchedules(CourseSections section) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await ScheduleGeneratorService.generateSchedulesFromCourseSection(section.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã sinh thành công lịch học cho ${section.totalSessions} buổi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi sinh lịch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _viewSchedules(CourseSections section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulesViewScreen(courseSectionId: section.id),
      ),
    );
  }

  void _editCourseSection(CourseSections section) {
    // TODO: Implement edit course section
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chỉnh sửa sẽ được implement')),
    );
  }

  void _deleteCourseSection(CourseSections section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phân công "${section.id}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement delete course section
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng xóa sẽ được implement')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class SchedulesViewScreen extends StatefulWidget {
  final String courseSectionId;
  
  const SchedulesViewScreen({
    super.key,
    required this.courseSectionId,
  });

  @override
  State<SchedulesViewScreen> createState() => _SchedulesViewScreenState();
}

class _SchedulesViewScreenState extends State<SchedulesViewScreen> {
  List<Schedules> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load schedules from database
      // final schedules = await ScheduleService.getSchedulesByCourseSection(widget.courseSectionId);
      // setState(() {
      //   _schedules = schedules;
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải lịch học: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Học Chi Tiết'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? const Center(
                  child: Text('Chưa có lịch học nào được sinh'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(schedule.status),
                          child: Text(
                            schedule.sessionNumber.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text('Buổi ${schedule.sessionNumber}'),
                        subtitle: Text(
                          '${_formatDateTime(schedule.startTime)} - ${_formatDateTime(schedule.endTime)}',
                        ),
                        trailing: Chip(
                          label: Text(_getStatusText(schedule.status)),
                          backgroundColor: _getStatusColor(schedule.status).withOpacity(0.2),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return Colors.blue;
      case ScheduleStatus.completed:
        return Colors.green;
      case ScheduleStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return 'Đã lên lịch';
      case ScheduleStatus.completed:
        return 'Đã hoàn thành';
      case ScheduleStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
