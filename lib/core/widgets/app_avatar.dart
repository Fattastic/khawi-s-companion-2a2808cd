import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

/// A polished avatar widget with smart fallback to initials.
///
/// Features:
/// - Automatic initials generation from name
/// - Consistent sizing across the app
/// - Optional online/offline status indicator
/// - Premium badge support
/// - Smooth image loading with fade transition
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final bool isOnline;
  final bool showOnlineIndicator;
  final bool isPremium;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.showBorder = false,
    this.borderColor,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.isPremium = false,
    this.onTap,
  });

  /// Small avatar (32px) - for compact lists
  const AppAvatar.small({
    super.key,
    this.imageUrl,
    this.name,
    this.showBorder = false,
    this.borderColor,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.isPremium = false,
    this.onTap,
  }) : size = 32;

  /// Medium avatar (48px) - default size
  const AppAvatar.medium({
    super.key,
    this.imageUrl,
    this.name,
    this.showBorder = false,
    this.borderColor,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.isPremium = false,
    this.onTap,
  }) : size = 48;

  /// Large avatar (64px) - for profile headers
  const AppAvatar.large({
    super.key,
    this.imageUrl,
    this.name,
    this.showBorder = true,
    this.borderColor,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.isPremium = false,
    this.onTap,
  }) : size = 64;

  /// Extra large avatar (96px) - for profile pages
  const AppAvatar.xlarge({
    super.key,
    this.imageUrl,
    this.name,
    this.showBorder = true,
    this.borderColor,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.isPremium = false,
    this.onTap,
  }) : size = 96;

  String _getInitials() {
    if (name == null || name!.trim().isEmpty) return '?';

    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getBackgroundColor() {
    if (name == null || name!.isEmpty) return AppTheme.borderColor;

    // Generate consistent color from name
    final hash = name.hashCode;
    final colors = [
      AppTheme.primaryGreen,
      AppTheme.driverAccent,
      AppTheme.juniorAccent,
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        // Main avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(
                    color: borderColor ?? Colors.white,
                    width: size > 60 ? 3 : 2,
                  )
                : null,
            boxShadow: showBorder
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildFallback(),
                    placeholder: (_, __) => _buildFallback(isLoading: true),
                    fadeInDuration: const Duration(milliseconds: 200),
                  )
                : _buildFallback(),
          ),
        ),

        // Online indicator
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.success : AppTheme.textTertiary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),

        // Premium badge
        if (isPremium)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.star_rounded,
                size: size * 0.22,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildFallback({bool isLoading = false}) {
    final bgColor = _getBackgroundColor();
    final initials = _getInitials();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            isLoading ? AppTheme.borderLight : bgColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation(bgColor.withValues(alpha: 0.5)),
                ),
              ),
            )
          : Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: bgColor,
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
    );
  }
}

/// A row of overlapping avatars for group displays.
class AppAvatarStack extends StatelessWidget {
  final List<AvatarData> avatars;
  final double avatarSize;
  final double overlap;
  final int maxVisible;
  final VoidCallback? onTap;

  const AppAvatarStack({
    super.key,
    required this.avatars,
    this.avatarSize = 32,
    this.overlap = 8,
    this.maxVisible = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAvatars = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: avatarSize,
        width: avatarSize +
            (visibleAvatars.length - 1) * (avatarSize - overlap) +
            (remaining > 0 ? avatarSize - overlap : 0),
        child: Stack(
          children: [
            for (var i = 0; i < visibleAvatars.length; i++)
              Positioned(
                left: i * (avatarSize - overlap),
                child: AppAvatar(
                  imageUrl: visibleAvatars[i].imageUrl,
                  name: visibleAvatars[i].name,
                  size: avatarSize,
                  showBorder: true,
                ),
              ),
            if (remaining > 0)
              Positioned(
                left: visibleAvatars.length * (avatarSize - overlap),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: avatarSize * 0.32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Data class for avatar information
class AvatarData {
  final String? imageUrl;
  final String? name;

  const AvatarData({this.imageUrl, this.name});
}
