import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/lesson.dart';
import '../providers/lesson_provider.dart';

class LeaveRegistrationTab extends StatefulWidget {
  final Lesson lesson;

  const LeaveRegistrationTab({
    super.key,
    required this.lesson,
  });

  @override
  State<LeaveRegistrationTab> createState() => _LeaveRegistrationTabState();
}

class _LeaveRegistrationTabState extends State<LeaveRegistrationTab> {
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registration Form
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đăng ký nghỉ dạy / dạy bù',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
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

                // Start Time
                const Text(
                  'Giờ bắt đầu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    widget.lesson.startTime,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // End Time
                const Text(
                  'Giờ kết thúc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    widget.lesson.endTime,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),

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
                    onPressed: _selectedReason.isEmpty
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
        ],
      ),
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
      lessonId: widget.lesson.id,
      type: _registrationType,
      reason: _selectedReason,
      makeupDate: _makeupDate,
      startTime: widget.lesson.startTime,
      endTime: widget.lesson.endTime,
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
      _registrationType = 'leave';
      _selectedReason = '';
      _makeupDate = null;
      _notesController.clear();
    });
  }
}