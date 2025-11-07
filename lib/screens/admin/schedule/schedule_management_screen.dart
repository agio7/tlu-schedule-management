import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../../providers/admin_provider.dart';
import '../../../models/semesters.dart';
import '../../../services/csv_import_service.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  String _selectedTeacher = 'Tất cả';
  String _selectedClass = 'Tất cả';
  String _selectedSubject = 'Tất cả';
  String _selectedRoom = 'Tất cả';
  DateTime _selectedDate = DateTime.now();
  Semesters? _selectedSemester;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  void _loadSemesters() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.loadSemesters();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bộ lọc
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown('Giảng viên', _selectedTeacher, [
                      'Tất cả',
                    ], (value) {
                      setState(() => _selectedTeacher = value!);
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterDropdown('Lớp học', _selectedClass, [
                      'Tất cả',
                    ], (value) {
                      setState(() => _selectedClass = value!);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown('Môn học', _selectedSubject, [
                      'Tất cả',
                    ], (value) {
                      setState(() => _selectedSubject = value!);
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterDropdown('Phòng học', _selectedRoom, [
                      'Tất cả',
                    ], (value) {
                      setState(() => _selectedRoom = value!);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Header với dropdown Học kỳ và nút Import/Sinh lịch
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lịch trình ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () => _showImportDialog(),
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('Import/Sinh lịch', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dropdown chọn học kỳ
                  Row(
                    children: [
                      const Text(
                        'Học kỳ: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<Semesters>(
                          value: _selectedSemester,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            hintText: 'Chọn học kỳ *',
                            errorText: _selectedSemester == null ? 'Vui lòng chọn học kỳ' : null,
                          ),
                          items: adminProvider.semesters.map((semester) {
                            return DropdownMenuItem<Semesters>(
                              value: semester,
                              child: Text(
                                semester.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (semester) {
                            setState(() {
                              _selectedSemester = semester;
                            });
                            if (semester != null) {
                              print('✅ Đã chọn học kỳ: ${semester.name}');
                              print('   - ID: ${semester.id}');
                              print('   - Start Date: ${semester.startDate}');
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Vui lòng chọn học kỳ';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        
        // Lịch trình (không còn dữ liệu ảo)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.event_busy, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Chưa có lịch trình', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11, // Giảm từ 12 xuống 11
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 3), // Giảm từ 4 xuống 3
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true, // Thêm để tránh overflow
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Giảm padding
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6), // Giảm border radius
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item, 
              style: const TextStyle(fontSize: 12), // Giảm từ 14 xuống 12
              overflow: TextOverflow.ellipsis, // Thêm overflow handling
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, String> schedule, BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (schedule['status']) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Đã dạy';
        statusIcon = Icons.check_circle;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusText = 'Đã nghỉ';
        statusIcon = Icons.cancel;
        break;
      case 'makeup':
        statusColor = Colors.orange;
        statusText = 'Dạy bù';
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Chưa dạy';
        statusIcon = Icons.schedule;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          '${schedule['time']} - ${schedule['subject']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GV: ${schedule['teacher']}'),
            Text('Lớp: ${schedule['class']} - Phòng: ${schedule['room']}'),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Chỉnh sửa'),
            ),
            const PopupMenuItem(
              value: 'view',
              child: Text('Xem chi tiết'),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditScheduleDialog(schedule, context);
            }
          },
        ),
        onTap: () => _showEditScheduleDialog(schedule, context),
      ),
    );
  }

  void _showImportDialog() {
    if (_selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn học kỳ trước khi nhập file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => _ImportCsvDialog(
        dialogContext: dialogContext,
        selectedSemester: _selectedSemester!,
      ),
    );
  }

  void _showEditScheduleDialog(Map<String, String> schedule, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa lịch trình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thời gian: ${schedule['time']}'),
            Text('Môn: ${schedule['subject']}'),
            Text('Lớp: ${schedule['class']}'),
            const SizedBox(height: 16),
            const Text('Chọn giảng viên mới:'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C'].map((teacher) => 
                DropdownMenuItem(value: teacher, child: Text(teacher))
              ).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 8),
            const Text('Chọn phòng mới:'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['A101', 'A102', 'A103'].map((room) => 
                DropdownMenuItem(value: room, child: Text(room))
              ).toList(),
              onChanged: (value) {},
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật lịch trình')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

class _ImportCsvDialog extends StatefulWidget {
  final BuildContext dialogContext;
  final Semesters selectedSemester;
  
  const _ImportCsvDialog({
    required this.dialogContext,
    required this.selectedSemester,
  });

  @override
  State<_ImportCsvDialog> createState() => _ImportCsvDialogState();
}

class _ImportCsvDialogState extends State<_ImportCsvDialog> {
  String? _selectedFile;
  String? _csvContent;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        // Đọc nội dung file CSV
        final bytes = result.files.single.bytes!;
        final content = utf8.decode(bytes);
        
        setState(() {
          _selectedFile = result.files.single.name;
          _csvContent = content;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi chọn file: $e';
      });
    }
  }

  Future<void> _confirmImport() async {
    if (_csvContent == null || _csvContent!.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng chọn file CSV';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await CsvImportService.importCsvAndGenerateSchedules(
        csvContent: _csvContent!,
        semesterId: widget.selectedSemester.id,
        semesterStartDate: widget.selectedSemester.startDate,
      );

      if (mounted) {
        if (result['success'] == true) {
          Navigator.pop(widget.dialogContext);
          ScaffoldMessenger.of(widget.dialogContext).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Nhập thành công!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Lỗi khi nhập file';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi nhập file: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import lịch trình từ CSV'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hiển thị học kỳ đã chọn
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Học kỳ đã chọn:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.selectedSemester.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Nút chọn file CSV
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_selectedFile == null ? 'Chọn File CSV' : 'Chọn File Khác'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            // Hiển thị tên file đã chọn
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Hiển thị lỗi
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            Text(
              'Yêu cầu file CSV có các cột: MaLHP, MaMonHoc, MaGV, MaLopSH, MaPhong, SoBuoi, LichHocChuoi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(widget.dialogContext),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _csvContent == null) ? null : _confirmImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Xác nhận Nhập'),
        ),
      ],
    );
  }
}

