import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../services/department_service.dart';
import '../services/subject_service.dart';
import '../models/users.dart';
import '../models/departments.dart';
import '../models/subjects.dart';

class ApiTestingTool extends StatefulWidget {
  const ApiTestingTool({super.key});

  @override
  State<ApiTestingTool> createState() => _ApiTestingToolState();
}

class _ApiTestingToolState extends State<ApiTestingTool> {
  final _emailController = TextEditingController(text: 'admin@tlu.edu.vn');
  final _passwordController = TextEditingController(text: 'admin123');
  final _departmentNameController = TextEditingController();
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _subjectCreditsController = TextEditingController();
  
  List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _testSignIn() async {
    setState(() => _isLoading = true);
    try {
      _addLog('🔐 Testing sign in...');
      final result = await AuthService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (result['success'] == true) {
        _addLog('✅ Sign in successful: ${result['user'].email}');
      } else {
        _addLog('❌ Sign in failed: ${result['message']}');
      }
    } catch (e) {
      _addLog('❌ Sign in error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSignOut() async {
    setState(() => _isLoading = true);
    try {
      _addLog('🔐 Testing sign out...');
      await AuthService.signOut();
      _addLog('✅ Sign out successful');
    } catch (e) {
      _addLog('❌ Sign out error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCreateDepartment() async {
    setState(() => _isLoading = true);
    try {
      _addLog('📁 Testing create department...');
      final department = await DepartmentService.createDepartment({
        'name': _departmentNameController.text.isNotEmpty 
            ? _departmentNameController.text 
            : 'Test Department ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'Test Description',
      });
      
      if (department != null) {
        _addLog('✅ Department created: ${department.name} (ID: ${department.id})');
      } else {
        _addLog('❌ Failed to create department');
      }
    } catch (e) {
      _addLog('❌ Create department error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCreateSubject() async {
    setState(() => _isLoading = true);
    try {
      _addLog('📚 Testing create subject...');
      
      // Get first department
      final departments = await AdminService.getAllDepartments();
      if (departments.isEmpty) {
        _addLog('❌ No departments found. Create a department first.');
        return;
      }
      
      final department = departments.first;
      final subject = await SubjectService.createSubject({
        'name': _subjectNameController.text.isNotEmpty 
            ? _subjectNameController.text 
            : 'Test Subject ${DateTime.now().millisecondsSinceEpoch}',
        'code': _subjectCodeController.text.isNotEmpty 
            ? _subjectCodeController.text 
            : 'TEST${DateTime.now().millisecondsSinceEpoch}',
        'credits': int.tryParse(_subjectCreditsController.text) ?? 3,
        'departmentId': department.id,
        'description': 'Test Subject Description',
      });
      
      if (subject != null) {
        _addLog('✅ Subject created: ${subject.name} (ID: ${subject.id})');
      } else {
        _addLog('❌ Failed to create subject');
      }
    } catch (e) {
      _addLog('❌ Create subject error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetAllData() async {
    setState(() => _isLoading = true);
    try {
      _addLog('📊 Testing get all data...');
      
      final users = await AdminService.getAllUsers();
      _addLog('👥 Users: ${users.length}');
      
      final departments = await AdminService.getAllDepartments();
      _addLog('📁 Departments: ${departments.length}');
      
      final subjects = await AdminService.getAllSubjects();
      _addLog('📚 Subjects: ${subjects.length}');
      
      final classrooms = await AdminService.getAllClassrooms();
      _addLog('🏫 Classrooms: ${classrooms.length}');
      
      final rooms = await AdminService.getAllRooms();
      _addLog('🏢 Rooms: ${rooms.length}');
      
      final students = await AdminService.getAllStudents();
      _addLog('🎓 Students: ${students.length}');
      
      final semesters = await AdminService.getAllSemesters();
      _addLog('📅 Semesters: ${semesters.length}');
      
      final courseSections = await AdminService.getAllCourseSections();
      _addLog('📖 Course Sections: ${courseSections.length}');
      
      final schedules = await AdminService.getAllSchedules();
      _addLog('⏰ Schedules: ${schedules.length}');
      
      final attendance = await AdminService.getAllAttendance();
      _addLog('📝 Attendance: ${attendance.length}');
      
      final leaveRequests = await AdminService.getAllLeaveRequests();
      _addLog('📋 Leave Requests: ${leaveRequests.length}');
      
      final makeupRequests = await AdminService.getAllMakeupRequests();
      _addLog('🔄 Makeup Requests: ${makeupRequests.length}');
      
      _addLog('✅ All data retrieved successfully');
    } catch (e) {
      _addLog('❌ Get all data error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFirestoreConnection() async {
    setState(() => _isLoading = true);
    try {
      _addLog('🔗 Testing Firestore connection...');
      
      final firestore = FirebaseFirestore.instance;
      final testDoc = await firestore.collection('test').doc('connection').get();
      
      if (testDoc.exists) {
        _addLog('✅ Firestore connection successful');
      } else {
        _addLog('✅ Firestore connection successful (test document created)');
        await firestore.collection('test').doc('connection').set({
          'timestamp': FieldValue.serverTimestamp(),
          'test': true,
        });
      }
    } catch (e) {
      _addLog('❌ Firestore connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Testing Tool'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Authentication Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Tests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testSignIn,
                          child: const Text('Test Sign In'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testSignOut,
                          child: const Text('Test Sign Out'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // CRUD Tests Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CRUD Tests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _departmentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Department Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _subjectNameController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subjectCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Subject Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _subjectCreditsController,
                            decoration: const InputDecoration(
                              labelText: 'Credits',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testCreateDepartment,
                          child: const Text('Test Create Department'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testCreateSubject,
                          child: const Text('Test Create Subject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // System Tests Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Tests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testFirestoreConnection,
                          child: const Text('Test Firestore Connection'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testGetAllData,
                          child: const Text('Test Get All Data'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logs Section
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Test Logs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _logs.clear();
                              });
                            },
                            child: const Text('Clear Logs'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _logs.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No logs yet. Run some tests to see results.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _logs.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        _logs[index],
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
