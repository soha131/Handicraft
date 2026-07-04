import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../data/models/admin_models.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<AdminCubit>().loadStats();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 0: context.read<AdminCubit>().loadStats(); break;
      case 1: context.read<AdminCubit>().loadUsers(); break;
      case 2: context.read<AdminCubit>().loadWorkshops(); break;
      case 3: context.read<AdminCubit>().loadReviews(); break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded, size: 20), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people_rounded, size: 20), text: 'Users'),
            Tab(icon: Icon(Icons.work_outline_rounded, size: 20), text: 'Workshops'),
            Tab(icon: Icon(Icons.star_outline_rounded, size: 20), text: 'Reviews'),
          ],
        ),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            // Refresh current tab
            _onTabChanged();
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _DashboardTab(state: state, isDark: isDark),
              _UsersTab(state: state, isDark: isDark, searchController: _searchController),
              _WorkshopsTab(state: state, isDark: isDark),
              _ReviewsTab(state: state, isDark: isDark),
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD TAB
// ══════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  final AdminState state;
  final bool isDark;

  const _DashboardTab({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final Map<String, int> stats = state is AdminStatsLoaded
        ? (state as AdminStatsLoaded).stats
        : {'users': 0, 'workshops': 0, 'bookings': 0, 'reviews': 0};

    final kpis = [
      _KPI(label: 'Total Users', value: stats['users'] ?? 0,
          icon: Icons.people_rounded, color: const Color(0xFF6C63FF)),
      _KPI(label: 'Workshops', value: stats['workshops'] ?? 0,
          icon: Icons.work_rounded, color: AppColors.primary),
      _KPI(label: 'Bookings', value: stats['bookings'] ?? 0,
          icon: Icons.bookmark_rounded, color: AppColors.secondary),
      _KPI(label: 'Reviews', value: stats['reviews'] ?? 0,
          icon: Icons.star_rounded, color: Colors.amber),
    ];

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadStats(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Text('Platform Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  )),
          Text(
            DateFormat('EEEE, MMMM d yyyy').format(DateTime.now()),
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Inter',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          // KPI Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: kpis.map((k) => _buildKPICard(context, k, isDark)).toList(),
          ),
          const SizedBox(height: 28),
          // Quick Actions
          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  )),
          const SizedBox(height: 14),
          _buildQuickActions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildKPICard(BuildContext context, _KPI kpi, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: kpi.color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kpi.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(kpi.icon, color: kpi.color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${kpi.value}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: kpi.color,
                ),
              ),
              Text(
                kpi.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      _QuickAction(
          label: 'Manage Users',
          icon: Icons.manage_accounts_rounded,
          color: const Color(0xFF6C63FF),
          onTap: () {}),
      _QuickAction(
          label: 'Manage Workshops',
          icon: Icons.work_outline_rounded,
          color: AppColors.primary,
          onTap: () {}),
      _QuickAction(
          label: 'Moderate Reviews',
          icon: Icons.rate_review_rounded,
          color: Colors.amber[700]!,
          onTap: () {}),
    ];

    return Column(
      children: actions
          .map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.icon, color: a.color, size: 20),
                  ),
                  title: Text(
                    a.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  trailing:
                      Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  onTap: a.onTap,
                ),
              ))
          .toList(),
    );
  }
}

class _KPI {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _KPI({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap});
}

// ══════════════════════════════════════════════════════════════════════════════
// USERS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _UsersTab extends StatelessWidget {
  final AdminState state;
  final bool isDark;
  final TextEditingController searchController;

  const _UsersTab({
    required this.state,
    required this.isDark,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchController,
            onChanged: (v) => context.read<AdminCubit>().filterUsers(v),
            decoration: InputDecoration(
              hintText: 'Search by name, email, or role...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(child: _buildUserList(context)),
      ],
    );
  }

  Widget _buildUserList(BuildContext context) {
    if (state is AdminLoading || state is AdminInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    List<AdminUserRow> users = [];
    if (state is AdminUsersLoaded) {
      users = (state as AdminUsersLoaded).filtered;
    } else if (state is AdminActionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserCard(user: user, isDark: isDark);
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUserRow user;
  final bool isDark;

  const _UserCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final roleColor = user.role == 'workshop_owner'
        ? AppColors.primary
        : user.role == 'admin'
            ? const Color(0xFF6C63FF)
            : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withValues(alpha: 0.15),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey[400]),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context, user);
              } else {
                context.read<AdminCubit>().updateUserRole(user.uid, value);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'learner',
                child: Text('Set as Learner'),
              ),
              const PopupMenuItem(
                value: 'workshop_owner',
                child: Text('Set as Owner'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete User', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminUserRow user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().deleteUser(user.uid);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WORKSHOPS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _WorkshopsTab extends StatelessWidget {
  final AdminState state;
  final bool isDark;

  const _WorkshopsTab({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (state is AdminLoading || state is AdminInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AdminActionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<AdminWorkshopRow> workshops = [];
    if (state is AdminWorkshopsLoaded) {
      workshops = (state as AdminWorkshopsLoaded).workshops;
    }

    if (workshops.isEmpty) {
      return const Center(child: Text('No workshops found.'));
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadWorkshops(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workshops.length,
        itemBuilder: (context, index) {
          final w = workshops[index];
          return _WorkshopAdminCard(workshop: w, isDark: isDark);
        },
      ),
    );
  }
}

class _WorkshopAdminCard extends StatelessWidget {
  final AdminWorkshopRow workshop;
  final bool isDark;

  const _WorkshopAdminCard({required this.workshop, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final occupancy = workshop.capacity > 0
        ? (workshop.bookedSpots / workshop.capacity * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      workshop.category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, workshop),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip('\$${workshop.price.toStringAsFixed(0)}', Icons.monetization_on_outlined),
              const SizedBox(width: 8),
              _chip('${workshop.averageRating.toStringAsFixed(1)} ★', Icons.star_rounded),
              const SizedBox(width: 8),
              _chip('${workshop.totalReviews} reviews', Icons.comment_outlined),
            ],
          ),
          const SizedBox(height: 12),
          // Occupancy bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Occupancy',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'Inter')),
                  Text('${workshop.bookedSpots}/${workshop.capacity} ($occupancy%)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'Inter')),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: workshop.capacity > 0 ? workshop.bookedSpots / workshop.capacity : 0,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    occupancy >= 90 ? Colors.red : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: AppColors.primary, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminWorkshopRow workshop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Workshop'),
        content: Text(
            'Delete "${workshop.title}"? All associated bookings and reviews will also be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().deleteWorkshop(workshop.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REVIEWS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ReviewsTab extends StatelessWidget {
  final AdminState state;
  final bool isDark;

  const _ReviewsTab({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (state is AdminLoading || state is AdminInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AdminActionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<AdminReviewRow> reviews = [];
    if (state is AdminReviewsLoaded) {
      reviews = (state as AdminReviewsLoaded).reviews;
    }

    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews found.'));
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadReviews(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _ReviewAdminCard(review: review, isDark: isDark);
        },
      ),
    );
  }
}

class _ReviewAdminCard extends StatelessWidget {
  final AdminReviewRow review;
  final bool isDark;

  const _ReviewAdminCard({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0] : '?',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(review.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(Icons.star_rounded,
                        size: 14,
                        color: i < review.rating ? Colors.amber : Colors.grey[300])),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDelete(context, review),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Workshop ID: ${review.workshopId}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminReviewRow review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Review'),
        content: const Text(
            'Are you sure you want to remove this review? The workshop average rating will be recalculated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AdminCubit>()
                  .deleteReview(review.id, review.workshopId);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
