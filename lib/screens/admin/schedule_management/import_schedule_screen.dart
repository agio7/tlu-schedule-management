import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../services/file_import_service.dart';
import '../../../services/template_service.dart';
import '../../../models/course_sections.dart';

class ImportScheduleScreen extends StatefulWidget {
  const ImportScheduleScreen({super.key});

  @override
  State<ImportScheduleScreen> createState() => _ImportScheduleScreenState();
}

class _ImportScheduleScreenState extends State<ImportScheduleScreen> {
  bool _isLoading = false;
  String? _error;
  List<List<dynamic>>? _previewData;
  List<CourseSections>? _parsedSections;
  bool _autoGenerateSchedules = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Phân công từ File'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadTemplate,
            tooltip: 'Tải template CSV',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import Phân công Giảng dạy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn file CSV hoặc Excel để import phân công giảng dạy và tự động sinh lịch học',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _selectFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Chọn File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _downloadTemplate,
                          icon: const Icon(Icons.download),
                          label: const Text('Template'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Options
            if (_previewData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tùy chọn Import',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Tự động sinh lịch học'),
                        subtitle: const Text('Sau khi import sẽ tự động sinh Schedules'),
                        value: _autoGenerateSchedules,
                        onChanged: (value) {
                          setState(() {
                            _autoGenerateSchedules = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Preview
            if (_previewData != null) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Preview Dữ liệu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_previewData!.length - 1} dòng dữ liệu',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: _previewData!.first
                                    .map((header) => DataColumn(
                                          label: Text(
                                            header.toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ))
                                    .toList(),
                                rows: _previewData!
                                    .skip(1)
                                    .take(10) // Chỉ hiển thị 10 dòng đầu
                                    .map((row) => DataRow(
                                          cells: row
                                              .map((cell) => DataCell(
                                                    Text(cell?.toString() ?? ''),
                                                  ))
                                              .toList(),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        if (_previewData!.length > 11)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '... và ${_previewData!.length - 11} dòng khác',
                              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            if (_previewData != null) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearPreview,
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _importData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Import & Sinh Lịch'),
                    ),
                  ),
                ],
              ),
            ],

            // Error display
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _previewData = null;
      _parsedSections = null;
    });

    try {
      final result = await FileImportService.importFileAndCreateCourseSections(
        autoGenerateSchedules: false, // Chỉ preview, chưa import
      );

      if (result.success) {
        setState(() {
          _previewData = _generatePreviewData(result.courseSections!);
          _parsedSections = result.courseSections;
        });
      } else {
        setState(() {
          _error = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi chọn file: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _importData() async {
    if (_parsedSections == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await FileImportService.importFileAndCreateCourseSections(
        autoGenerateSchedules: _autoGenerateSchedules,
      );

      if (result.success) {
        // Refresh admin provider
        if (mounted) {
          final adminProvider = Provider.of<AdminProvider>(context, listen: false);
          await adminProvider.loadCourseSections();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _error = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi import: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearPreview() {
    setState(() {
      _previewData = null;
      _parsedSections = null;
      _error = null;
    });
  }

  void _downloadTemplate() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await TemplateService.downloadCSVTemplate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template CSV đã được tải xuống thư mục Downloads'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải template: $e'),
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

  List<List<dynamic>> _generatePreviewData(List<CourseSections> sections) {
    final headers = [
      'subjectId',
      'teacherId',
      'classroomId',
      'roomId',
      'semesterId',
      'totalSessions',
      'scheduleString',
    ];

    final rows = sections.map((section) => [
      section.subjectId,
      section.teacherId,
      section.classroomId,
      section.roomId,
      section.semesterId,
      section.totalSessions,
      section.scheduleString,
    ]).toList();

    return [headers, ...rows];
  }
}
