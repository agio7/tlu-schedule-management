import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_request.dart';
import 'firebase_service.dart';

class LeaveRequestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả leave requests (từ cả leaveRequests và makeupRequests)
  static Future<List<LeaveRequest>> getAllLeaveRequests() async {
    try {
      final results = await Future.wait([
        _firestore.collection('leaveRequests').get(),
        _firestore.collection('makeupRequests').get(),
      ]);
      
      final allRequests = <LeaveRequest>[];
      
      for (var doc in results[0].docs) {
        try {
          allRequests.add(LeaveRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        } catch (e) {
          print('Error parsing leave request ${doc.id}: $e');
        }
      }
      
      for (var doc in results[1].docs) {
        try {
          allRequests.add(LeaveRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        } catch (e) {
          print('Error parsing makeup request ${doc.id}: $e');
        }
      }
      
      return allRequests;
    } catch (e) {
      print('Error getting all requests: $e');
      return [];
    }
  }

  // Lấy leave requests theo teacher ID (lấy từ cả leaveRequests và makeupRequests)
  // Hỗ trợ query với nhiều teacherId để tương thích với dữ liệu cũ
  static Future<List<LeaveRequest>> getLeaveRequestsByTeacher(String teacherId, {List<String>? additionalTeacherIds}) async {
    try {
      print(' Querying Firebase for requests where teacherId = "$teacherId"');
      
      // Tạo danh sách teacherIds để query (bao gồm teacherId chính và các ID bổ sung)
      final teacherIdsToQuery = <String>[teacherId];
      if (additionalTeacherIds != null && additionalTeacherIds.isNotEmpty) {
        teacherIdsToQuery.addAll(additionalTeacherIds);
        print(' Also querying with additional teacherIds: $additionalTeacherIds');
      }
      
      // Debug: Lấy tất cả requests để xem teacherId thực tế trong Firebase
      print(' DEBUG: Checking all requests in Firebase...');
      final allLeaveRequests = await _firestore.collection('leaveRequests').limit(10).get();
      final allMakeupRequests = await _firestore.collection('makeupRequests').limit(10).get();
      
      print('Total leaveRequests in Firebase: ${allLeaveRequests.docs.length}');
      print(' Total makeupRequests in Firebase: ${allMakeupRequests.docs.length}');
      
      print('Sample teacherIds in leaveRequests:');
      for (var doc in allLeaveRequests.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docTeacherId = data['teacherId']?.toString() ?? 'null';
        print('   - Doc ID: ${doc.id}, teacherId: "$docTeacherId" (match: ${docTeacherId == teacherId})');
      }
      
      print(' Sample teacherIds in makeupRequests:');
      for (var doc in allMakeupRequests.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docTeacherId = data['teacherId']?.toString() ?? 'null';
        print('   - Doc ID: ${doc.id}, teacherId: "$docTeacherId" (match: ${docTeacherId == teacherId})');
      }
      
      // Lấy từ cả 2 collection với tất cả teacherIds
      final allLeaveQueries = teacherIdsToQuery.map((tid) => 
        _firestore.collection('leaveRequests').where('teacherId', isEqualTo: tid).get()
      ).toList();
      final allMakeupQueries = teacherIdsToQuery.map((tid) => 
        _firestore.collection('makeupRequests').where('teacherId', isEqualTo: tid).get()
      ).toList();
      
      final leaveResults = await Future.wait(allLeaveQueries);
      final makeupResults = await Future.wait(allMakeupQueries);
      
      // Merge tất cả kết quả và loại bỏ duplicate
      final leaveDocIds = <String>{};
      final leaveRequests = <QueryDocumentSnapshot>[];
      for (var result in leaveResults) {
        for (var doc in result.docs) {
          if (!leaveDocIds.contains(doc.id)) {
            leaveDocIds.add(doc.id);
            leaveRequests.add(doc);
          }
        }
      }
      
      final makeupDocIds = <String>{};
      final makeupRequests = <QueryDocumentSnapshot>[];
      for (var result in makeupResults) {
        for (var doc in result.docs) {
          if (!makeupDocIds.contains(doc.id)) {
            makeupDocIds.add(doc.id);
            makeupRequests.add(doc);
          }
        }
      }
      
      print('Found ${leaveRequests.length} leave requests with teacherIds = $teacherIdsToQuery');
      print(' Found ${makeupRequests.length} makeup requests with teacherIds = $teacherIdsToQuery');
      
      // Nếu không tìm thấy makeup requests, thử lấy tất cả và filter ở client
      if (makeupRequests.isEmpty) {
        print('No makeup requests found with teacherId = "$teacherId"');
        print(' Trying to get all makeup requests and filter...');
        final allMakeupRequests = await _firestore.collection('makeupRequests').get();
        print('Total makeup requests in Firebase: ${allMakeupRequests.docs.length}');
        
        final filteredMakeup = allMakeupRequests.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final docTeacherId = data['teacherId']?.toString() ?? '';
          final matches = docTeacherId == teacherId;
          if (!matches && allMakeupRequests.docs.length <= 20) {
            print('   - Doc ${doc.id}: teacherId="$docTeacherId" (match: $matches)');
          }
          return matches;
        }).toList();
        
        print('Filtered ${filteredMakeup.length} makeup requests matching teacherId');
        
        // Thay thế kết quả nếu tìm thấy
        if (filteredMakeup.isNotEmpty) {
          print(' Using filtered makeup requests');
          // Sử dụng filtered results
          final allRequests = <LeaveRequest>[];
          
          for (var doc in leaveRequests) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              if (data['type'] == null) {
                data['type'] = 'leave';
              }
              final request = LeaveRequest.fromMap(data, doc.id);
              allRequests.add(request);
            } catch (e) {
              print(' Error parsing leave request ${doc.id}: $e');
            }
          }
          
          for (var doc in filteredMakeup) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              if (data['type'] == null || data['type'].toString().isEmpty) {
                data['type'] = 'makeup';
              }
              final request = LeaveRequest.fromMap(data, doc.id);
              print('    Parsed makeup request: ID=${request.id}, type=${request.type}');
              allRequests.add(request);
            } catch (e) {
              print('Error parsing makeup request ${doc.id}: $e');
            }
          }
          
          print(' Tổng số requests sau khi merge: ${allRequests.length}');
          print('   - Leave: ${allRequests.where((r) => r.type == 'leave').length}');
          print('   - Makeup: ${allRequests.where((r) => r.type == 'makeup').length}');
          
          return allRequests;
        }
      }
      
      // Debug: In chi tiết từng request
      for (var doc in leaveRequests) {
        final data = doc.data() as Map<String, dynamic>;
        print('   Leave Request: ID=${doc.id}, type=${data['type']}, teacherId=${data['teacherId']}');
      }
      
      for (var doc in makeupRequests) {
        final data = doc.data() as Map<String, dynamic>;
        print('    Makeup Request: ID=${doc.id}, type=${data['type']}, teacherId=${data['teacherId']}');
      }
      
      // Merge cả 2 danh sách
      final allRequests = <LeaveRequest>[];
      
      for (var doc in leaveRequests) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          // Đảm bảo type là 'leave' cho leaveRequests
          if (data['type'] == null) {
            data['type'] = 'leave';
          }
          final request = LeaveRequest.fromMap(data, doc.id);
          print('    Parsed leave request: ID=${request.id}, type=${request.type}');
          allRequests.add(request);
        } catch (e) {
          print(' Error parsing leave request ${doc.id}: $e');
          print('   Data: ${doc.data()}');
        }
      }
      
      for (var doc in makeupRequests) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          // Đảm bảo type là 'makeup' cho makeupRequests
          if (data['type'] == null) {
            data['type'] = 'makeup';
          }
          final request = LeaveRequest.fromMap(data, doc.id);
          print('    Parsed makeup request: ID=${request.id}, type=${request.type}');
          allRequests.add(request);
        } catch (e) {
          print(' Error parsing makeup request ${doc.id}: $e');
          print('   Data: ${doc.data()}');
        }
      }
      
      print(' Tổng số requests sau khi merge: ${allRequests.length}');
      print('   - Leave: ${allRequests.where((r) => r.type == 'leave').length}');
      print('   - Makeup: ${allRequests.where((r) => r.type == 'makeup').length}');
      
      return allRequests;
    } catch (e) {
      print(' Error getting requests by teacher: $e');
      return [];
    }
  }

  // Tạo leave request mới
  static Future<String?> createLeaveRequest(LeaveRequest request) async {
    try {
      print(' Đang tạo request...');
      print('   Type: ${request.type}');
      print('   TeacherId: ${request.teacherId}');
      print('   LessonId: ${request.lessonId}');
      print('   MakeupDate: ${request.makeupDate}');
      
      final data = request.toMap();
      print(' Data to save: ${data.keys.toList()}');
      print('TeacherId trong data: ${data['teacherId']}');
      
      // Chọn collection dựa trên type
      final String collectionName = request.type == 'makeup' ? 'makeupRequests' : 'leaveRequests';
      print(' Lưu vào collection: $collectionName');
      // Kiểm tra xem teacherId có null hoặc empty không
      if (data['teacherId'] == null || data['teacherId'].toString().isEmpty) {
        throw Exception('TeacherId không được để trống');
      }
      
      final DocumentReference docRef = await _firestore.collection(collectionName).add(data);
      print('Đã tạo ${request.type} request thành công với ID: ${docRef.id}');
      
      return docRef.id;
    } catch (e, stackTrace) {
      print(' Error creating request: $e');
      print('   Stack trace: $stackTrace');
      print('   Request data: ${request.toMap()}');
      return null;
    }
  }

  // Cập nhật leave request (cần biết collection để update đúng)
  static Future<bool> updateLeaveRequest(String requestId, LeaveRequest request, {String? collectionName}) async {
    try {
      // Nếu không có collectionName, tự động xác định dựa trên type
      final String targetCollection = collectionName ?? (request.type == 'makeup' ? 'makeupRequests' : 'leaveRequests');
      await _firestore.collection(targetCollection).doc(requestId).update(request.toMap());
      return true;
    } catch (e) {
      print('Error updating request: $e');
      return false;
    }
  }

  // Xóa leave request (cần biết collection để xóa đúng)
  static Future<bool> deleteLeaveRequest(String requestId, {String? collectionName, String? type}) async {
    try {
      // Nếu không có collectionName, tự động xác định dựa trên type
      final String targetCollection = collectionName ?? (type == 'makeup' ? 'makeupRequests' : 'leaveRequests');
      await _firestore.collection(targetCollection).doc(requestId).delete();
      return true;
    } catch (e) {
      print('Error deleting request: $e');
      return false;
    }
  }

  // Stream leave requests theo teacher (real-time updates) - từ cả 2 collection
  static Stream<List<LeaveRequest>> getLeaveRequestsStreamByTeacher(String teacherId) {
    // Combine streams từ cả 2 collection
    final leaveStream = _firestore
        .collection('leaveRequests')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
    
    final makeupStream = _firestore
        .collection('makeupRequests')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
    
    // Combine 2 streams bằng cách merge
    StreamController<List<LeaveRequest>>? controller;
    StreamSubscription<QuerySnapshot>? leaveSub;
    StreamSubscription<QuerySnapshot>? makeupSub;
    
    QuerySnapshot? leaveSnapshot;
    QuerySnapshot? makeupSnapshot;
    
    void emitCombined() {
      final allRequests = <LeaveRequest>[];
      
      if (leaveSnapshot != null) {
        for (var doc in leaveSnapshot!.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            // Đảm bảo type là 'leave' cho leaveRequests
            if (data['type'] == null || data['type'].toString().isEmpty) {
              data['type'] = 'leave';
            }
            allRequests.add(LeaveRequest.fromMap(data, doc.id));
          } catch (e) {
            print('Error parsing leave request ${doc.id}: $e');
          }
        }
      }
      
      if (makeupSnapshot != null) {
        for (var doc in makeupSnapshot!.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            // Đảm bảo type là 'makeup' cho makeupRequests
            if (data['type'] == null || data['type'].toString().isEmpty) {
              data['type'] = 'makeup';
            }
            allRequests.add(LeaveRequest.fromMap(data, doc.id));
          } catch (e) {
            print('Error parsing makeup request ${doc.id}: $e');
          }
        }
      }
      
      // Sort theo createdAt descending
      allRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      controller?.add(allRequests);
    }
    
    controller = StreamController<List<LeaveRequest>>(
      onListen: () {
        leaveSub = leaveStream.listen((snapshot) {
          leaveSnapshot = snapshot;
          emitCombined();
        });
        
        makeupSub = makeupStream.listen((snapshot) {
          makeupSnapshot = snapshot;
          emitCombined();
        });
      },
      onCancel: () {
        leaveSub?.cancel();
        makeupSub?.cancel();
        controller?.close();
      },
    );
    
    return controller.stream;
  }
}

