import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ReviewRemoteDataSource {
  Future<void> addReview(Map<String, dynamic> reviewData, String reviewId, String workshopId);
  Future<void> updateReview(Map<String, dynamic> reviewData, String reviewId, String workshopId);
  Future<void> deleteReview(String reviewId, String workshopId);
  Stream<List<Map<String, dynamic>>> getWorkshopReviews(String workshopId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  ReviewRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addReview(Map<String, dynamic> reviewData, String reviewId, String workshopId) async {
    final batch = firestore.batch();
    
    // Add review doc
    final reviewRef = firestore.collection('reviews').doc(reviewId);
    batch.set(reviewRef, reviewData);
    
    // Update workshop average rating
    final workshopRef = firestore.collection('workshops').doc(workshopId);
    
    // Read the current workshop data within a transaction or just update via cloud function.
    // For client-side simulation, we will run a transaction instead of batch to read old averages.
    
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(workshopRef);
      if (doc.exists) {
        final data = doc.data()!;
        final int currentTotal = data['totalReviews'] as int? ?? 0;
        final double currentAverage = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
        
        final double newRating = (reviewData['rating'] as num).toDouble();
        final int newTotal = currentTotal + 1;
        final double newAverage = ((currentAverage * currentTotal) + newRating) / newTotal;
        
        transaction.update(workshopRef, {
          'totalReviews': newTotal,
          'averageRating': newAverage,
        });
      }
      transaction.set(reviewRef, reviewData);
    });
  }

  @override
  Future<void> updateReview(Map<String, dynamic> reviewData, String reviewId, String workshopId) async {
    final reviewRef = firestore.collection('reviews').doc(reviewId);
    final workshopRef = firestore.collection('workshops').doc(workshopId);

    await firestore.runTransaction((transaction) async {
      final reviewDoc = await transaction.get(reviewRef);
      if (!reviewDoc.exists) return;
      
      final oldRating = (reviewDoc.data()!['rating'] as num).toDouble();
      final newRating = (reviewData['rating'] as num).toDouble();
      
      final workshopDoc = await transaction.get(workshopRef);
      if (workshopDoc.exists) {
        final data = workshopDoc.data()!;
        final int currentTotal = data['totalReviews'] as int? ?? 1;
        final double currentAverage = (data['averageRating'] as num?)?.toDouble() ?? oldRating;
        
        // Remove old rating, add new rating
        final double newAverage = ((currentAverage * currentTotal) - oldRating + newRating) / currentTotal;
        
        transaction.update(workshopRef, {
          'averageRating': newAverage,
        });
      }
      transaction.update(reviewRef, reviewData);
    });
  }

  @override
  Future<void> deleteReview(String reviewId, String workshopId) async {
    final reviewRef = firestore.collection('reviews').doc(reviewId);
    final workshopRef = firestore.collection('workshops').doc(workshopId);

    await firestore.runTransaction((transaction) async {
      final reviewDoc = await transaction.get(reviewRef);
      if (!reviewDoc.exists) return;
      
      final oldRating = (reviewDoc.data()!['rating'] as num).toDouble();
      
      final workshopDoc = await transaction.get(workshopRef);
      if (workshopDoc.exists) {
        final data = workshopDoc.data()!;
        final int currentTotal = data['totalReviews'] as int? ?? 1;
        final double currentAverage = (data['averageRating'] as num?)?.toDouble() ?? oldRating;
        
        final int newTotal = currentTotal > 1 ? currentTotal - 1 : 0;
        final double newAverage = newTotal > 0 ? ((currentAverage * currentTotal) - oldRating) / newTotal : 0.0;
        
        transaction.update(workshopRef, {
          'totalReviews': newTotal,
          'averageRating': newAverage,
        });
      }
      transaction.delete(reviewRef);
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getWorkshopReviews(String workshopId) {
    return firestore
        .collection('reviews')
        .where('workshopId', isEqualTo: workshopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
