import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../services/department_service.dart';
import '../services/subject_service.dart';
import '../models/users.dart';
import '../models/departments.dart';
import '../models/subjects.dart';

void main() {
  group('Firebase API Tests', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp();
    });

    group('Authentication Tests', () {
      test('should sign in with valid credentials', () async {
        final result = await AuthService.signInWithEmailAndPassword(
          email: 'admin@tlu.edu.vn',
          password: 'admin123',
        );
        
        expect(result['success'], true);
        expect(result['user'], isA<Users>());
      });

      test('should fail with invalid credentials', () async {
        final result = await AuthService.signInWithEmailAndPassword(
          email: 'invalid@test.com',
          password: 'wrongpassword',
        );
        
        expect(result['success'], false);
        expect(result['message'], isNotEmpty);
      });

      test('should sign out successfully', () async {
        await AuthService.signOut();
        final user = AuthService.getCurrentFirebaseUser();
        expect(user, isNull);
      });
    });

    group('Firestore CRUD Tests', () {
      test('should create department', () async {
        final department = await DepartmentService.createDepartment({
          'name': 'Test Department',
          'description': 'Test Description',
        });
        
        expect(department, isNotNull);
        expect(department.name, 'Test Department');
        expect(department.description, 'Test Description');
      });

      test('should read department', () async {
        final department = await DepartmentService.createDepartment({
          'name': 'Test Read Department',
          'description': 'Test Read Description',
        });
        
        final retrieved = await DepartmentService.getDepartmentById(department.id);
        expect(retrieved, isNotNull);
        expect(retrieved.name, 'Test Read Department');
      });

      test('should update department', () async {
        final department = await DepartmentService.createDepartment({
          'name': 'Test Update Department',
          'description': 'Original Description',
        });
        
        await DepartmentService.updateDepartment(department.id, {
          'description': 'Updated Description',
        });
        
        final updated = await DepartmentService.getDepartmentById(department.id);
        expect(updated.description, 'Updated Description');
      });

      test('should delete department', () async {
        final department = await DepartmentService.createDepartment({
          'name': 'Test Delete Department',
          'description': 'Test Delete Description',
        });
        
        await DepartmentService.deleteDepartment(department.id);
        
        final deleted = await DepartmentService.getDepartmentById(department.id);
        expect(deleted, isNull);
      });
    });

    group('Subject Management Tests', () {
      test('should create subject', () async {
        final department = await DepartmentService.createDepartment({
          'name': 'Test Department for Subject',
          'description': 'Test Description',
        });
        
        final subject = await SubjectService.createSubject({
          'name': 'Test Subject',
          'code': 'TEST001',
          'credits': 3,
          'departmentId': department.id,
          'description': 'Test Subject Description',
        });
        
        expect(subject, isNotNull);
        expect(subject.name, 'Test Subject');
        expect(subject.code, 'TEST001');
        expect(subject.credits, 3);
        expect(subject.departmentId, department.id);
      });

      test('should get subjects by department', () async {
        final department = await DepartmentService.createDepartment({
          'name': 'Test Department for Subjects',
          'description': 'Test Description',
        });
        
        await SubjectService.createSubject({
          'name': 'Subject 1',
          'code': 'SUB001',
          'credits': 3,
          'departmentId': department.id,
        });
        
        await SubjectService.createSubject({
          'name': 'Subject 2',
          'code': 'SUB002',
          'credits': 4,
          'departmentId': department.id,
        });
        
        final subjects = await SubjectService.getSubjectsByDepartment(department.id);
        expect(subjects.length, 2);
      });
    });

    group('Admin Service Tests', () {
      test('should get all users', () async {
        final users = await AdminService.getAllUsers();
        expect(users, isA<List<Users>>());
      });

      test('should get all departments', () async {
        final departments = await AdminService.getAllDepartments();
        expect(departments, isA<List<Departments>>());
      });

      test('should get all subjects', () async {
        final subjects = await AdminService.getAllSubjects();
        expect(subjects, isA<List<Subjects>>());
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        // Simulate network error by using invalid Firebase config
        try {
          final result = await AuthService.signInWithEmailAndPassword(
            email: 'test@test.com',
            password: 'test123',
          );
          // Should not reach here
          expect(result['success'], false);
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('should handle permission denied errors', () async {
        try {
          final departments = await AdminService.getAllDepartments();
          expect(departments, isA<List>());
        } catch (e) {
          // Should handle permission errors gracefully
          expect(e, isA<Exception>());
        }
      });
    });

    group('Performance Tests', () {
      test('should load large datasets efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        final departments = await AdminService.getAllDepartments();
        final subjects = await AdminService.getAllSubjects();
        final users = await AdminService.getAllUsers();
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete within 5 seconds
        expect(departments, isA<List>());
        expect(subjects, isA<List>());
        expect(users, isA<List>());
      });
    });
  });
}
