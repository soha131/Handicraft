import 'package:uuid/uuid.dart';

import '../models/review_model.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final Uuid _uuid = const Uuid();
  
  final List<ReviewModel> _devReviews = [];

  ReviewRepositoryImpl({required this.remoteDataSource});

  bool _isFirebaseConfigError(Object e) {
    final msg = e.toString();
    return msg.contains('no-app') ||
        msg.contains('core/') ||
        msg.contains('FirebaseException') ||
        msg.contains('cloud_firestore');
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    try {
      final docId = _uuid.v4();
      final newReview = review.copyWith(id: docId);
      await remoteDataSource.addReview(newReview.toMap(), docId, newReview.workshopId);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        final docId = _uuid.v4();
        _devReviews.add(review.copyWith(id: docId));
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    try {
      await remoteDataSource.updateReview(review.toMap(), review.id, review.workshopId);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        final index = _devReviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          _devReviews[index] = review;
        }
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteReview(String reviewId, String workshopId) async {
    try {
      await remoteDataSource.deleteReview(reviewId, workshopId);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        _devReviews.removeWhere((r) => r.id == reviewId);
        return;
      }
      rethrow;
    }
  }

  @override
  Stream<List<ReviewModel>> getWorkshopReviews(String workshopId) {
    try {
      return remoteDataSource.getWorkshopReviews(workshopId).map((list) {
        return list.map((map) => ReviewModel.fromMap(map, map['id'] as String)).toList();
      }).handleError((e) {
        if (_isFirebaseConfigError(e)) {
          return Stream.value(_devReviews.where((r) => r.workshopId == workshopId).toList());
        }
        throw e;
      });
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        return Stream.value(_devReviews.where((r) => r.workshopId == workshopId).toList());
      }
      rethrow;
    }
  }
}
