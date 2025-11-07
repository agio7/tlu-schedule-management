import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rooms.dart';
import 'firebase_service.dart';

class RoomService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả rooms
  static Stream<List<Rooms>> getRoomsStream() {
    return _firestore.collection('rooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Rooms.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy rooms theo building
  static Stream<List<Rooms>> getRoomsByBuildingStream(String building) {
    return _firestore
        .collection('rooms')
        .where('building', isEqualTo: building)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Rooms.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm room mới
  static Future<String> addRoom(Rooms room) async {
    final docRef = await _firestore.collection('rooms').add(room.toJson());
    return docRef.id;
  }

  // Cập nhật room
  static Future<void> updateRoom(String roomId, Rooms room) async {
    await _firestore.collection('rooms').doc(roomId).update(room.toJson());
  }

  // Xóa room
  static Future<void> deleteRoom(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).delete();
  }

  // Lấy room theo ID
  static Future<Rooms?> getRoomById(String roomId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      return Rooms.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  // ==== Added for leave_registration_tab ==== 
  static Future<List<Rooms>> getAvailableRooms(DateTime date) async {
    // Simple implementation: return all rooms. You can refine by excluding occupied rooms for the date.
    final snapshot = await _firestore.collection('rooms').get();
    return snapshot.docs.map((d) => Rooms.fromJson(d.id, d.data())).toList();
  }

  static Future<List<Map<String, String>>> getAvailableTimeSlots(DateTime date, String roomId) async {
    // Simple demo time slots; replace with actual schedule conflict checks if needed
    final slots = <Map<String, String>>[
      {'slot': 'Tiết 1-2', 'start': '07:00', 'end': '08:50'},
      {'slot': 'Tiết 3-4', 'start': '09:00', 'end': '10:50'},
      {'slot': 'Tiết 5-6', 'start': '13:00', 'end': '14:50'},
      {'slot': 'Tiết 7-8', 'start': '15:00', 'end': '16:50'},
    ];
    return slots;
  }
}