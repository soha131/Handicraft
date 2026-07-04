import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Displays a user avatar with three sources in priority order:
///   1. [localFile]   — newly picked image (File) not yet uploaded
///   2. [networkUrl]  — existing photo URL from Firebase Storage
///   3. Initials      — generated from [name] as a graceful fallback
class ProfileAvatarWidget extends StatelessWidget {
  final double radius;
  final String? networkUrl;
  final File? localFile;
  final String name;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const ProfileAvatarWidget({
    super.key,
    required this.name,
    this.radius = 56,
    this.networkUrl,
    this.localFile,
    this.onTap,
    this.showEditBadge = false,
  });

  /// Extract the first initial from the full name.
  String _initials() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: _buildContent(),
          ),
          if (showEditBadge) _buildEditBadge(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Only display generated first initial as per user preference
    return _initialsWidget();
  }

  Widget _initialsWidget() {
    return Text(
      _initials(),
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: radius * 0.55,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEditBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.camera_alt_rounded,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}
