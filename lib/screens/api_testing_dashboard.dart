import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../services/department_service.dart';
import '../services/subject_service.dart';
import '../models/users.dart';
import '../models/departments.dart';
import '../models/subjects.dart';

class ApiTestingDashboard extends StatefulWidget {
  const ApiTestingDashboard({super.key});

  @override
  State<ApiTestingDashboard> createState() => _ApiTestingDashboardState();
}

class _ApiTestingDashboardState extends State<ApiTestingDashboard> {
  List<Map<String, dynamic>> _testResults = [];
  bool _isRunning = false;

  void _addTestResult(String testName, bool success, String message) {
    setState(() {
      _testResults.add({
        'testName': testName,
        'success': success,
        'message': message,
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    try {
      // Test 1: Authentication
      await _testAuthentication();
      
      // Test 2: Department CRUD
      await _testDepartmentCRUD();
      
      // Test 3: Subject CRUD
      await _testSubjectCRUD();
      
      // Test 4: Admin Service
      await _testAdminService();
      
      // Test 5: Error Handling
      await _testErrorHandling();
      
    } catch (e) {
      _addTestResult('All Tests', false, 'Error: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testAuthentication() async {
    try {
      // Test sign in
      final result = await AuthService.signInWithEmailAndPassword(
        email: 'admin@tlu.edu.vn',
        password: 'admin123',
      );
      
      if (result['success'] == true) {
        _addTestResult('Authentication - Sign In', true, 'Successfully signed in');
      } else {
        _addTestResult('Authentication - Sign In', false, result['message']);
      }
      
      // Test get current user
      final user = AuthService.getCurrentFirebaseUser();
      if (user != null) {
        _addTestResult('Authentication - Get Current User', true, 'User found: ${user.email}');
      } else {
        _addTestResult('Authentication - Get Current User', false, 'No current user');
      }
      
    } catch (e) {
      _addTestResult('Authentication', false, 'Error: $e');
    }
  }

  Future<void> _testDepartmentCRUD() async {
    try {
      // Test create
      final department = await DepartmentService.createDepartment({
        'name': 'Test Department',
        'description': 'Test Description',
      });
      
      if (department != null) {
        _addTestResult('Department - Create', true, 'Created: ${department.name}');
        
        // Test read
        final retrieved = await DepartmentService.getDepartmentById(department.id);
        if (retrieved != null) {
          _addTestResult('Department - Read', true, 'Retrieved: ${retrieved.name}');
          
          // Test update
          await DepartmentService.updateDepartment(department.id, {
            'description': 'Updated Description',
          });
          
          final updated = await DepartmentService.getDepartmentById(department.id);
          if (updated?.description == 'Updated Description') {
            _addTestResult('Department - Update', true, 'Updated successfully');
          } else {
            _addTestResult('Department - Update', false, 'Update failed');
          }
          
          // Test delete
          await DepartmentService.deleteDepartment(department.id);
          final deleted = await DepartmentService.getDepartmentById(department.id);
          if (deleted == null) {
            _addTestResult('Department - Delete', true, 'Deleted successfully');
          } else {
            _addTestResult('Department - Delete', false, 'Delete failed');
          }
        } else {
          _addTestResult('Department - Read', false, 'Failed to retrieve');
        }
      } else {
        _addTestResult('Department - Create', false, 'Failed to create');
      }
    } catch (e) {
      _addTestResult('Department CRUD', false, 'Error: $e');
    }
  }

  Future<void> _testSubjectCRUD() async {
    try {
      // Create department first
      final department = await DepartmentService.createDepartment({
        'name': 'Test Department for Subject',
        'description': 'Test Description',
      });
      
      if (department != null) {
        // Test create subject
        final subject = await SubjectService.createSubject({
          'name': 'Test Subject',
          'code': 'TEST001',
          'credits': 3,
          'departmentId': department.id,
          'description': 'Test Subject Description',
        });
        
        if (subject != null) {
          _addTestResult('Subject - Create', true, 'Created: ${subject.name}');
          
          // Test read
          final retrieved = await SubjectService.getSubjectById(subject.id);
          if (retrieved != null) {
            _addTestResult('Subject - Read', true, 'Retrieved: ${retrieved.name}');
            
            // Test update
            await SubjectService.updateSubject(subject.id, {
              'credits': 4,
            });
            
            final updated = await SubjectService.getSubjectById(subject.id);
            if (updated?.credits == 4) {
              _addTestResult('Subject - Update', true, 'Updated successfully');
            } else {
              _addTestResult('Subject - Update', false, 'Update failed');
            }
            
            // Test delete
            await SubjectService.deleteSubject(subject.id);
            final deleted = await SubjectService.getSubjectById(subject.id);
            if (deleted == null) {
              _addTestResult('Subject - Delete', true, 'Deleted successfully');
            } else {
              _addTestResult('Subject - Delete', false, 'Delete failed');
            }
          } else {
            _addTestResult('Subject - Read', false, 'Failed to retrieve');
          }
        } else {
          _addTestResult('Subject - Create', false, 'Failed to create');
        }
        
        // Clean up department
        await DepartmentService.deleteDepartment(department.id);
      } else {
        _addTestResult('Subject CRUD', false, 'Failed to create department');
      }
    } catch (e) {
      _addTestResult('Subject CRUD', false, 'Error: $e');
    }
  }

  Future<void> _testAdminService() async {
    try {
      // Test get all users
      final users = await AdminService.getAllUsers();
      _addTestResult('Admin Service - Get All Users', true, 'Found ${users.length} users');
      
      // Test get all departments
      final departments = await AdminService.getAllDepartments();
      _addTestResult('Admin Service - Get All Departments', true, 'Found ${departments.length} departments');
      
      // Test get all subjects
      final subjects = await AdminService.getAllSubjects();
      _addTestResult('Admin Service - Get All Subjects', true, 'Found ${subjects.length} subjects');
      
    } catch (e) {
      _addTestResult('Admin Service', false, 'Error: $e');
    }
  }

  Future<void> _testErrorHandling() async {
    try {
      // Test invalid sign in
      final result = await AuthService.signInWithEmailAndPassword(
        email: 'invalid@test.com',
        password: 'wrongpassword',
      );
      
      if (result['success'] == false) {
        _addTestResult('Error Handling - Invalid Sign In', true, 'Properly handled invalid credentials');
      } else {
        _addTestResult('Error Handling - Invalid Sign In', false, 'Should have failed');
      }
      
    } catch (e) {
      _addTestResult('Error Handling', false, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Testing Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Testing Controls',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isRunning ? null : _runAllTests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _isRunning
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Running Tests...'),
                                  ],
                                )
                              : const Text('Run All Tests'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _testResults.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear Results'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Results
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _testResults.isEmpty
                            ? const Center(
                                child: Text(
                                  'No test results yet. Click "Run All Tests" to start.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _testResults.length,
                                itemBuilder: (context, index) {
                                  final result = _testResults[index];
                                  return Card(
                                    color: result['success'] 
                                        ? Colors.green.shade50 
                                        : Colors.red.shade50,
                                    child: ListTile(
                                      leading: Icon(
                                        result['success'] 
                                            ? Icons.check_circle 
                                            : Icons.error,
                                        color: result['success'] 
                                            ? Colors.green 
                                            : Colors.red,
                                      ),
                                      title: Text(
                                        result['testName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(result['message']),
                                      trailing: Text(
                                        result['timestamp'].toString().substring(11, 19),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
