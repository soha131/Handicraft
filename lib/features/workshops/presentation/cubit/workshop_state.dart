import 'package:equatable/equatable.dart';
import '../../data/models/workshop_model.dart';

abstract class WorkshopState extends Equatable {
  const WorkshopState();
  @override
  List<Object?> get props => [];
}

class WorkshopInitial extends WorkshopState {}

class WorkshopLoading extends WorkshopState {}

class WorkshopLoaded extends WorkshopState {
  final List<WorkshopModel> workshops;
  const WorkshopLoaded(this.workshops);
  
  @override
  List<Object?> get props => [workshops];
}

class WorkshopError extends WorkshopState {
  final String message;
  const WorkshopError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class WorkshopActionLoading extends WorkshopState {}

class WorkshopActionSuccess extends WorkshopState {
  final String message;
  const WorkshopActionSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
