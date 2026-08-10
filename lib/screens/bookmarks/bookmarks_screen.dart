import 'package:flutter/material.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bookmarks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.bookmark_outline,

              size: 80,

              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 20),

            const Text(
              "No bookmarks yet",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Saved Quran verses and duas will appear here.",

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
