import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_avatar_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _initialised = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Pre-fill fields from current profile on first build.
  void _initFields(ProfileState state) {
    if (_initialised) return;
    final user = switch (state) {
      ProfileLoaded(:final user) => user,
      ProfileUpdating(:final user) => user,
      ProfileUpdateSuccess(:final user) => user,
      _ => null,
    };
    if (user != null) {
      _nameController.text = user.name;
      _initialised = true;
    }
  }


  void _save(ProfileState state) {
    if (!_formKey.currentState!.validate()) return;

    final user = switch (state) {
      ProfileLoaded(:final user) => user,
      ProfileUpdateSuccess(:final user) => user,
      _ => null,
    };
    if (user == null) return;

    final cubit = context.read<ProfileCubit>();

    // Update name / bio
    cubit.updateProfile(
      uid: user.uid,
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        _initFields(state);

        final user = switch (state) {
          ProfileLoaded(:final user) => user,
          ProfileUpdating(:final user) => user,
          ProfileUpdateSuccess(:final user) => user,
          _ => null,
        };

        final isUpdating = state is ProfileUpdating;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar
                        Center(
                          child: ProfileAvatarWidget(
                            name: user?.name ?? '',
                            radius: 64,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Name field
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Name cannot be empty';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Email (read-only)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email (cannot be changed)',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                                      ),
                                    ),
                                    Text(
                                      user?.email ?? '',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        CustomButton(
                          text: 'Save Changes',
                          isGradient: true,
                          onPressed: isUpdating ? null : () => _save(state),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isUpdating)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const LoadingWidget(message: 'Saving profile...'),
                ),
            ],
          ),
        );
      },
    );
  }
}
