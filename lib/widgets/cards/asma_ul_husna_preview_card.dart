import 'package:flutter/material.dart';

import '../../models/asma_ul_husna.dart';

/// "Name of the Day" preview shown on the Home dashboard, with a tap
/// target that opens the full 99 Names list.
class AsmaUlHusnaPreviewCard extends StatelessWidget {
  const AsmaUlHusnaPreviewCard({
    required this.name,
    required this.onTap,
    super.key,
  });

  final AsmaUlHusna name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: Text('${name.number}'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.transliteration,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name.meaning,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                name.arabic,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
