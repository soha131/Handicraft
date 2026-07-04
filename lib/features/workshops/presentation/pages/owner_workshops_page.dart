import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/workshop_cubit.dart';
import '../cubit/workshop_state.dart';
import '../../data/models/workshop_model.dart';

class OwnerWorkshopsPage extends StatefulWidget {
  const OwnerWorkshopsPage({super.key});

  @override
  State<OwnerWorkshopsPage> createState() => _OwnerWorkshopsPageState();
}

class _OwnerWorkshopsPageState extends State<OwnerWorkshopsPage> {
  @override
  void initState() {
    super.initState();
    // Start listening to this owner's workshops immediately
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<WorkshopCubit>().loadOwnerWorkshops(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workshops'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<WorkshopCubit, WorkshopState>(
        listener: (context, state) {
          if (state is WorkshopError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          if (state is WorkshopActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkshopLoading || state is WorkshopInitial) {
            return const LoadingWidget(message: 'Loading your workshops...');
          }

          if (state is WorkshopLoaded) {
            final workshops = state.workshops;

            if (workshops.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://www.transparenttextures.com/patterns/connected.png',
                      height: 120,
                      color: AppColors.primary.withValues(alpha: 0.3),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.workspaces_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No workshops yet.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Workshop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push(AppRouter.workshopForm),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                final w = workshops[index];
                return _WorkshopCard(workshop: w, isDark: isDark);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRouter.workshopForm),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final WorkshopModel workshop;
  final bool isDark;

  const _WorkshopCard({required this.workshop, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      color: isDark ? AppColors.cardDark : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(AppRouter.workshopForm, extra: workshop);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image header
            if (workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: workshop.imageUrl!,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, err) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: workshop.isOnline
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          workshop.isOnline ? 'ONLINE' : 'IN-PERSON',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: workshop.isOnline ? Colors.green : Colors.deepOrange,
                          ),
                        ),
                      ),
                      Text(
                        '\$${workshop.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workshop.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(workshop.startDateTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category_rounded, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        workshop.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 40,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
