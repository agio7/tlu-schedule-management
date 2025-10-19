import 'package:flutter/material.dart';

class MakeupClassScreen extends StatefulWidget {
  const MakeupClassScreen({super.key});

  @override
  State<MakeupClassScreen> createState() => _MakeupClassScreenState();
}

class _MakeupClassScreenState extends State<MakeupClassScreen> {
  String _selectedClass = 'CNTT01';
  String _selectedSubject = 'Lập trình Java';
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '08:00-10:00';
  String _selectedRoom = 'A101';
  String _selectedReason = 'Nghỉ bệnh';

  final List<String> _timeSlots = [
    '08:00-10:00',
    '10:30-12:30',
    '14:00-16:00',
    '16:30-18:30',
  ];

  final List<String> _rooms = [
    'A101',
    'A102',
    'A103',
    'Lab A',
    'Lab B',
    'B201',
    'B202',
  ];

  final List<String> _reasons = [
    'Nghỉ bệnh',
    'Công việc cá nhân',
    'Hội nghị/Hội thảo',
    'Nghỉ phép',
    'Lý do khác',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký dạy bù'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Information
            _buildSectionHeader('Thông tin lớp học'),
            _buildClassInfoCard(),
            const SizedBox(height: 24),

            // Makeup Class Details
            _buildSectionHeader('Chi tiết dạy bù'),
            _buildMakeupDetailsCard(),
            const SizedBox(height: 24),

            // Available Time Slots
            _buildSectionHeader('Ca học có sẵn'),
            _buildAvailableSlotsCard(),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitMakeupRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),

            // Recent Makeup Classes
            _buildSectionHeader('Lịch dạy bù gần đây'),
            _buildRecentMakeupClasses(),
          ],
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
                const Icon(Icons.info, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Text(
                  'Lý do nghỉ: $_selectedReason',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMakeupDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date Selection
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Text(
                  'Ngày dạy bù: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.edit),
                  label: const Text('Chọn ngày'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Slot Selection
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

            // Room Selection
            DropdownButtonFormField<String>(
              value: _selectedRoom,
              decoration: const InputDecoration(
                labelText: 'Phòng học',
                prefixIcon: Icon(Icons.room),
                border: OutlineInputBorder(),
              ),
              items: _rooms.map((room) {
                return DropdownMenuItem(
                  value: room,
                  child: Text(room),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoom = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSlotsCard() {
    final availableSlots = [
      {'date': '20/01/2024', 'time': '08:00-10:00', 'room': 'A101', 'available': true},
      {'date': '20/01/2024', 'time': '10:30-12:30', 'room': 'A102', 'available': true},
      {'date': '21/01/2024', 'time': '14:00-16:00', 'room': 'Lab A', 'available': true},
      {'date': '21/01/2024', 'time': '16:30-18:30', 'room': 'A103', 'available': false},
      {'date': '22/01/2024', 'time': '08:00-10:00', 'room': 'A101', 'available': true},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Các ca học có sẵn trong tuần tới:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...availableSlots.map((slot) => _buildSlotItem(slot)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotItem(Map<String, dynamic> slot) {
    final isAvailable = slot['available'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot['date']} - ${slot['time']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Phòng: ${slot['room']}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isAvailable)
            TextButton(
              onPressed: () => _selectSlot(slot),
              child: const Text('Chọn'),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentMakeupClasses() {
    final recentMakeupClasses = [
      {
        'date': '18/01/2024',
        'class': 'CNTT02',
        'subject': 'Cơ sở dữ liệu',
        'timeSlot': '10:30-12:30',
        'room': 'A102',
        'status': 'approved',
        'originalDate': '15/01/2024',
      },
      {
        'date': '16/01/2024',
        'class': 'CNTT01',
        'subject': 'Lập trình Java',
        'timeSlot': '08:00-10:00',
        'room': 'A101',
        'status': 'completed',
        'originalDate': '12/01/2024',
      },
      {
        'date': '19/01/2024',
        'class': 'CNTT03',
        'subject': 'Mạng máy tính',
        'timeSlot': '14:00-16:00',
        'room': 'Lab A',
        'status': 'pending',
        'originalDate': '17/01/2024',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentMakeupClasses.length,
      itemBuilder: (context, index) {
        final makeupClass = recentMakeupClasses[index];
        return _buildMakeupClassCard(makeupClass);
      },
    );
  }

  Widget _buildMakeupClassCard(Map<String, String> makeupClass) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (makeupClass['status']) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Đã duyệt';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done;
        statusText = 'Đã hoàn thành';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Chờ duyệt';
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
        title: Text('${makeupClass['class']} - ${makeupClass['subject']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dạy bù: ${makeupClass['date']} - ${makeupClass['timeSlot']}'),
            Text('Phòng: ${makeupClass['room']}'),
            Text('Thay cho: ${makeupClass['originalDate']}'),
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
        onTap: () => _showMakeupClassDetails(makeupClass),
      ),
    );
  }

  void _selectSlot(Map<String, dynamic> slot) {
    setState(() {
      _selectedDate = DateTime(2024, 1, 20); // Mock date
      _selectedTimeSlot = slot['time'];
      _selectedRoom = slot['room'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chọn ca học: ${slot['date']} - ${slot['time']}'),
        backgroundColor: Colors.green,
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

  void _submitMakeupRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng ký dạy bù'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lớp: $_selectedClass'),
            Text('Môn: $_selectedSubject'),
            Text('Ngày dạy bù: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            Text('Ca: $_selectedTimeSlot'),
            Text('Phòng: $_selectedRoom'),
            Text('Lý do nghỉ: $_selectedReason'),
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
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }

  void _showMakeupClassDetails(Map<String, String> makeupClass) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết lịch dạy bù'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lớp: ${makeupClass['class']}'),
            Text('Môn: ${makeupClass['subject']}'),
            Text('Ngày dạy bù: ${makeupClass['date']}'),
            Text('Ca: ${makeupClass['timeSlot']}'),
            Text('Phòng: ${makeupClass['room']}'),
            Text('Thay cho: ${makeupClass['originalDate']}'),
            Text('Trạng thái: ${makeupClass['status']}'),
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
        content: Text('Đã đăng ký dạy bù thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}