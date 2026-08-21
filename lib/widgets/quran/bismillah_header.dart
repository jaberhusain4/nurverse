import 'package:flutter/material.dart';

class BismillahHeader extends StatelessWidget {
  const BismillahHeader({super.key});

  static const _bismillah = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Divider(
                  color: primary.withValues(alpha: .20),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: primary.withValues(alpha: .68),
                ),
              ),
              Expanded(
                child: Divider(
                  color: primary.withValues(alpha: .20),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? .065 : .035),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  _bismillah,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.78,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 9,
                      color: primary.withValues(alpha: .55),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      width: 28,
                      height: 1,
                      color: primary.withValues(alpha: .20),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      Icons.mosque_rounded,
                      size: 13,
                      color: primary.withValues(alpha: .60),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      width: 28,
                      height: 1,
                      color: primary.withValues(alpha: .20),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      Icons.star_rounded,
                      size: 9,
                      color: primary.withValues(alpha: .55),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
