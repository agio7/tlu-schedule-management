import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_sections.dart';
import '../models/semesters.dart';
import '../services/schedule_generator_service.dart';

/// Script test quy trình sinh lịch tự động
class TestScheduleGeneration {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test sinh lịch với dữ liệu mẫu
  static Future<void> runTest() async {
    print('🧪 Bắt đầu test sinh lịch tự động...');

    try {
      // 1. Tạo semester test
      final semesterId = await _createTestSemester();
      print('✅ Đã tạo semester test: $semesterId');

      // 2. Tạo course section test
      final courseSectionId = await _createTestCourseSection(semesterId);
      print('✅ Đã tạo course section test: $courseSectionId');

      // 3. Sinh lịch tự động
      print('🔄 Bắt đầu sinh lịch tự động...');
      final schedules = await ScheduleGeneratorService.generateSchedulesFromCourseSection(courseSectionId);
      print('✅ Đã sinh thành công ${schedules.length} buổi học');

      // 4. Hiển thị kết quả
      _displayResults(schedules);

      print('🎉 Test hoàn thành thành công!');

    } catch (e) {
      print('❌ Test thất bại: $e');
    }
  }

  /// Tạo semester test
  static Future<String> _createTestSemester() async {
    final semester = {
      'name': 'Học kỳ 1 - 2024 (Test)',
      'startDate': Timestamp.fromDate(DateTime(2024, 9, 2)), // Thứ 2, 2/9/2024
      'endDate': Timestamp.fromDate(DateTime(2024, 12, 31)),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('semesters').add(semester);
    return docRef.id;
  }

  /// Tạo course section test
  static Future<String> _createTestCourseSection(String semesterId) async {
    final courseSection = {
      'subjectId': 'test_subject_001',
      'teacherId': 'test_teacher_001',
      'classroomId': 'test_classroom_001',
      'roomId': 'test_room_001',
      'semesterId': semesterId,
      'totalSessions': 16, // 16 buổi học
      'scheduleString': 'Thứ 2, Tiết 1-3; Thứ 5, Tiết 7-9', // 2 buổi/tuần
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('courseSections').add(courseSection);
    return docRef.id;
  }

  /// Hiển thị kết quả sinh lịch
  static void _displayResults(List schedules) {
    print('\n📅 KẾT QUẢ SINH LỊCH:');
    print('=' * 50);
    
    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];
      print('Buổi ${schedule.sessionNumber}: ${_formatDateTime(schedule.startTime)} - ${_formatDateTime(schedule.endTime)}');
      
      if ((i + 1) % 4 == 0) {
        print('---');
      }
    }
    
    print('=' * 50);
    print('📊 Tổng cộng: ${schedules.length} buổi học');
    print('📅 Thời gian: ${_formatDateTime(schedules.first.startTime)} đến ${_formatDateTime(schedules.last.startTime)}');
  }

  /// Format DateTime
  static String _formatDateTime(DateTime dateTime) {
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final weekday = weekdays[dateTime.weekday % 7];
    return '$weekday ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Cleanup test data
  static Future<void> cleanup() async {
    print('🧹 Dọn dẹp dữ liệu test...');
    
    try {
      // Xóa test semesters
      final semesterQuery = await _firestore
          .collection('semesters')
          .where('name', isEqualTo: 'Học kỳ 1 - 2024 (Test)')
          .get();
      
      for (final doc in semesterQuery.docs) {
        await doc.reference.delete();
      }

      // Xóa test course sections
      final courseSectionQuery = await _firestore
          .collection('courseSections')
          .where('subjectId', isEqualTo: 'test_subject_001')
          .get();
      
      for (final doc in courseSectionQuery.docs) {
        await doc.reference.delete();
      }

      // Xóa test schedules
      final scheduleQuery = await _firestore
          .collection('schedules')
          .where('courseSectionId', isEqualTo: 'test_course_section_001')
          .get();
      
      for (final doc in scheduleQuery.docs) {
        await doc.reference.delete();
      }

      print('✅ Đã dọn dẹp xong dữ liệu test');
    } catch (e) {
      print('❌ Lỗi dọn dẹp: $e');
    }
  }
}






