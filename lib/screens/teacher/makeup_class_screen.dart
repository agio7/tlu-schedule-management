import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lesson_provider.dart';
import '../../widgets/bottom_navigation.dart';

class MakeupClassScreen extends StatefulWidget {
  const MakeupClassScreen({super.key});

  @override
  State<MakeupClassScreen> createState() => _MakeupClassScreenState();
}

class _MakeupClassScreenState extends State<MakeupClassScreen> {
  DateTime? _selectedDate;
  String _selectedSubject = '';
  String _selectedClass = '';
  String _selectedRoom = '';
  String _startTime = '';
  String _endTime = '';
  String _content = '';

  final List<String> _subjects = [
    'Phân tích thiết kế hệ thống',
    'Công nghệ phần mềm',
    'Lập trình web',
    'Cơ sở dữ liệu',
  ];

  final List<String> _classes = [
    'CNPM-K14',
    'CNTT-K14',
    'CNPM-K15',
    'CNTT-K15',
  ];

  final List<String> _rooms = [
    'A107',
    'A108',
    'B203',
    'C202',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: const Text('Dạy bù'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    Icons.event_available,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Đăng ký dạy bù',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Đăng ký buổi dạy bù cho sinh viên',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Form
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
                    'Thông tin buổi dạy bù',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Date Selection
                  const Text(
                    'Ngày dạy bù',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                          _selectedDate = date;
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
                              _selectedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                  : 'Chọn ngày dạy bù',
                              style: TextStyle(
                                color: _selectedDate != null
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
                  
                  const SizedBox(height: 16),
                  
                  // Subject Selection
                  const Text(
                    'Môn học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject.isEmpty ? null : _selectedSubject,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6B46C1)),
                      ),
                    ),
                    items: _subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value ?? '';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Class Selection
                  const Text(
                    'Lớp học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedClass.isEmpty ? null : _selectedClass,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6B46C1)),
                      ),
                    ),
                    items: _classes.map((className) {
                      return DropdownMenuItem(
                        value: className,
                        child: Text(className),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value ?? '';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Room Selection
                  const Text(
                    'Phòng học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRoom.isEmpty ? null : _selectedRoom,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6B46C1)),
                      ),
                    ),
                    items: _rooms.map((room) {
                      return DropdownMenuItem(
                        value: room,
                        child: Text(room),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRoom = value ?? '';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giờ bắt đầu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _startTime,
                              decoration: const InputDecoration(
                                hintText: '07:30',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF6B46C1)),
                                ),
                              ),
                              onChanged: (value) {
                                _startTime = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giờ kết thúc',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _endTime,
                              decoration: const InputDecoration(
                                hintText: '09:30',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF6B46C1)),
                                ),
                              ),
                              onChanged: (value) {
                                _endTime = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Content
                  const Text(
                    'Nội dung buổi học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _content,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Nhập nội dung buổi dạy bù...',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6B46C1)),
                      ),
                    ),
                    onChanged: (value) {
                      _content = value;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid() ? _submitMakeupClass : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Đăng ký dạy bù',
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
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }

  bool _isFormValid() {
    return _selectedDate != null &&
        _selectedSubject.isNotEmpty &&
        _selectedClass.isNotEmpty &&
        _selectedRoom.isNotEmpty &&
        _startTime.isNotEmpty &&
        _endTime.isNotEmpty;
  }

  void _submitMakeupClass() {
    // TODO: Implement makeup class submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đăng ký dạy bù thành công'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Reset form
    setState(() {
      _selectedDate = null;
      _selectedSubject = '';
      _selectedClass = '';
      _selectedRoom = '';
      _startTime = '';
      _endTime = '';
      _content = '';
    });
  }
}
