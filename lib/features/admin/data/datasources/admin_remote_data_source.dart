import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AdminRemoteDataSource {
  // Dashboard stats
  Future<Map<String, int>> getDashboardStats();

  // Users
  Stream<List<Map<String, dynamic>>> getAllUsers();
  Future<void> deleteUser(String uid);
  Future<void> updateUserRole(String uid, String newRole);

  // Workshops
  Stream<List<Map<String, dynamic>>> getAllWorkshopsAdmin();
  Future<void> deleteWorkshopAdmin(String workshopId);

  // Reviews
  Stream<List<Map<String, dynamic>>> getAllReviewsAdmin();
  Future<void> deleteReviewAdmin(String reviewId, String workshopId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Map<String, int>> getDashboardStats() async {
    final results = await Future.wait([
      firestore.collection('users').count().get(),
      firestore.collection('workshops').count().get(),
      firestore.collection('bookings').count().get(),
      firestore.collection('reviews').count().get(),
    ]);
    return {
      'users': results[0].count ?? 0,
      'workshops': results[1].count ?? 0,
      'bookings': results[2].count ?? 0,
      'reviews': results[3].count ?? 0,
    };
  }

  @override
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['uid'] = d.id;
              return data;
            }).toList());
  }

  @override
  Future<void> deleteUser(String uid) async {
    await firestore.collection('users').doc(uid).delete();
  }

  @override
  Future<void> updateUserRole(String uid, String newRole) async {
    await firestore.collection('users').doc(uid).update({'role': newRole});
  }

  @override
  Stream<List<Map<String, dynamic>>> getAllWorkshopsAdmin() {
    return firestore
        .collection('workshops')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  @override
  Future<void> deleteWorkshopAdmin(String workshopId) async {
    final batch = firestore.batch();
    batch.delete(firestore.collection('workshops').doc(workshopId));
    // Delete associated bookings
    final bookings = await firestore
        .collection('bookings')
        .where('workshopId', isEqualTo: workshopId)
        .get();
    for (final doc in bookings.docs) {
      batch.delete(doc.reference);
    }
    // Delete associated reviews
    final reviews = await firestore
        .collection('reviews')
        .where('workshopId', isEqualTo: workshopId)
        .get();
    for (final doc in reviews.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Stream<List<Map<String, dynamic>>> getAllReviewsAdmin() {
    return firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  @override
  Future<void> deleteReviewAdmin(String reviewId, String workshopId) async {
    final reviewRef = firestore.collection('reviews').doc(reviewId);
    final workshopRef = firestore.collection('workshops').doc(workshopId);

    await firestore.runTransaction((tx) async {
      final reviewDoc = await tx.get(reviewRef);
      if (!reviewDoc.exists) return;
      final oldRating = (reviewDoc.data()!['rating'] as num).toDouble();

      final workshopDoc = await tx.get(workshopRef);
      if (workshopDoc.exists) {
        final data = workshopDoc.data()!;
        final int currentTotal = data['totalReviews'] as int? ?? 1;
        final double currentAverage = (data['averageRating'] as num?)?.toDouble() ?? oldRating;

        final int newTotal = currentTotal > 1 ? currentTotal - 1 : 0;
        final double newAverage = newTotal > 0
            ? ((currentAverage * currentTotal) - oldRating) / newTotal
            : 0.0;

        tx.update(workshopRef, {
          'totalReviews': newTotal,
          'averageRating': newAverage,
        });
      }
      tx.delete(reviewRef);
    });
  }
}
