import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/lesson.dart';
import '../models/leave_request.dart';
import '../models/room.dart';
import '../providers/lesson_provider.dart';
import '../services/room_service.dart';

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
  String? _selectedRoomId;
  String? _selectedTimeSlot;
  List<Room> _availableRooms = [];
  List<Map<String, String>> _availableTimeSlots = [];
  bool _isLoadingRooms = false;
  bool _isLoadingTimeSlots = false;
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
      child: SingleChildScrollView(
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
                  decoration: InputDecoration(
                    hintText: widget.lesson.status == 'upcoming' || widget.lesson.status == 'ongoing'
                        ? 'Chọn lý do'
                        : 'Lớp đã kết thúc - không thể đăng ký',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6B46C1)),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  items: _reasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (widget.lesson.status == 'upcoming' || widget.lesson.status == 'ongoing')
                      ? (value) {
                          setState(() {
                            _selectedReason = value ?? '';
                          });
                        }
                      : null,
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
                          _selectedRoomId = null;
                          _selectedTimeSlot = null;
                          _availableRooms = [];
                          _availableTimeSlots = [];
                        });
                        // Load phòng học trống khi chọn ngày
                        _loadAvailableRooms(date);
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
                  
                  // Chọn phòng học trống
                  if (_makeupDate != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Phòng học trống',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingRooms
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: _selectedRoomId,
                            decoration: const InputDecoration(
                              hintText: 'Chọn phòng học trống',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6B46C1)),
                              ),
                            ),
                            items: _availableRooms.map((room) {
                              return DropdownMenuItem(
                                value: room.id,
                                child: Text('${room.code} - ${room.name}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRoomId = value;
                                _selectedTimeSlot = null;
                                _availableTimeSlots = [];
                              });
                              // Load tiết học trống khi chọn phòng
                              if (value != null && _makeupDate != null) {
                                _loadAvailableTimeSlots(_makeupDate!, value);
                              }
                            },
                          ),
                  ],
                  
                  // Chọn tiết học trống
                  if (_makeupDate != null && _selectedRoomId != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Tiết học trống',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingTimeSlots
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: _selectedTimeSlot,
                            decoration: const InputDecoration(
                              hintText: 'Chọn tiết học trống',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6B46C1)),
                              ),
                            ),
                            items: _availableTimeSlots.map((slot) {
                              return DropdownMenuItem(
                                value: '${slot['start']}-${slot['end']}',
                                child: Text('${slot['slot']} (${slot['start']} - ${slot['end']})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeSlot = value;
                              });
                            },
                          ),
                  ],
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
                    onPressed: (widget.lesson.status == 'upcoming' || widget.lesson.status == 'ongoing') && _selectedReason.isNotEmpty
                        ? () {
                            _submitRegistration();
                          }
                        : null,
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
      ),
    );
  }

  Future<void> _loadAvailableRooms(DateTime date) async {
    setState(() {
      _isLoadingRooms = true;
    });

    try {
      // Lấy phòng học trống trong ngày
      final rooms = await RoomService.getAvailableRooms(date);

      setState(() {
        _availableRooms = rooms;
        _isLoadingRooms = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRooms = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách phòng học: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAvailableTimeSlots(DateTime date, String roomId) async {
    setState(() {
      _isLoadingTimeSlots = true;
    });

    try {
      final timeSlots = await RoomService.getAvailableTimeSlots(date, roomId);

      setState(() {
        _availableTimeSlots = timeSlots;
        _isLoadingTimeSlots = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTimeSlots = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách tiết học: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    // Lấy thời gian từ tiết học đã chọn hoặc dùng thời gian mặc định
    String startTime = widget.lesson.startTime;
    String endTime = widget.lesson.endTime;
    
    if (_selectedTimeSlot != null) {
      final timeParts = _selectedTimeSlot!.split('-');
      if (timeParts.length == 2) {
        startTime = timeParts[0];
        endTime = timeParts[1];
      }
    }

    // Lấy thông tin phòng học đã chọn
    String? roomId;
    String? roomName;
    if (_selectedRoomId != null) {
      final selectedRoom = _availableRooms.firstWhere(
        (room) => room.id == _selectedRoomId,
        orElse: () => _availableRooms.first,
      );
      roomId = selectedRoom.id;
      roomName = '${selectedRoom.code} - ${selectedRoom.name}';
    }

    final leaveRequest = LeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: widget.lesson.id,
      type: _registrationType,
      reason: _selectedReason,
      makeupDate: _makeupDate,
      startTime: startTime,
      endTime: endTime,
      additionalNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
      teacherId: 'teacher_001', // TODO: Lấy từ auth provider
      requestDate: DateTime.now(),
      roomId: roomId,
      roomName: roomName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
      _selectedRoomId = null;
      _selectedTimeSlot = null;
      _availableRooms = [];
      _availableTimeSlots = [];
      _notesController.clear();
    });
  }
}