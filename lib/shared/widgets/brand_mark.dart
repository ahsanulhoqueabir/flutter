import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Placeholder logo. Replace the icon with your brand asset; it is used on the
/// splash, auth and about screens.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: size / 3,
            offset: Offset(0, size / 8),
          ),
        ],
      ),
      child: Icon(Icons.auto_awesome_rounded, color: colors.onPrimary, size: size * 0.5),
    );
  }
}
