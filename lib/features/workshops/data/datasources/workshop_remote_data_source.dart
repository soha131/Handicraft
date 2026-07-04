import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class WorkshopRemoteDataSource {
  Future<void> createWorkshop(Map<String, dynamic> workshopData, String docId);
  Future<void> updateWorkshop(String docId, Map<String, dynamic> workshopData);
  Future<void> deleteWorkshop(String docId);
  Future<String> uploadWorkshopImage(String docId, File imageFile);
  Stream<List<Map<String, dynamic>>> getWorkshopsByOwner(String ownerId);
  Stream<List<Map<String, dynamic>>> getAllWorkshops();
}

class WorkshopRemoteDataSourceImpl implements WorkshopRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  WorkshopRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<void> createWorkshop(Map<String, dynamic> workshopData, String docId) async {
    await firestore.collection('workshops').doc(docId).set(workshopData);
  }

  @override
  Future<void> updateWorkshop(String docId, Map<String, dynamic> workshopData) async {
    await firestore.collection('workshops').doc(docId).update(workshopData);
  }

  @override
  Future<void> deleteWorkshop(String docId) async {
    await firestore.collection('workshops').doc(docId).delete();
  }

  @override
  Future<String> uploadWorkshopImage(String docId, File imageFile) async {
    final ref = storage.ref().child('workshops').child('$docId.jpg');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Stream<List<Map<String, dynamic>>> getWorkshopsByOwner(String ownerId) {
    return firestore
        .collection('workshops')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // inject doc id
        return data;
      }).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getAllWorkshops() {
    return firestore
        .collection('workshops')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // inject doc id
        return data;
      }).toList();
    });
  }
}
