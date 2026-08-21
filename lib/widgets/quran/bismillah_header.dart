import 'package:flutter/material.dart';

class BismillahHeader extends StatelessWidget {
  const BismillahHeader({super.key});

  static const _bismillah = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider(color: primary.withValues(alpha: .24), thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: primary.withValues(alpha: .72),
                ),
              ),
              Expanded(child: Divider(color: primary.withValues(alpha: .24), thickness: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? .075 : .045),
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
                    height: 1.75,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, size: 10, color: primary.withValues(alpha: .65)),
                    const SizedBox(width: 7),
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1.3,
                        color: primary.withValues(alpha: .82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(Icons.star_rounded, size: 10, color: primary.withValues(alpha: .65)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 1,
                color: primary.withValues(alpha: .20),
              ),
              const SizedBox(width: 8),
              Icon(Icons.mosque_rounded, size: 13, color: primary.withValues(alpha: .58)),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 1,
                color: primary.withValues(alpha: .20),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
