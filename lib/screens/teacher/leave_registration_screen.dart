import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lesson_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../models/lesson.dart';

class LeaveRegistrationScreen extends StatefulWidget {
  const LeaveRegistrationScreen({super.key});

  @override
  State<LeaveRegistrationScreen> createState() => _LeaveRegistrationScreenState();
}

class _LeaveRegistrationScreenState extends State<LeaveRegistrationScreen> {
  String _selectedLessonId = '';
  String _registrationType = 'leave';
  String _selectedReason = '';
  DateTime? _makeupDate;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _reasons = [
    'Ốm đau',
    'Công tác',
    'Gia đình có việc',
    'Thời tiết xấu',
    'Lý do khác',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: const Text('Đăng ký nghỉ dạy'),
        elevation: 0,
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          final upcomingLessons = lessonProvider.getUpcomingLessons();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Đăng ký nghỉ dạy / Dạy bù',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Đăng ký nghỉ dạy hoặc dạy bù cho các buổi học',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Registration Form
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
                        'Thông tin đăng ký',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Select Lesson
                      const Text(
                        'Chọn buổi học',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedLessonId.isEmpty ? null : _selectedLessonId,
                        decoration: const InputDecoration(
                          hintText: 'Chọn buổi học cần đăng ký',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6B46C1)),
                          ),
                        ),
                        items: upcomingLessons.map((lesson) {
                          return DropdownMenuItem(
                            value: lesson.id,
                            child: Text(
                              '${lesson.subject} - ${DateFormat('dd/MM/yyyy').format(lesson.date)} (${lesson.startTime}-${lesson.endTime})',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLessonId = value ?? '';
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // Registration Type
                      const Text(
                        'Loại đăng ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Nghỉ dạy'),
                              value: 'leave',
                              groupValue: _registrationType,
                              onChanged: (value) {
                                setState(() {
                                  _registrationType = value!;
                                });
                              },
                              activeColor: const Color(0xFF6B46C1),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Dạy bù'),
                              value: 'makeup',
                              groupValue: _registrationType,
                              onChanged: (value) {
                                setState(() {
                                  _registrationType = value!;
                                });
                              },
                              activeColor: const Color(0xFF6B46C1),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Reason
                      const Text(
                        'Lý do',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedReason.isEmpty ? null : _selectedReason,
                        decoration: const InputDecoration(
                          hintText: 'Chọn lý do',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6B46C1)),
                          ),
                        ),
                        items: _reasons.map((reason) {
                          return DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReason = value ?? '';
                          });
                        },
                      ),

                      // Makeup Date (only for makeup registration)
                      if (_registrationType == 'makeup') ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Ngày bù (nếu đăng ký dạy bù)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _makeupDate = date;
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
                                    _makeupDate != null
                                        ? DateFormat('dd/MM/yyyy').format(_makeupDate!)
                                        : 'Chọn ngày bù',
                                    style: TextStyle(
                                      color: _makeupDate != null
                                          ? const Color(0xFF374151)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const Icon(Icons.calendar_today, color: Color(0xFF6B46C1)),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Additional Notes
                      const Text(
                        'Ghi chú bổ sung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Nhập ghi chú bổ sung (nếu có)',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6B46C1)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedLessonId.isEmpty || _selectedReason.isEmpty
                              ? null
                              : () {
                            _submitRegistration();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Gửi đăng ký',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Requests
                if (lessonProvider.leaveRequests.isNotEmpty) ...[
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
                          'Đăng ký gần đây',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...lessonProvider.leaveRequests.take(3).map((request) {
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
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }

  void _submitRegistration() {
    if (_registrationType == 'makeup' && _makeupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày bù'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final leaveRequest = LeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: _selectedLessonId,
      type: _registrationType,
      reason: _selectedReason,
      makeupDate: _makeupDate,
      startTime: context.read<LessonProvider>().getLessonById(_selectedLessonId)?.startTime ?? '',
      endTime: context.read<LessonProvider>().getLessonById(_selectedLessonId)?.endTime ?? '',
      additionalNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    context.read<LessonProvider>().submitLeaveRequest(leaveRequest);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi đăng ký thành công'),
        backgroundColor: Colors.green,
      ),
    );

    // Reset form
    setState(() {
      _selectedLessonId = '';
      _registrationType = 'leave';
      _selectedReason = '';
      _makeupDate = null;
      _notesController.clear();
    });
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