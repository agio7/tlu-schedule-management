import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../models/users.dart';
import '../../../../models/subjects.dart';
import '../../../../models/classrooms.dart';
import '../../../../models/rooms.dart';

class CRUDScreen extends StatefulWidget {
  final String type;
  
  const CRUDScreen({super.key, required this.type});

  @override
  State<CRUDScreen> createState() => _CRUDScreenState();
}

class _CRUDScreenState extends State<CRUDScreen> {
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
      
      switch (widget.type) {
        case 'Giảng viên':
          await adminProvider.loadUsers();
          break;
        case 'Môn học':
          await adminProvider.loadSubjects();
          break;
        case 'Lớp học':
          await adminProvider.loadClassrooms();
          break;
        case 'Phòng học':
          await adminProvider.loadRooms();
          break;
      }
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
        title: Text('Quản lý ${widget.type}'),
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
                hintText: 'Tìm kiếm ${widget.type.toLowerCase()}...',
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
          
          // Error message
          if (_error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          
          // Danh sách
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final items = _getFilteredItems(adminProvider);
        
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(),
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có ${widget.type.toLowerCase()} nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút + để thêm mới',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                  child: Icon(
                    _getIconForType(),
                    color: const Color(0xFF1976D2),
                  ),
                ),
                title: Text(
                  _getItemTitle(item),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_getItemSubtitle(item)),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Chỉnh sửa'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(item);
                    } else if (value == 'delete') {
                      _showDeleteDialog(item);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<dynamic> _getFilteredItems(AdminProvider adminProvider) {
    List<dynamic> items = [];
    
    switch (widget.type) {
      case 'Giảng viên':
        items = adminProvider.teachers;
        break;
      case 'Môn học':
        items = adminProvider.subjects;
        break;
      case 'Lớp học':
        items = adminProvider.classrooms;
        break;
      case 'Phòng học':
        items = adminProvider.rooms;
        break;
    }

    if (_searchController.text.isEmpty) {
      return items;
    }

    final query = _searchController.text.toLowerCase();
    return items.where((item) {
      switch (widget.type) {
        case 'Giảng viên':
          final teacher = item as Users;
          return teacher.fullName.toLowerCase().contains(query) ||
                 teacher.email.toLowerCase().contains(query) ||
                 (teacher.employeeId?.toLowerCase().contains(query) ?? false) ||
                 (teacher.specialization?.toLowerCase().contains(query) ?? false);
        case 'Môn học':
          final subject = item as Subjects;
          return subject.name.toLowerCase().contains(query) ||
                 subject.code.toLowerCase().contains(query) ||
                 (subject.description?.toLowerCase().contains(query) ?? false);
        case 'Lớp học':
          final classroom = item as Classrooms;
          return classroom.name.toLowerCase().contains(query) ||
                 classroom.code.toLowerCase().contains(query) ||
                 (classroom.description?.toLowerCase().contains(query) ?? false);
        case 'Phòng học':
          final room = item as Rooms;
          return room.name.toLowerCase().contains(query) ||
                 room.code.toLowerCase().contains(query) ||
                 (room.type?.toLowerCase().contains(query) ?? false) ||
                 (room.building?.toLowerCase().contains(query) ?? false) ||
                 (room.description?.toLowerCase().contains(query) ?? false);
        default:
          return false;
      }
    }).toList();
  }

  String _getItemTitle(dynamic item) {
    switch (widget.type) {
      case 'Giảng viên':
        return (item as Users).fullName;
      case 'Môn học':
        return (item as Subjects).name;
      case 'Lớp học':
        return (item as Classrooms).name;
      case 'Phòng học':
        return (item as Rooms).name;
      default:
        return '';
    }
  }

  String _getItemSubtitle(dynamic item) {
    switch (widget.type) {
      case 'Giảng viên':
        final teacher = item as Users;
        return '${teacher.email} - ${teacher.specialization ?? "Chưa rõ chuyên ngành"}';
      case 'Môn học':
        final subject = item as Subjects;
        return '${subject.code} - ${subject.credits} tín chỉ';
      case 'Lớp học':
        final classroom = item as Classrooms;
        return '${classroom.studentCount} sinh viên - ${classroom.academicYear}';
      case 'Phòng học':
        final room = item as Rooms;
        return '${room.capacity} chỗ - ${room.type} - Tầng ${room.floor}';
      default:
        return '';
    }
  }

  IconData _getIconForType() {
    switch (widget.type) {
      case 'Giảng viên':
        return Icons.person;
      case 'Môn học':
        return Icons.book;
      case 'Lớp học':
        return Icons.school;
      case 'Phòng học':
        return Icons.room;
      default:
        return Icons.category;
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _buildFormDialog(
        title: 'Thêm ${widget.type}',
        item: null,
        onSave: (formData) => _addItem(formData),
        dialogContext: dialogContext,
      ),
    );
  }

  void _showEditDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (dialogContext) => _buildFormDialog(
        title: 'Chỉnh sửa ${widget.type}',
        item: item,
        onSave: (formData) => _updateItem(item, formData),
        dialogContext: dialogContext,
      ),
    );
  }

  void _showDeleteDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa ${widget.type.toLowerCase()} "${_getItemTitle(item)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(item);
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

  Widget _buildFormDialog({
    required String title,
    required dynamic item,
    required Function(Map<String, dynamic>) onSave,
    required BuildContext dialogContext,
  }) {
    final formKey = GlobalKey<FormState>();
    final controllers = _createControllers(item);

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: _buildFormFields(controllers),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final formData = _getFormData(controllers);
              Navigator.pop(dialogContext);
              onSave(formData);
            }
          },
          child: Text(item == null ? 'Thêm' : 'Lưu'),
        ),
      ],
    );
  }

  Map<String, TextEditingController> _createControllers(dynamic item) {
    final controllers = <String, TextEditingController>{};
    
    switch (widget.type) {
      case 'Giảng viên':
        final teacher = item as Users?;
        controllers['fullName'] = TextEditingController(text: teacher?.fullName ?? '');
        controllers['email'] = TextEditingController(text: teacher?.email ?? '');
        controllers['phoneNumber'] = TextEditingController(text: teacher?.phoneNumber ?? '');
        controllers['employeeId'] = TextEditingController(text: teacher?.employeeId ?? '');
        controllers['specialization'] = TextEditingController(text: teacher?.specialization ?? '');
        controllers['academicRank'] = TextEditingController(text: teacher?.academicRank ?? '');
        break;
      case 'Môn học':
        final subject = item as Subjects?;
        controllers['name'] = TextEditingController(text: subject?.name ?? '');
        controllers['code'] = TextEditingController(text: subject?.code ?? '');
        controllers['credits'] = TextEditingController(text: subject?.credits.toString() ?? '');
        controllers['totalHours'] = TextEditingController(text: subject?.totalHours.toString() ?? '');
        controllers['description'] = TextEditingController(text: subject?.description ?? '');
        controllers['prerequisites'] = TextEditingController(text: subject?.prerequisites?.join(', ') ?? '');
        break;
      case 'Lớp học':
        final classroom = item as Classrooms?;
        controllers['name'] = TextEditingController(text: classroom?.name ?? '');
        controllers['code'] = TextEditingController(text: classroom?.code ?? '');
        controllers['academicYear'] = TextEditingController(text: classroom?.academicYear ?? '');
        controllers['semester'] = TextEditingController(text: classroom?.semester ?? '');
        controllers['studentCount'] = TextEditingController(text: classroom?.studentCount.toString() ?? '');
        controllers['description'] = TextEditingController(text: classroom?.description ?? '');
        break;
      case 'Phòng học':
        final room = item as Rooms?;
        controllers['name'] = TextEditingController(text: room?.name ?? '');
        controllers['code'] = TextEditingController(text: room?.code ?? '');
        controllers['building'] = TextEditingController(text: room?.building ?? '');
        controllers['capacity'] = TextEditingController(text: room?.capacity.toString() ?? '');
        controllers['type'] = TextEditingController(text: room?.type ?? '');
        controllers['floor'] = TextEditingController(text: room?.floor.toString() ?? '');
        controllers['description'] = TextEditingController(text: room?.description ?? '');
        controllers['equipment'] = TextEditingController(text: room?.equipment?.join(', ') ?? '');
        break;
    }
    
    return controllers;
  }

  Widget _buildFormFields(Map<String, TextEditingController> controllers) {
    switch (widget.type) {
      case 'Giảng viên':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controllers['fullName'],
              decoration: const InputDecoration(
                labelText: 'Họ và tên *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['email'],
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['phoneNumber'],
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['employeeId'],
              decoration: const InputDecoration(
                labelText: 'Mã giảng viên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['specialization'],
              decoration: const InputDecoration(
                labelText: 'Chuyên ngành',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['academicRank'],
              decoration: const InputDecoration(
                labelText: 'Học hàm/Học vị',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case 'Môn học':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controllers['name'],
              decoration: const InputDecoration(
                labelText: 'Tên môn học *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên môn học';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['code'],
              decoration: const InputDecoration(
                labelText: 'Mã môn học *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã môn học';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['credits'],
              decoration: const InputDecoration(
                labelText: 'Số tín chỉ *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tín chỉ';
                }
                if (int.tryParse(value) == null) {
                  return 'Số tín chỉ phải là số';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['totalHours'],
              decoration: const InputDecoration(
                labelText: 'Tổng số giờ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['description'],
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['prerequisites'],
              decoration: const InputDecoration(
                labelText: 'Môn học tiên quyết',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case 'Lớp học':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controllers['name'],
              decoration: const InputDecoration(
                labelText: 'Tên lớp học *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên lớp học';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['code'],
              decoration: const InputDecoration(
                labelText: 'Mã lớp học *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã lớp học';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['academicYear'],
              decoration: const InputDecoration(
                labelText: 'Năm học *',
                border: OutlineInputBorder(),
                hintText: '2024-2025',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập năm học';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['semester'],
              decoration: const InputDecoration(
                labelText: 'Học kỳ *',
                border: OutlineInputBorder(),
                hintText: '1, 2, 3',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập học kỳ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['studentCount'],
              decoration: const InputDecoration(
                labelText: 'Số sinh viên *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số sinh viên';
                }
                if (int.tryParse(value) == null) {
                  return 'Số sinh viên phải là số';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['description'],
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        );
      case 'Phòng học':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controllers['name'],
              decoration: const InputDecoration(
                labelText: 'Tên phòng học *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên phòng học';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['code'],
              decoration: const InputDecoration(
                labelText: 'Mã phòng học *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã phòng học';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['building'],
              decoration: const InputDecoration(
                labelText: 'Tòa nhà',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['capacity'],
              decoration: const InputDecoration(
                labelText: 'Sức chứa *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập sức chứa';
                }
                if (int.tryParse(value) == null) {
                  return 'Sức chứa phải là số';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['type'],
              decoration: const InputDecoration(
                labelText: 'Loại phòng *',
                border: OutlineInputBorder(),
                hintText: 'Lý thuyết, Thực hành, Seminar',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập loại phòng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['floor'],
              decoration: const InputDecoration(
                labelText: 'Tầng *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tầng';
                }
                if (int.tryParse(value) == null) {
                  return 'Tầng phải là số';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['equipment'],
              decoration: const InputDecoration(
                labelText: 'Thiết bị',
                border: OutlineInputBorder(),
                hintText: 'Projector, Whiteboard, Computer (phân cách bằng dấu phẩy)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['description'],
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        );
      default:
        return const Text('Form không được hỗ trợ');
    }
  }

  Map<String, dynamic> _getFormData(Map<String, TextEditingController> controllers) {
    final data = <String, dynamic>{};
    
    switch (widget.type) {
      case 'Giảng viên':
        data['fullName'] = controllers['fullName']!.text;
        data['email'] = controllers['email']!.text;
        data['phoneNumber'] = controllers['phoneNumber']!.text;
        data['employeeId'] = controllers['employeeId']!.text;
        data['specialization'] = controllers['specialization']!.text;
        data['academicRank'] = controllers['academicRank']!.text;
        data['role'] = 'teacher';
        break;
      case 'Môn học':
        data['name'] = controllers['name']!.text;
        data['code'] = controllers['code']!.text;
        data['credits'] = int.tryParse(controllers['credits']!.text) ?? 0;
        data['totalHours'] = int.tryParse(controllers['totalHours']!.text) ?? 0;
        data['description'] = controllers['description']!.text;
        data['prerequisites'] = controllers['prerequisites']!.text;
        data['departmentId'] = ''; // TODO: Add department selection
        break;
      case 'Lớp học':
        data['name'] = controllers['name']!.text;
        data['code'] = controllers['code']!.text;
        data['academicYear'] = controllers['academicYear']!.text;
        data['semester'] = controllers['semester']!.text;
        data['studentCount'] = int.tryParse(controllers['studentCount']!.text) ?? 0;
        data['description'] = controllers['description']!.text;
        data['departmentId'] = ''; // TODO: Add department selection
        break;
      case 'Phòng học':
        data['name'] = controllers['name']!.text;
        data['code'] = controllers['code']!.text;
        data['building'] = controllers['building']!.text;
        data['capacity'] = int.tryParse(controllers['capacity']!.text) ?? 0;
        data['type'] = controllers['type']!.text;
        data['floor'] = int.tryParse(controllers['floor']!.text) ?? 1;
        data['equipment'] = controllers['equipment']!.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        data['description'] = controllers['description']!.text;
        data['isAvailable'] = true;
        break;
    }
    
    return data;
  }

  Future<void> _addItem(Map<String, dynamic> formData) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      
      switch (widget.type) {
        case 'Giảng viên':
          await adminProvider.addUser(formData);
          break;
        case 'Môn học':
          await adminProvider.addSubject(formData);
          break;
        case 'Lớp học':
          await adminProvider.addClassroom(formData);
          break;
        case 'Phòng học':
          await adminProvider.addRoom(formData);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm ${widget.type} thành công')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi thêm ${widget.type}: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateItem(dynamic item, Map<String, dynamic> formData) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      
      switch (widget.type) {
        case 'Giảng viên':
          final teacher = item as Users;
          await adminProvider.updateUser(teacher.id, formData);
          break;
        case 'Môn học':
          final subject = item as Subjects;
          await adminProvider.updateSubject(subject.id, formData);
          break;
        case 'Lớp học':
          final classroom = item as Classrooms;
          await adminProvider.updateClassroom(classroom.id, formData);
          break;
        case 'Phòng học':
          final room = item as Rooms;
          await adminProvider.updateRoom(room.id, formData);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật ${widget.type} thành công')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi cập nhật ${widget.type}: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(dynamic item) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      
      switch (widget.type) {
        case 'Giảng viên':
          final teacher = item as Users;
          await adminProvider.deleteUser(teacher.id);
          break;
        case 'Môn học':
          final subject = item as Subjects;
          await adminProvider.deleteSubject(subject.id);
          break;
        case 'Lớp học':
          final classroom = item as Classrooms;
          await adminProvider.deleteClassroom(classroom.id);
          break;
        case 'Phòng học':
          final room = item as Rooms;
          await adminProvider.deleteRoom(room.id);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa ${widget.type} thành công')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi xóa ${widget.type}: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}



