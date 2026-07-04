import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingNotCompleted extends OnboardingState {
  final int pageIndex;

  const OnboardingNotCompleted({this.pageIndex = 0});

  OnboardingNotCompleted copyWith({int? pageIndex}) {
    return OnboardingNotCompleted(
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }

  @override
  List<Object?> get props => [pageIndex];
}

class OnboardingCompleted extends OnboardingState {}
