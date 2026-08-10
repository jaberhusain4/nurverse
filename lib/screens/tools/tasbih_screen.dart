import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _counter = 0;
  int? _target = 33; // null মানে অননির্দিষ্ট (Unlimited)
  int _selectedDhikrIndex = 0;
  bool _vibrationEnabled = true;

  final List<Map<String, String>> _dhikrList = const [
    {
      'arabic': 'سُبْحَانَ ٱللَّٰهِ',
      'bangla': 'সুবহানাল্লাহ',
      'meaning': 'আল্লাহ তাআলা পবিত্র',
    },
    {
      'arabic': 'ٱلْحَمْدُ لِلَّٰهِ',
      'bangla': 'আলহামদুলিল্লাহ',
      'meaning': 'সমস্ত প্রশংসা আল্লাহর জন্য',
    },
    {
      'arabic': 'ٱللَّٰهُ أَكْبَرُ',
      'bangla': 'আল্লাহু আকবার',
      'meaning': 'আল্লাহ সবচেয়ে মহান',
    },
    {
      'arabic': 'أَسْتَغْفِرُ ٱللَّٰهَ',
      'bangla': 'আস্তাগফিরুল্লাহ',
      'meaning': 'আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি',
    },
    {
      'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      'bangla': 'লা ইলাহা ইল্লাল্লাহ',
      'meaning': 'আল্লাহ ছাড়া কোন উপাস্য নেই',
    },
  ];

  void _incrementCounter() async {
    final nextCount = _counter + 1;

    // টার্গেট পূরণের চেক
    if (_target != null && _target! > 0 && nextCount >= _target!) {
      if (_vibrationEnabled) {
        // টার্গেট পূরণে জোরালো ভাইব্রেশন
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.heavyImpact();
      }

      _showTargetReachedSnackBar(_target!);

      // টার্গেট পূর্ণ হলে অটো রিসেট
      setState(() {
        _counter = 0;
      });
    } else {
      setState(() {
        _counter = nextCount;
      });

      if (_vibrationEnabled) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _showTargetReachedSnackBar(int targetValue) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'আলহামদুলিল্লাহ! $targetValue বার পাঠ সম্পন্ন হওয়ায় রিসেট হয়েছে।',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.seaBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDhikr = _dhikrList[_selectedDhikrIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ডিজিটাল তাসবিহ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _vibrationEnabled ? Icons.vibration : Icons.smartphone_outlined,
              color:
                  _vibrationEnabled
                      ? AppColors.seaBlue
                      : context.secondaryTextColor,
            ),
            onPressed: () {
              setState(() {
                _vibrationEnabled = !_vibrationEnabled;
              });
            },
            tooltip: 'ভাইব্রেশন অন/অফ',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCounter,
            tooltip: 'কাউন্ট রিসেট',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ১. জিকির সিলেক্টর
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _dhikrList.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDhikrIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_dhikrList[index]['bangla']!),
                      selected: isSelected,
                      selectedColor: AppColors.seaBlue.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? AppColors.seaBlue
                                : context.primaryTextColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDhikrIndex = index;
                            _counter = 0;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            // ২. জিকির ডিসপ্লে
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    currentDhikr['arabic']!,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.seaBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentDhikr['bangla']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentDhikr['meaning']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ৩. মূল কাউন্টার বাটন
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.cardColor,
                  border: Border.all(color: AppColors.seaBlue, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.seaBlue.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_counter',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: AppColors.seaBlue,
                        ),
                      ),
                      Text(
                        _target == null
                            ? 'লক্ষ্য: অননির্দিষ্ট'
                            : 'লক্ষ্য: $_target',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ৪. টার্গেট সেট করার বাটনসমূহ (অননির্দিষ্ট, ৩৩, ১০০, ১০০০)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTargetButton(null, 'অননির্দিষ্ট'),
                    const SizedBox(width: 8),
                    _buildTargetButton(33, '৩৩ বার'),
                    const SizedBox(width: 8),
                    _buildTargetButton(100, '১০০ বার'),
                    const SizedBox(width: 8),
                    _buildTargetButton(1000, '১০০০ বার'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetButton(int? targetValue, String label) {
    final isSelected = _target == targetValue;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? AppColors.seaBlue : context.borderColor,
          width: isSelected ? 2 : 1,
        ),
        backgroundColor: isSelected ? AppColors.seaBlue.withValues(alpha: 0.1) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        setState(() {
          _target = targetValue;
          _counter = 0;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.seaBlue : context.primaryTextColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
