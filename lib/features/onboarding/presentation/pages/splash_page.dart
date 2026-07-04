import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Trigger onboarding status check
    context.read<OnboardingCubit>().checkOnboardingStatus();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Called each time onboarding or auth state changes.
  /// Reads state synchronously BEFORE the Future.delayed gap to avoid
  /// using BuildContext across an async gap (use_build_context_synchronously).
  void _checkAndNavigate(BuildContext context) {
    if (_hasNavigated) return;

    final onboardingState = context.read<OnboardingCubit>().state;
    final authState = context.read<AuthCubit>().state;

    // Wait until both cubits have resolved from their initial state
    if (onboardingState is OnboardingInitial || authState is AuthInitial) {
      return;
    }

    _hasNavigated = true;

    // Capture the destination route synchronously before the timer fires
    final String destination;
    if (onboardingState is OnboardingCompleted) {
      destination =
          authState is Authenticated ? AppRouter.home : AppRouter.welcome;
    } else {
      destination = AppRouter.onboarding;
    }

    // Capture the router reference synchronously before the async gap
    final router = GoRouter.of(context);

    // Delay to let the splash animation breathe, then navigate
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      // Use captured [router] and [destination] — no BuildContext read after async gap
      router.go(destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OnboardingCubit, OnboardingState>(
          listener: (context, state) => _checkAndNavigate(context),
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) => _checkAndNavigate(context),
        ),
      ],
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Dark artisan image background
            CachedNetworkImage(
              imageUrl: AppAssets.splashBackground,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.bgDark),
              errorWidget: (context, url, error) =>
                  Container(color: AppColors.bgDark),
            ),
            // Vignette dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Animated Brand identity
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing Artisan Logo Icon
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.palette_outlined,
                          color: AppColors.accent,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // App name
                      Text(
                        AppStrings.appName.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                          shadows: const [Shadows.shadow1],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      Text(
                        AppStrings.splashTagline,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                          fontSize: 14,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Loading indicator at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LOADING EXPERIENCE',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shadow utility for splash typography
class Shadows {
  static const shadow1 = Shadow(
    color: Colors.black45,
    offset: Offset(0, 4),
    blurRadius: 10,
  );
}
