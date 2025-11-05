import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_sections.dart';
import '../models/schedules.dart';
import '../models/semesters.dart';

/// Service để sinh lịch tự động từ CourseSections
class ScheduleGeneratorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sinh lịch tự động từ một CourseSection
  static Future<List<Schedules>> generateSchedulesFromCourseSection(
    String courseSectionId,
  ) async {
    try {
      print('🔄 ScheduleGenerator: Bắt đầu sinh lịch cho CourseSection: $courseSectionId');

      // 1. Lấy thông tin CourseSection
      final courseSection = await _getCourseSection(courseSectionId);
      if (courseSection == null) {
        throw Exception('Không tìm thấy CourseSection với ID: $courseSectionId');
      }

      // 2. Lấy thông tin Semester
      final semester = await _getSemester(courseSection.semesterId);
      if (semester == null) {
        throw Exception('Không tìm thấy Semester với ID: ${courseSection.semesterId}');
      }

      // 3. Phân tích scheduleString
      final scheduleRules = _parseScheduleString(courseSection.scheduleString);
      print('📅 ScheduleGenerator: Phân tích được ${scheduleRules.length} quy tắc lịch học');

      // 4. Tính toán các buổi học
      final schedules = _calculateSchedules(
        courseSection,
        semester,
        scheduleRules,
      );

      // 5. Lưu vào database
      final savedSchedules = await _saveSchedules(schedules);
      
      print('✅ ScheduleGenerator: Đã sinh thành công ${savedSchedules.length} buổi học');
      return savedSchedules;

    } catch (e) {
      print('❌ ScheduleGenerator: Lỗi sinh lịch: $e');
      rethrow;
    }
  }

  /// Lấy thông tin CourseSection
  static Future<CourseSections?> _getCourseSection(String courseSectionId) async {
    final doc = await _firestore
        .collection('courseSections')
        .doc(courseSectionId)
        .get();
    
    if (doc.exists) {
      return CourseSections.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  /// Lấy thông tin Semester
  static Future<Semesters?> _getSemester(String semesterId) async {
    final doc = await _firestore
        .collection('semesters')
        .doc(semesterId)
        .get();
    
    if (doc.exists) {
      return Semesters.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  /// Phân tích scheduleString thành các quy tắc
  static List<ScheduleRule> _parseScheduleString(String scheduleString) {
    final rules = <ScheduleRule>[];
    
    // Tách các quy tắc bằng dấu ";"
    final ruleStrings = scheduleString.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty);
    
    for (final ruleString in ruleStrings) {
      final rule = _parseSingleRule(ruleString);
      if (rule != null) {
        rules.add(rule);
      }
    }
    
    return rules;
  }

  /// Phân tích một quy tắc đơn lẻ
  static ScheduleRule? _parseSingleRule(String ruleString) {
    try {
      // Ví dụ: "Thứ 2, Tiết 1-3"
      final parts = ruleString.split(',').map((s) => s.trim());
      if (parts.length != 2) return null;

      final dayPart = parts.first; // "Thứ 2"
      final timePart = parts.last; // "Tiết 1-3"

      // Parse ngày trong tuần
      final dayOfWeek = _parseDayOfWeek(dayPart);
      if (dayOfWeek == null) return null;

      // Parse tiết học
      final periods = _parsePeriods(timePart);
      if (periods.isEmpty) return null;

      return ScheduleRule(
        dayOfWeek: dayOfWeek,
        periods: periods,
      );
    } catch (e) {
      print('❌ ScheduleGenerator: Lỗi parse quy tắc "$ruleString": $e');
      return null;
    }
  }

  /// Parse ngày trong tuần
  static int? _parseDayOfWeek(String dayString) {
    final dayMap = {
      'Thứ 2': 1,
      'Thứ 3': 2,
      'Thứ 4': 3,
      'Thứ 5': 4,
      'Thứ 6': 5,
      'Thứ 7': 6,
      'Chủ nhật': 7,
    };
    
    return dayMap[dayString];
  }

  /// Parse tiết học
  static List<int> _parsePeriods(String timeString) {
    // Ví dụ: "Tiết 1-3" -> [1, 2, 3]
    if (timeString.startsWith('Tiết ')) {
      final periodPart = timeString.substring(5); // "1-3"
      
      if (periodPart.contains('-')) {
        // Khoảng tiết: "1-3"
        final parts = periodPart.split('-');
        if (parts.length == 2) {
          final start = int.tryParse(parts[0]);
          final end = int.tryParse(parts[1]);
          if (start != null && end != null && start <= end) {
            return List.generate(end - start + 1, (i) => start + i);
          }
        }
      } else {
        // Tiết đơn: "1"
        final period = int.tryParse(periodPart);
        if (period != null) {
          return [period];
        }
      }
    }
    
    return [];
  }

  /// Tính toán các buổi học
  static List<Schedules> _calculateSchedules(
    CourseSections courseSection,
    Semesters semester,
    List<ScheduleRule> rules,
  ) {
    final schedules = <Schedules>[];
    int sessionCounter = 1;
    
    // Tính số tuần cần thiết
    final totalSessions = courseSection.totalSessions;
    final sessionsPerWeek = rules.length;
    final totalWeeks = (totalSessions / sessionsPerWeek).ceil();
    
    print('📊 ScheduleGenerator: Tổng ${totalSessions} buổi, ${sessionsPerWeek} buổi/tuần, ${totalWeeks} tuần');
    
    // Bắt đầu từ ngày đầu học kỳ
    DateTime currentDate = semester.startDate;
    
    // Tìm ngày thứ 2 đầu tiên của học kỳ
    while (currentDate.weekday != 1) {
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    // Lặp qua các tuần
    for (int week = 0; week < totalWeeks && sessionCounter <= totalSessions; week++) {
      final weekStartDate = currentDate.add(Duration(days: week * 7));
      
      // Lặp qua các quy tắc trong tuần
      for (final rule in rules) {
        if (sessionCounter > totalSessions) break;
        
        // Tính ngày học trong tuần
        final sessionDate = weekStartDate.add(Duration(days: rule.dayOfWeek - 1));
        
        // Tính thời gian bắt đầu và kết thúc
        final timeSlots = _calculateTimeSlots(rule.periods);
        
        for (final timeSlot in timeSlots) {
          if (sessionCounter > totalSessions) break;
          
          final schedule = Schedules(
            id: 'sched_${courseSection.id}_${sessionCounter.toString().padLeft(3, '0')}',
            courseSectionId: courseSection.id,
            sessionNumber: sessionCounter,
            startTime: DateTime(
              sessionDate.year,
              sessionDate.month,
              sessionDate.day,
              timeSlot.startHour,
              timeSlot.startMinute,
            ),
            endTime: DateTime(
              sessionDate.year,
              sessionDate.month,
              sessionDate.day,
              timeSlot.endHour,
              timeSlot.endMinute,
            ),
            status: ScheduleStatus.scheduled,
            content: '',
            originalScheduleId: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          schedules.add(schedule);
          sessionCounter++;
        }
      }
    }
    
    return schedules;
  }

  /// Tính toán thời gian từ tiết học
  static List<TimeSlot> _calculateTimeSlots(List<int> periods) {
    final timeSlots = <TimeSlot>[];
    
    for (final period in periods) {
      final timeSlot = _getTimeSlotForPeriod(period);
      if (timeSlot != null) {
        timeSlots.add(timeSlot);
      }
    }
    
    return timeSlots;
  }

  /// Lấy thời gian cho một tiết học
  static TimeSlot? _getTimeSlotForPeriod(int period) {
    // Bảng thời gian tiết học chuẩn
    final periodTimes = {
      1: TimeSlot(7, 0, 7, 50),    // Tiết 1: 7:00-7:50
      2: TimeSlot(7, 55, 8, 45),  // Tiết 2: 7:55-8:45
      3: TimeSlot(8, 50, 9, 40),  // Tiết 3: 8:50-9:40
      4: TimeSlot(10, 0, 10, 50), // Tiết 4: 10:00-10:50
      5: TimeSlot(10, 55, 11, 45), // Tiết 5: 10:55-11:45
      6: TimeSlot(12, 0, 12, 50), // Tiết 6: 12:00-12:50
      7: TimeSlot(12, 55, 13, 45), // Tiết 7: 12:55-13:45
      8: TimeSlot(13, 50, 14, 40), // Tiết 8: 13:50-14:40
      9: TimeSlot(15, 0, 15, 50),  // Tiết 9: 15:00-15:50
      10: TimeSlot(15, 55, 16, 45), // Tiết 10: 15:55-16:45
    };
    
    return periodTimes[period];
  }

  /// Lưu danh sách Schedules vào database
  static Future<List<Schedules>> _saveSchedules(List<Schedules> schedules) async {
    final batch = _firestore.batch();
    
    for (final schedule in schedules) {
      final docRef = _firestore.collection('schedules').doc(schedule.id);
      batch.set(docRef, schedule.toJson());
    }
    
    await batch.commit();
    return schedules;
  }

  /// Xóa tất cả Schedules của một CourseSection
  static Future<void> deleteSchedulesForCourseSection(String courseSectionId) async {
    final query = await _firestore
        .collection('schedules')
        .where('courseSectionId', isEqualTo: courseSectionId)
        .get();
    
    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('🗑️ ScheduleGenerator: Đã xóa ${query.docs.length} buổi học của CourseSection: $courseSectionId');
  }
}

/// Quy tắc lịch học
class ScheduleRule {
  final int dayOfWeek; // 1=Thứ 2, 2=Thứ 3, ..., 7=Chủ nhật
  final List<int> periods; // Danh sách tiết học

  ScheduleRule({
    required this.dayOfWeek,
    required this.periods,
  });
}

/// Khoảng thời gian
class TimeSlot {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  TimeSlot(this.startHour, this.startMinute, this.endHour, this.endMinute);
}














