import '../../data/models/review_model.dart';

abstract class ReviewRepository {
  Future<void> addReview(ReviewModel review);
  Future<void> updateReview(ReviewModel review);
  Future<void> deleteReview(String reviewId, String workshopId);
  Stream<List<ReviewModel>> getWorkshopReviews(String workshopId);
}
