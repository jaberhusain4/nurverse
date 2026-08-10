import 'package:flutter/material.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> duas = [
      {
        "title": "Morning Dua",
        "subtitle": "Start your day with Allah's remembrance",
      },
      {
        "title": "Evening Dua",
        "subtitle": "Protection before sunset",
      },
      {
        "title": "Before Sleep",
        "subtitle": "Dua before going to bed",
      },
      {
        "title": "After Prayer",
        "subtitle": "Tasbih & Dhikr",
      },
      {
        "title": "Before Eating",
        "subtitle": "Dua before meals",
      },
      {
        "title": "After Eating",
        "subtitle": "Thank Allah after meals",
      },
      {
        "title": "Travel Dua",
        "subtitle": "For safe journeys",
      },
      {
        "title": "Entering Mosque",
        "subtitle": "Dua before entering Masjid",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Dua"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: duas.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
              title: Text(
                duas[index]["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(duas[index]["subtitle"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}