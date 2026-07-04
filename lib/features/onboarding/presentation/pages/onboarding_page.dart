import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final int _numPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Model class to represent Onboarding Screens
  List<OnboardingData> _getOnboardingItems() {
    return [
      OnboardingData(
        title: AppStrings.onboardingTitlePottery,
        description: AppStrings.onboardingDescPottery,
        imageUrl: AppAssets.potteryOnboarding,
        icon: Icons.gesture_outlined,
      ),
      OnboardingData(
        title: AppStrings.onboardingTitleWeaving,
        description: AppStrings.onboardingDescWeaving,
        imageUrl: AppAssets.weavingOnboarding,
        icon: Icons.texture_outlined,
      ),
      OnboardingData(
        title: AppStrings.onboardingTitleAI,
        description: AppStrings.onboardingDescAI,
        imageUrl: AppAssets.aiOnboarding,
        icon: Icons.document_scanner_outlined,
      ),
    ];
  }

  void _onNextPressed(int currentIndex) {
    if (currentIndex == _numPages - 1) {
      context.read<OnboardingCubit>().completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onboardingItems = _getOnboardingItems();

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go(AppRouter.welcome);
        }
      },
      child: Scaffold(
        body: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            final int currentIndex = (state is OnboardingNotCompleted) ? state.pageIndex : 0;

            return SafeArea(
              child: Column(
                children: [
                  // Upper Action Area: Skip Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          opacity: currentIndex == _numPages - 1 ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: currentIndex == _numPages - 1,
                            child: TextButton(
                              onPressed: () {
                                context.read<OnboardingCubit>().completeOnboarding();
                              },
                              child: Text(
                                AppStrings.onboardingBtnSkip,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Carousel
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _numPages,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().updatePageIndex(index);
                      },
                      itemBuilder: (context, index) {
                        final item = onboardingItems[index];
                        return _buildSlide(item, theme, isDark);
                      },
                    ),
                  ),

                  // Bottom Action Area
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _numPages,
                            (index) => _buildDot(index, currentIndex),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Button
                        CustomButton(
                          text: currentIndex == _numPages - 1
                              ? AppStrings.onboardingBtnGetStarted
                              : AppStrings.onboardingBtnNext,
                          isGradient: currentIndex == _numPages - 1,
                          onPressed: () => _onNextPressed(currentIndex),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingData item, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image / Shape container
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? AppColors.cardDark : Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? AppColors.cardDark : Colors.grey[250],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    // Light overlay gradient on top
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Icon Floating badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bgLight.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Titles & description
          Text(
            item.title,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              fontSize: 14.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDot(int index, int currentIndex) {
    final bool isSelected = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imageUrl;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.icon,
  });
}
