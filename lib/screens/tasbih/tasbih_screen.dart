import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/tasbih_controller.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TasbihController>();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tasbih",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${controller.count}",
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "SubhanAllah",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            FilledButton(
              onPressed: controller.increment,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(45),
              ),
              child: const Icon(
                Icons.add,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            OutlinedButton(
              onPressed: controller.reset,
              child: const Text(
                "Reset",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
