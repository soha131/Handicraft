import '../repositories/review_repository.dart';
import '../../data/models/review_model.dart';

class AddReviewUseCase {
  final ReviewRepository repository;
  
  AddReviewUseCase(this.repository);
  
  Future<void> call(ReviewModel review) {
    return repository.addReview(review);
  }
}

class UpdateReviewUseCase {
  final ReviewRepository repository;
  
  UpdateReviewUseCase(this.repository);
  
  Future<void> call(ReviewModel review) {
    return repository.updateReview(review);
  }
}

class DeleteReviewUseCase {
  final ReviewRepository repository;
  
  DeleteReviewUseCase(this.repository);
  
  Future<void> call(String reviewId, String workshopId) {
    return repository.deleteReview(reviewId, workshopId);
  }
}

class GetWorkshopReviewsUseCase {
  final ReviewRepository repository;
  
  GetWorkshopReviewsUseCase(this.repository);
  
  Stream<List<ReviewModel>> call(String workshopId) {
    return repository.getWorkshopReviews(workshopId);
  }
}
