import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_sections.dart';
import '../models/schedules.dart';
import 'course_section_service.dart';
import 'schedule_service.dart';
import 'firebase_service.dart';

class CsvImportService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Parse CSV content thành List<Map>
  static List<Map<String, String>> parseCsv(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return [];

    // Lấy header (dòng đầu tiên)
    final headers = _parseCsvLine(lines[0]);
    
    // Parse các dòng dữ liệu (bỏ qua dòng header)
    final data = <Map<String, String>>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final values = _parseCsvLine(line);
      if (values.length != headers.length) continue;
      
      final row = <String, String>{};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j].trim()] = values[j].trim();
      }
      data.add(row);
    }
    
    return data;
  }

  // Parse một dòng CSV (xử lý dấu phẩy trong quotes)
  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    String current = '';
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    result.add(current);
    
    return result;
  }

  // Parse scheduleString để lấy thông tin ngày và giờ
  // Ví dụ: "Thứ Hai, Tiết 1-3" -> dayOfWeek: 1, startPeriod: 1, endPeriod: 3
  static Map<String, dynamic> parseScheduleString(String scheduleString) {
    // Map tên thứ sang số (Thứ Hai = 1, Chủ Nhật = 7)
    final dayMap = {
      'hai': 1,
      'ba': 2,
      'tư': 3,
      'năm': 4,
      'sáu': 5,
      'bảy': 6,
      'chủ nhật': 7,
      'cn': 7,
    };

    int dayOfWeek = 1;
    int startPeriod = 1;
    int endPeriod = 3;

    final lower = scheduleString.toLowerCase();
    
    // Tìm thứ trong tuần
    for (final entry in dayMap.entries) {
      if (lower.contains(entry.key)) {
        dayOfWeek = entry.value;
        break;
      }
    }

    // Tìm tiết học (ví dụ: "Tiết 1-3" hoặc "Tiết 1,2,3")
    final periodMatch = RegExp(r'tiết\s*(\d+)(?:\s*[-–]\s*(\d+))?', caseSensitive: false).firstMatch(lower);
    if (periodMatch != null) {
      startPeriod = int.tryParse(periodMatch.group(1) ?? '1') ?? 1;
      endPeriod = int.tryParse(periodMatch.group(2) ?? startPeriod.toString()) ?? startPeriod;
    }

    return {
      'dayOfWeek': dayOfWeek,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
    };
  }

  // Chuyển đổi tiết học sang giờ (Tiết 1 = 7:00, Tiết 2 = 8:00, ...)
  static Map<String, int> periodToTime(int period) {
    // Mỗi tiết 50 phút, nghỉ 10 phút giữa các tiết
    // Tiết 1: 7:00-7:50
    // Tiết 2: 8:00-8:50
    // Tiết 3: 9:00-9:50
    // ...
    final startHour = 6 + period; // Bắt đầu từ 7:00 (period 1 -> hour 7)
    final startMinute = 0;
    
    return {
      'hour': startHour,
      'minute': startMinute,
    };
  }
  
  // Tính giờ kết thúc dựa trên tiết cuối
  static Map<String, int> periodToEndTime(int endPeriod) {
    // Tiết kết thúc sau 50 phút
    final endHour = 6 + endPeriod;
    final endMinute = 50;
    
    return {
      'hour': endHour,
      'minute': endMinute,
    };
  }

  // Tìm ngày đầu tiên của thứ trong tuần kể từ startDate
  static DateTime findFirstDayOfWeek(DateTime startDate, int dayOfWeek) {
    // dayOfWeek: 1 = Monday, 7 = Sunday
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    final currentWeekday = startDate.weekday;
    int daysToAdd = dayOfWeek - currentWeekday;
    
    if (daysToAdd < 0) {
      daysToAdd += 7; // Nếu đã qua thứ đó trong tuần, chuyển sang tuần sau
    }
    
    return startDate.add(Duration(days: daysToAdd));
  }

  // Sinh lịch cho một CourseSection
  static List<Schedules> generateSchedules({
    required String courseSectionId,
    required int totalSessions,
    required String scheduleString,
    required DateTime semesterStartDate,
  }) {
    final schedules = <Schedules>[];
    final scheduleInfo = parseScheduleString(scheduleString);
    final dayOfWeek = scheduleInfo['dayOfWeek'] as int;
    final startPeriod = scheduleInfo['startPeriod'] as int;
    final endPeriod = scheduleInfo['endPeriod'] as int;

    // Tìm ngày đầu tiên của thứ trong tuần
    DateTime currentDate = findFirstDayOfWeek(semesterStartDate, dayOfWeek);
    
    // Lấy giờ bắt đầu và kết thúc từ tiết học
    final startTimeInfo = periodToTime(startPeriod);
    final endTimeInfo = periodToEndTime(endPeriod);

    for (int session = 1; session <= totalSessions; session++) {
      final startTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        startTimeInfo['hour']!,
        startTimeInfo['minute']!,
      );
      
      final endTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        endTimeInfo['hour']!,
        endTimeInfo['minute']!,
      );

      final schedule = Schedules(
        id: '', // Will be set by Firestore
        courseSectionId: courseSectionId,
        sessionNumber: session,
        startTime: startTime,
        endTime: endTime,
        status: ScheduleStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      schedules.add(schedule);
      
      // Chuyển sang tuần tiếp theo
      currentDate = currentDate.add(const Duration(days: 7));
    }

    return schedules;
  }

  // Import CSV và tạo CourseSections + Schedules
  static Future<Map<String, dynamic>> importCsvAndGenerateSchedules({
    required String csvContent,
    required String semesterId,
    required DateTime semesterStartDate,
  }) async {
    try {
      // Parse CSV
      final csvData = parseCsv(csvContent);
      if (csvData.isEmpty) {
        return {
          'success': false,
          'message': 'File CSV không có dữ liệu',
        };
      }

      final sectionsToCreate = <CourseSections>[];
      final schedulesToCreate = <Schedules>[];

      // Lặp qua từng hàng CSV
      for (final row in csvData) {
        try {
          // Ánh xạ các cột CSV
          final maLHP = row['MaLHP'] ?? '';
          final maMonHoc = row['MaMonHoc'] ?? '';
          final maGV = row['MaGV'] ?? '';
          final maLopSH = row['MaLopSH'] ?? '';
          final maPhong = row['MaPhong'] ?? '';
          final soBuoi = int.tryParse(row['SoBuoi'] ?? '0') ?? 0;
          final lichHocChuoi = row['LichHocChuoi'] ?? '';

          if (maLHP.isEmpty || maMonHoc.isEmpty || soBuoi == 0 || lichHocChuoi.isEmpty) {
            continue; // Bỏ qua hàng không đủ thông tin
          }

          // Tạo CourseSection
          final courseSection = CourseSections(
            id: maLHP, // Dùng MaLHP làm ID
            subjectId: maMonHoc,
            teacherId: maGV,
            classroomId: maLopSH,
            roomId: maPhong,
            semesterId: semesterId,
            totalSessions: soBuoi,
            scheduleString: lichHocChuoi,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          sectionsToCreate.add(courseSection);

          // Sinh lịch cho CourseSection này
          final schedules = generateSchedules(
            courseSectionId: maLHP,
            totalSessions: soBuoi,
            scheduleString: lichHocChuoi,
            semesterStartDate: semesterStartDate,
          );

          schedulesToCreate.addAll(schedules);
        } catch (e) {
          print('❌ Lỗi khi xử lý hàng CSV: $e');
          continue;
        }
      }

      if (sectionsToCreate.isEmpty) {
        return {
          'success': false,
          'message': 'Không có dữ liệu hợp lệ để nhập',
        };
      }

      // Batch write CourseSections
      WriteBatch batch = _firestore.batch();
      for (final section in sectionsToCreate) {
        final docRef = _firestore.collection('courseSections').doc(section.id);
        batch.set(docRef, section.toJson());
      }
      await batch.commit();

      // Batch write Schedules (chia nhỏ nếu quá nhiều)
      const batchLimit = 500; // Firestore limit
      for (int i = 0; i < schedulesToCreate.length; i += batchLimit) {
        final batch = _firestore.batch();
        final end = (i + batchLimit < schedulesToCreate.length) 
            ? i + batchLimit 
            : schedulesToCreate.length;
        
        for (int j = i; j < end; j++) {
          final schedule = schedulesToCreate[j];
          final docRef = _firestore.collection('schedules').doc();
          batch.set(docRef, schedule.toJson());
        }
        
        await batch.commit();
      }

      return {
        'success': true,
        'message': 'Nhập thành công! Đã tạo ${sectionsToCreate.length} lớp học phần và ${schedulesToCreate.length} buổi học chi tiết.',
        'sectionsCount': sectionsToCreate.length,
        'schedulesCount': schedulesToCreate.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi khi nhập file: $e',
      };
    }
  }
}

