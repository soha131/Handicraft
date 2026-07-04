import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../workshops/presentation/cubit/workshop_cubit.dart';
import '../../../workshops/presentation/cubit/workshop_state.dart';
import '../../../workshops/data/models/workshop_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Pre-load workshops so the Featured strip is ready on home
    context.read<WorkshopCubit>().loadAllWorkshops();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Send back to welcome screen upon logout
          context.go('/welcome');
        }
      },
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: LoadingWidget(message: 'Checking auth session ...'),
          );
        }

        final user = state.user;
        final bool isOwner = user.role == 'workshop_owner';
        final String roleLabel = isOwner ? 'Workshop Owner' : 'Learner';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Handicraft Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                tooltip: 'My Profile',
                onPressed: () {
                  // Initialize the global ProfileCubit from the already-loaded user
                  context.read<ProfileCubit>().initFromUser(user);
                  context.push(AppRouter.profile);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_outlined),
                tooltip: 'Logout',
                onPressed: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOwner
                            ? [AppColors.primary, AppColors.primaryLight]
                            : [AppColors.secondary, AppColors.secondaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isOwner
                                      ? AppColors.primary
                                      : AppColors.secondary)
                                  .withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                roleLabel.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome, ${user.name}!',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enjoy building crafts with advanced AI inspection feedback.',
                          style: _interStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Dashboard Content Section
                  Text(
                    'Workspace Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDashboardGrid(context, isOwner, isDark),

                  if (!isOwner) ...[
                    const SizedBox(height: 36),
                    _buildFeaturedWorkshopsSection(context, theme, isDark),
                  ],

                  const SizedBox(height: 36),

                  // Display role-specific summary
                  _buildRoleFeatureSummary(theme, isOwner, isDark),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Sign Out',
                    isOutline: true,
                    isSecondary: !isOwner,
                    onPressed: () {
                      _showLogoutConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Inter typography inline style helper
  TextStyle _interStyle({required Color color, required double fontSize}) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  Widget _buildDashboardGrid(BuildContext context, bool isOwner, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        _buildGridCard(
          title: isOwner ? 'My Workshops' : 'Browse Workshops',
          subtitle: isOwner ? 'Manage your listings' : 'Find Pottery & Weaving',
          icon: isOwner ? Icons.storefront_rounded : Icons.search_rounded,
          iconColor: isOwner ? AppColors.primary : AppColors.secondary,
          isDark: isDark,
          onTap: () {
            if (isOwner) {
              context.push(AppRouter.ownerWorkshops);
            } else {
              context.push(AppRouter.browseWorkshops);
            }
          },
        ),
        _buildGridCard(
          title: 'AI Scan feedback',
          subtitle: 'Check clay & candle shape',
          icon: Icons.camera_alt_outlined,
          iconColor: AppColors.accent,
          isDark: isDark,
        ),
        _buildGridCard(
          title: isOwner ? 'Student Bookings' : 'My Enrolments',
          subtitle: isOwner ? 'Monitor registers' : 'Check project dates',
          icon: isOwner
              ? Icons.people_outline_rounded
              : Icons.bookmark_border_rounded,
          iconColor: isOwner ? AppColors.primary : AppColors.secondary,
          isDark: isDark,
          onTap: () {
            if (!isOwner) {
              context.push(AppRouter.myBookings);
            } else {
              // TODO: Owner bookings page
            }
          }
        ),
        _buildGridCard(
          title: 'Direct Chats',
          subtitle: 'Realtime chat messenger',
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: Colors.blueAccent,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey[150]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textMainLight,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSubDark
                        : AppColors.textSubLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedWorkshopsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Workshops',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRouter.browseWorkshops),
              child: Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<WorkshopCubit, WorkshopState>(
          builder: (context, state) {
            if (state is WorkshopLoading || state is WorkshopInitial) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is WorkshopLoaded && state.workshops.isNotEmpty) {
              final featured = state.workshops.take(6).toList();
              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  itemBuilder: (context, index) {
                    return _FeaturedWorkshopCard(
                      workshop: featured[index],
                      isDark: isDark,
                    );
                  },
                ),
              );
            }
            // Empty or error → subtle prompt
            return Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.interests_rounded,
                        color: AppColors.primary.withValues(alpha: 0.4),
                        size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'No workshops yet — check back soon!',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoleFeatureSummary(ThemeData theme, bool isOwner, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOwner ? Icons.info_outline_rounded : Icons.offline_bolt_outlined,
            color: isOwner ? AppColors.primary : AppColors.secondary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwner ? 'Hosting Workshops' : 'Skill Level Progress',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOwner
                      ? 'You can register in-person workshops located in Riyadh and online courses. AI feedback assists your students during pottery practices.'
                      : 'Enroll in candle making or weaving tutorials. Upload photos of your finished projects to activate computer vision evaluation feedback.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to end your active workspace session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismissdialog
              context.read<AuthCubit>().logout(); // execute logout session
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact horizontal card used in the Featured Workshops strip on the Home Screen.
class _FeaturedWorkshopCard extends StatelessWidget {
  final WorkshopModel workshop;
  final bool isDark;

  const _FeaturedWorkshopCard({required this.workshop, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

    return GestureDetector(
      onTap: () => context.push(AppRouter.workshopDetails, extra: workshop),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: workshop.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, err) => _placeholder(),
                    )
                  else
                    _placeholder(),
                  // Price badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${workshop.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      workshop.category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workshop.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 10,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(workshop.startDateTime),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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

  Widget _placeholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.interests_rounded,
          color: AppColors.primary.withValues(alpha: 0.3),
          size: 32,
        ),
      ),
    );
  }
}
