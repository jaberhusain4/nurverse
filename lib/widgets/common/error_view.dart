import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;

  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 70,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(
                  height: 20,
                ),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text(
                    "Retry",
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
