import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Collection references
  static CollectionReference get usersCollection => firestore.collection('users');
  static CollectionReference get departmentsCollection => firestore.collection('departments');
  static CollectionReference get subjectsCollection => firestore.collection('subjects');
  static CollectionReference get classroomsCollection => firestore.collection('classrooms');
  static CollectionReference get roomsCollection => firestore.collection('rooms');
  static CollectionReference get schedulesCollection => firestore.collection('schedules');
  static CollectionReference get attendanceCollection => firestore.collection('attendance');
  static CollectionReference get leaveRequestsCollection => firestore.collection('leaveRequests');
  static CollectionReference get notificationsCollection => firestore.collection('notifications');
  static CollectionReference get lessonsCollection => firestore.collection('lessons');

  // Helper methods for common operations
  static Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await firestore.collection(collection).add(data);
  }

  static Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(docId).update(data);
  }

  static Future<void> deleteDocument(String collection, String docId) async {
    await firestore.collection(collection).doc(docId).delete();
  }

  static Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await firestore.collection(collection).doc(docId).get();
  }

  static Stream<QuerySnapshot> getCollectionStream(String collection) {
    return firestore.collection(collection).snapshots();
  }

  static Future<QuerySnapshot> getCollection(String collection) async {
    return await firestore.collection(collection).get();
  }

  // Batch operations
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    WriteBatch batch = firestore.batch();
    
    for (var operation in operations) {
      String type = operation['type'];
      String collection = operation['collection'];
      String? docId = operation['docId'];
      Map<String, dynamic>? data = operation['data'];
      
      DocumentReference docRef = docId != null 
          ? firestore.collection(collection).doc(docId)
          : firestore.collection(collection).doc();
      
      switch (type) {
        case 'set':
          batch.set(docRef, data!);
          break;
        case 'update':
          batch.update(docRef, data!);
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    }
    
    await batch.commit();
  }
}


