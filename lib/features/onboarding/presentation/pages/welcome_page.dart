import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Track selected user role (0: Learner, 1: Owner, 2: Admin)
  int _selectedRoleIndex = 0;

  void _onRoleSelected(int index) {
    setState(() {
      _selectedRoleIndex = index;
    });
  }

  void _handleContinue() {
    String roleKey = 'learner';
    if (_selectedRoleIndex == 1) roleKey = 'workshop_owner';
    context.push('/register?role=$roleKey');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Visual backdrop representing craft workspace
          CachedNetworkImage(
            imageUrl: AppAssets.welcomeBackground,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.bgDark),
            errorWidget: (context, url, error) => Container(color: AppColors.bgDark),
          ),
          // Clean layered glass gradient overlay (higher saturation near bottom)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.65),
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                  isDark ? AppColors.bgDark.withValues(alpha: 0.95) : AppColors.bgLight.withValues(alpha: 0.98),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // App branding header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textMainLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Heading text
                  Text(
                    AppStrings.welcomeTitle,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.welcomeSubtitle,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Roles Selection Section
                  _buildRoleCard(
                    index: 0,
                    title: AppStrings.welcomeRoleLearner,
                    description: AppStrings.welcomeRoleLearnerDesc,
                    icon: Icons.school_outlined,
                    isSelected: _selectedRoleIndex == 0,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildRoleCard(
                    index: 1,
                    title: AppStrings.welcomeRoleOwner,
                    description: AppStrings.welcomeRoleOwnerDesc,
                    icon: Icons.storefront_outlined,
                    isSelected: _selectedRoleIndex == 1,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 40),

                  // Continuation Actions
                  CustomButton(
                    text: 'Continue',
                    isGradient: true,
                    onPressed: _handleContinue,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/login');
                        },
                        child: Text(
                          'Login',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required int index,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _onRoleSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.06))
              : (isDark ? AppColors.cardDark : Colors.white.withValues(alpha: 0.95)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.grey[850]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon element
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.bgDark : Colors.grey[100]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : (isDark ? AppColors.primaryLight : AppColors.primary),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text element
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.white : AppColors.textMainLight),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
