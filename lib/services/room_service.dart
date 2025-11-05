import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../models/lesson.dart';
import 'firebase_service.dart';

class RoomService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả phòng học
  static Future<List<Room>> getAllRooms() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('rooms').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Room.fromJson({
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        });
      }).toList();
    } catch (e) {
      print('Error getting all rooms: $e');
      return [];
    }
  }

  // Lấy phòng học trống trong một ngày (không cần thời gian cụ thể)
  static Future<List<Room>> getAvailableRooms(DateTime date) async {
    try {
      // Lấy tất cả phòng học
      final allRooms = await getAllRooms();
      
      // Lấy tất cả lessons trong ngày đó
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final lessonsSnapshot = await _firestore
          .collection('lessons')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();
      
      final lessons = lessonsSnapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Lấy danh sách phòng đã được sử dụng trong ngày
      final occupiedRoomIds = <String>{};
      for (var lesson in lessons) {
        if (lesson.roomId != null) {
          occupiedRoomIds.add(lesson.roomId!);
        } else if (lesson.room.isNotEmpty) {
          // Tìm roomId từ room name
          try {
            final room = allRooms.firstWhere(
              (r) => r.code == lesson.room || r.name == lesson.room,
            );
            occupiedRoomIds.add(room.id);
          } catch (e) {
            // Không tìm thấy phòng, bỏ qua
          }
        }
      }
      
      // Lọc ra các phòng trống và available
      return allRooms.where((room) {
        return room.isAvailable && !occupiedRoomIds.contains(room.id);
      }).toList();
    } catch (e) {
      print('Error getting available rooms: $e');
      return [];
    }
  }

  // Kiểm tra xem hai khoảng thời gian có trùng nhau không
  static bool _isTimeOverlapping(String start1, String end1, String start2, String end2) {
    // Parse time strings (format: HH:mm)
    int parseTime(String time) {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    
    final start1Min = parseTime(start1);
    final end1Min = parseTime(end1);
    final start2Min = parseTime(start2);
    final end2Min = parseTime(end2);
    
    // Kiểm tra overlap
    return !(end1Min <= start2Min || start1Min >= end2Min);
  }

  // Lấy các tiết học chuẩn từ Firebase (fallback về danh sách mặc định nếu không có)
  static Future<List<Map<String, String>>> getStandardTimeSlots() async {
    try {
      // Thử lấy từ collection timeSlots trong Firebase
      final snapshot = await _firestore
          .collection('timeSlots')
          .orderBy('startTime')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'start': data['startTime']?.toString() ?? '',
            'end': data['endTime']?.toString() ?? '',
            'slot': data['name']?.toString() ?? data['slot']?.toString() ?? 'Tiết học',
          };
        }).toList();
      }
    } catch (e) {
      print('Error getting time slots from Firebase: $e');
    }
    
    // Fallback: Danh sách tiết học chuẩn mặc định
    return [
      {'start': '07:00', 'end': '08:45', 'slot': 'Tiết 1-2'},
      {'start': '08:55', 'end': '10:40', 'slot': 'Tiết 3-4'},
      {'start': '10:50', 'end': '12:35', 'slot': 'Tiết 5-6'},
      {'start': '13:00', 'end': '14:45', 'slot': 'Tiết 7-8'},
      {'start': '14:55', 'end': '16:40', 'slot': 'Tiết 9-10'},
      {'start': '16:50', 'end': '18:35', 'slot': 'Tiết 11-12'},
      {'start': '18:45', 'end': '20:30', 'slot': 'Tiết 13-14'},
    ];
  }

  // Lấy các tiết học trống trong một ngày
  static Future<List<Map<String, String>>> getAvailableTimeSlots(DateTime date, String? roomId) async {
    try {
      // Lấy các tiết học chuẩn từ Firebase
      final standardTimeSlots = await getStandardTimeSlots();
      
      // Lấy tất cả lessons trong ngày đó
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final lessonsSnapshot = await _firestore
          .collection('lessons')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();
      
      final lessons = lessonsSnapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Lọc các tiết học trống
      final availableSlots = <Map<String, String>>[];
      
      for (var slot in standardTimeSlots) {
        bool isAvailable = true;
        
        // Kiểm tra xem có lesson nào trùng thời gian không
        for (var lesson in lessons) {
          // Nếu có roomId, chỉ kiểm tra lessons trong phòng đó
          if (roomId != null) {
            if (lesson.roomId != roomId) continue;
          }
          
          if (_isTimeOverlapping(
            lesson.startTime,
            lesson.endTime,
            slot['start']!,
            slot['end']!,
          )) {
            isAvailable = false;
            break;
          }
        }
        
        if (isAvailable) {
          availableSlots.add(slot);
        }
      }
      
      return availableSlots;
    } catch (e) {
      print('Error getting available time slots: $e');
      return [];
    }
  }
}

