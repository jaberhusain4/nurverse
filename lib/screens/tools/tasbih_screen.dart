import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localizations.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});
  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const _vibrationChannel = MethodChannel('nurverse/vibration');
  int _counter = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;
  bool _vibrationEnabled = true;

  final List<Map<String, String>> _dhikrList = const [
    {'arabic': 'سُبْحَانَ ٱللَّٰهِ', 'bangla': 'সুবহানাল্লাহ', 'meaning': 'আল্লাহ তাআলা পবিত্র'},
    {'arabic': 'ٱلْحَمْدُ لِلَّٰهِ', 'bangla': 'আলহামদুলিল্লাহ', 'meaning': 'সমস্ত প্রশংসা আল্লাহর জন্য'},
    {'arabic': 'ٱللَّٰهُ أَكْبَرُ', 'bangla': 'আল্লাহু আকবার', 'meaning': 'আল্লাহ সবচেয়ে মহান'},
    {'arabic': 'أَسْتَغْفِرُ ٱللَّٰهَ', 'bangla': 'আস্তাগফিরুল্লাহ', 'meaning': 'আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি'},
    {'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ', 'bangla': 'লা ইলাহা ইল্লাল্লাহ', 'meaning': 'আল্লাহ ছাড়া কোন উপাস্য নেই'},
  ];

  Future<void> _vibrate({bool completion = false}) async {
    if (!_vibrationEnabled) return;

    // Use Flutter's haptic engine immediately so a native-channel failure
    // can never prevent the physical feedback on supported Android devices.
    if (completion) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    try {
      await _vibrationChannel.invokeMethod<void>(
        completion ? 'targetReached' : 'tap',
      );
    } on PlatformException {
      // Flutter haptic feedback above is already the fallback.
    } on MissingPluginException {
      // Native channel is unavailable during hot reload; haptic feedback above remains usable.
    }
  }

  void _incrementCounter() {
    final nextCount = _counter + 1;

    if (nextCount >= _target) {
      setState(() => _counter = _target);
      _vibrate(completion: true);
      if (!mounted) return;
      _showTargetReachedSnackBar(_target);
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _counter == _target) {
          setState(() => _counter = 0);
        }
      });
      return;
    }

    setState(() => _counter = nextCount);
    _vibrate();
  }

  void _resetCounter() => setState(() => _counter = 0);

  void _showTargetReachedSnackBar(int targetValue) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.tr(
        'আলহামদুলিল্লাহ! $targetValue বার পাঠ সম্পন্ন হয়েছে।',
        'Alhamdulillah! $targetValue repetitions completed.',
      )),
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.seaBlue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentDhikr = _dhikrList[_selectedDhikrIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tr('ডিজিটাল তাসবিহ', 'Digital Tasbih'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _vibrationEnabled ? Icons.vibration : Icons.smartphone_outlined,
              color: _vibrationEnabled
                  ? AppColors.seaBlue
                  : context.secondaryTextColor,
            ),
            onPressed: () => setState(() => _vibrationEnabled = !_vibrationEnabled),
            tooltip: l10n.tr('ভাইব্রেশন অন/অফ', 'Toggle vibration'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCounter,
            tooltip: l10n.tr('কাউন্ট রিসেট', 'Reset counter'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _dhikrList.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDhikrIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_dhikrList[index]['bangla']!),
                      selected: isSelected,
                      selectedColor: AppColors.seaBlue.withValues(alpha: .2),
                      labelStyle: TextStyle(
                        color: isSelected
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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

            // Counter is intentionally outside the tap circle.
            Column(
              children: [
                Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 52,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.seaBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.isBangla ? 'বার / $_target' : 'repetitions / $_target',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _incrementCounter,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.cardColor,
                      border: Border.all(color: AppColors.seaBlue, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.seaBlue.withValues(alpha: .15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 42,
                            color: AppColors.seaBlue,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            l10n.tr('ট্যাপ করুন', 'TAP'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.seaBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetCounter,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text(l10n.tr('রিসেট', 'Reset')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showTargetDialog(context, l10n),
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(l10n.tr('টার্গেট', 'Target')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showTargetDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    const options = <int>[33, 100, 500, 1000];
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                l10n.tr('টার্গেট নির্বাচন করুন', 'Select target'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            ...options.map((value) => ListTile(
              leading: Icon(
                value == _target
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: value == _target
                    ? AppColors.seaBlue
                    : context.secondaryTextColor,
              ),
              title: Text('$value'),
              trailing: value == _target
                  ? const Icon(Icons.check_rounded, color: AppColors.seaBlue)
                  : null,
              onTap: () => Navigator.pop(sheetContext, value),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;
    setState(() {
      _target = selected;
      _counter = 0;
    });
  }
}
