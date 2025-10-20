import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import 'firebase_service.dart';

class RoomService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy danh sách tất cả phòng học
  static Stream<List<Room>> getRoomsStream() {
    print('🏢 RoomService: Lấy stream rooms...');
    return _firestore
        .collection('rooms')
        .snapshots()
        .map((snapshot) {
      print('🏢 RoomService: Nhận được ${snapshot.docs.length} rooms');
      return snapshot.docs.map((doc) {
        return Room.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    });
  }

  // Lấy phòng học theo ID
  static Future<Room?> getRoomById(String roomId) async {
    try {
      print('🏢 RoomService: Lấy room $roomId...');
      final doc = await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        return Room.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      print('❌ RoomService: Lỗi khi lấy room: $e');
      rethrow;
    }
  }

  // Thêm phòng học mới
  static Future<String> addRoom(Room room) async {
    try {
      print('🏢 RoomService: Thêm room mới...');
      final docRef = await _firestore.collection('rooms').add({
        'name': room.name,
        'code': room.code,
        'capacity': room.capacity,
        'type': room.type,
        'floor': room.floor,
        'building': room.building,
        'equipment': room.equipment,
        'description': room.description,
        'isAvailable': room.isAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ RoomService: Đã thêm room với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ RoomService: Lỗi khi thêm room: $e');
      rethrow;
    }
  }

  // Cập nhật phòng học
  static Future<void> updateRoom(String roomId, Room room) async {
    try {
      print('🏢 RoomService: Cập nhật room $roomId...');
      await _firestore.collection('rooms').doc(roomId).update({
        'name': room.name,
        'code': room.code,
        'capacity': room.capacity,
        'type': room.type,
        'floor': room.floor,
        'building': room.building,
        'equipment': room.equipment,
        'description': room.description,
        'isAvailable': room.isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ RoomService: Đã cập nhật room $roomId');
    } catch (e) {
      print('❌ RoomService: Lỗi khi cập nhật room: $e');
      rethrow;
    }
  }

  // Xóa phòng học
  static Future<void> deleteRoom(String roomId) async {
    try {
      print('🏢 RoomService: Xóa room $roomId...');
      await _firestore.collection('rooms').doc(roomId).delete();
      print('✅ RoomService: Đã xóa room $roomId');
    } catch (e) {
      print('❌ RoomService: Lỗi khi xóa room: $e');
      rethrow;
    }
  }

  // Tìm kiếm phòng học
  static Stream<List<Room>> searchRooms(String query) {
    print('🏢 RoomService: Tìm kiếm rooms với query: $query');
    return _firestore
        .collection('rooms')
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs.map((doc) {
        return Room.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
      
      if (query.isEmpty) {
        return rooms;
      }
      
      return rooms.where((room) {
        return room.name.toLowerCase().contains(query.toLowerCase()) ||
               room.code.toLowerCase().contains(query.toLowerCase()) ||
               room.type.toLowerCase().contains(query.toLowerCase()) ||
               (room.building?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (room.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }
}

