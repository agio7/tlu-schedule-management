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
}


