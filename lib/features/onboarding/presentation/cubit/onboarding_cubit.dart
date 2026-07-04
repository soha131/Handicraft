import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_onboarding_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CheckOnboardingUseCase checkOnboardingUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingCubit({
    required this.checkOnboardingUseCase,
    required this.completeOnboardingUseCase,
  }) : super(OnboardingInitial());

  Future<void> checkOnboardingStatus() async {
    emit(OnboardingLoading());
    try {
      final isCompleted = await checkOnboardingUseCase();
      if (isCompleted) {
        emit(OnboardingCompleted());
      } else {
        emit(const OnboardingNotCompleted(pageIndex: 0));
      }
    } catch (e) {
      emit(const OnboardingNotCompleted(pageIndex: 0));
    }
  }

  void updatePageIndex(int index) {
    if (state is OnboardingNotCompleted) {
      emit(OnboardingNotCompleted(pageIndex: index));
    }
  }

  Future<void> completeOnboarding() async {
    emit(OnboardingLoading());
    try {
      await completeOnboardingUseCase();
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingCompleted()); // Fallback to let user in even if cache errors
    }
  }
}
