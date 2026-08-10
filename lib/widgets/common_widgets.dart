export 'common/app_card.dart';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text.isEmpty ? 'শিরোনাম' : text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.primaryTextColor,
        ),
      ),
    );
  }
}

class NvCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const NvCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: context.isDark ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

class NvListTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final IconData? icon;
  final VoidCallback? onTap;

  NvListTile({
    super.key,
    dynamic title,
    dynamic subtitle,
    this.leading,
    this.trailing,
    this.icon,
    this.onTap,
  }) : title = title is String ? Text(title) : title as Widget?,
       subtitle = subtitle is String ? Text(subtitle) : subtitle as Widget?;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading:
          leading ??
          (icon != null ? Icon(icon, color: AppColors.primary) : null),
      trailing: trailing,
      onTap: onTap,
    );
  }
}


class AppBadge extends StatelessWidget {
  final String text;
  final Color color;

  const AppBadge({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
