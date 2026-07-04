import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  
  const ReviewLoaded(this.reviews);
  
  @override
  List<Object?> get props => [reviews];
}

class ReviewActionLoading extends ReviewState {}

class ReviewActionSuccess extends ReviewState {
  final String message;
  
  const ReviewActionSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ReviewError extends ReviewState {
  final String message;
  
  const ReviewError(this.message);
  
  @override
  List<Object?> get props => [message];
}
