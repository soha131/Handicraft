import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/review_model.dart';
import '../../domain/usecases/review_usecases.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final AddReviewUseCase addUseCase;
  final UpdateReviewUseCase updateUseCase;
  final DeleteReviewUseCase deleteUseCase;
  final GetWorkshopReviewsUseCase getWorkshopReviewsUseCase;

  StreamSubscription? _reviewsSubscription;

  ReviewCubit({
    required this.addUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
    required this.getWorkshopReviewsUseCase,
  }) : super(ReviewInitial());

  void loadWorkshopReviews(String workshopId) {
    emit(ReviewLoading());
    _reviewsSubscription?.cancel();
    _reviewsSubscription = getWorkshopReviewsUseCase(workshopId).listen(
      (reviews) {
        emit(ReviewLoaded(reviews));
      },
      onError: (error) {
        emit(ReviewError(_cleanErrorMessage(error.toString())));
      },
    );
  }

  Future<void> addReview(ReviewModel review) async {
    emit(ReviewActionLoading());
    try {
      await addUseCase(review);
      emit(const ReviewActionSuccess('Review added successfully!'));
    } catch (e) {
      emit(ReviewError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> updateReview(ReviewModel review) async {
    emit(ReviewActionLoading());
    try {
      await updateUseCase(review);
      emit(const ReviewActionSuccess('Review updated successfully!'));
    } catch (e) {
      emit(ReviewError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> deleteReview(String reviewId, String workshopId) async {
    emit(ReviewActionLoading());
    try {
      await deleteUseCase(reviewId, workshopId);
      emit(const ReviewActionSuccess('Review deleted successfully.'));
    } catch (e) {
      emit(ReviewError(_cleanErrorMessage(e.toString())));
    }
  }

  String _cleanErrorMessage(String rawError) {
    return rawError.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  @override
  Future<void> close() {
    _reviewsSubscription?.cancel();
    return super.close();
  }
}
