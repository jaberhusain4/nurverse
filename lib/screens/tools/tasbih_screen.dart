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
  bool _blankMode = true;

  final List<Map<String, String>> _dhikrList = const [
    {'arabic': 'سُبْحَانَ ٱللَّٰهِ', 'bangla': 'সুবহানাল্লাহ', 'meaning': 'আল্লাহ তাআলা পবিত্র'},
    {'arabic': 'ٱلْحَمْدُ لِلَّٰهِ', 'bangla': 'আলহামদুলিল্লাহ', 'meaning': 'সমস্ত প্রশংসা আল্লাহর জন্য'},
    {'arabic': 'ٱللَّٰهُ أَكْبَرُ', 'bangla': 'আল্লাহু আকবার', 'meaning': 'আল্লাহ সবচেয়ে মহান'},
    {'arabic': 'أَسْتَغْفِرُ ٱللَّٰهَ', 'bangla': 'আস্তাগফিরুল্লাহ', 'meaning': 'আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি'},
    {'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ', 'bangla': 'লা ইলাহা ইল্লাল্লাহ', 'meaning': 'আল্লাহ ছাড়া কোন উপাস্য নেই'},
  ];

  Future<void> _vibrate({bool completion = false}) async {
    if (!_vibrationEnabled) return;
    if (completion) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.selectionClick();
    }
    try {
      await _vibrationChannel.invokeMethod<void>(completion ? 'targetReached' : 'tap');
    } catch (_) {
      // Platform vibration is optional; the counter must continue to work.
    }
  }

  Future<void> _incrementCounter() async {
    final nextCount = _counter + 1;
    if (nextCount >= _target) {
      setState(() => _counter = _target);
      await _vibrate(completion: true);
      if (!mounted) return;
      _showTargetReachedSnackBar(_target);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (mounted) setState(() => _counter = 0);
    } else {
      setState(() => _counter = nextCount);
      await _vibrate();
    }
  }

  void _resetCounter() => setState(() => _counter = 0);

  void _selectDhikr(int index) {
    setState(() {
      _selectedDhikrIndex = index;
      _blankMode = false;
      _counter = 0;
    });
  }

  void _selectBlankMode() {
    setState(() {
      _blankMode = true;
      _counter = 0;
    });
  }

  void _showTargetReachedSnackBar(int targetValue) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.tr('আলহামদুলিল্লাহ! $targetValue বার পাঠ সম্পন্ন হয়েছে। কাউন্ট রিসেট হয়েছে.', 'Alhamdulillah! $targetValue repetitions completed. Counter reset.')),
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.seaBlue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentDhikr = _dhikrList[_selectedDhikrIndex];
    final text = context.primaryTextColor;
    final secondary = context.secondaryTextColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('ডিজিটাল তাসবিহ', 'Digital Tasbih'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(_vibrationEnabled ? Icons.vibration : Icons.smartphone_outlined, color: _vibrationEnabled ? AppColors.seaBlue : secondary), onPressed: () => setState(() => _vibrationEnabled = !_vibrationEnabled), tooltip: l10n.tr('ভাইব্রেশন অন/অফ', 'Toggle vibration')),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetCounter, tooltip: l10n.tr('কাউন্ট রিসেট', 'Reset counter')),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (var index = 0; index < _dhikrList.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(_dhikrList[index]['bangla']!),
                      selected: !_blankMode && index == _selectedDhikrIndex,
                      selectedColor: AppColors.seaBlue.withValues(alpha: .2),
                      labelStyle: TextStyle(color: !_blankMode && index == _selectedDhikrIndex ? AppColors.seaBlue : text, fontWeight: !_blankMode && index == _selectedDhikrIndex ? FontWeight.bold : FontWeight.normal),
                      onSelected: (selected) { if (selected) _selectDhikr(index); },
                    ),
                  ],
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.edit_note_rounded, size: 18),
                    label: Text(l10n.tr('নন-তাসবিহ', 'Non-Tasbih')),
                    selected: _blankMode,
                    selectedColor: AppColors.seaBlue.withValues(alpha: .2),
                    labelStyle: TextStyle(color: _blankMode ? AppColors.seaBlue : text, fontWeight: _blankMode ? FontWeight.bold : FontWeight.normal),
                    onSelected: (selected) { if (selected) _selectBlankMode(); },
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _blankMode
                  ? Column(children: [
                      Icon(Icons.touch_app_rounded, size: 42, color: AppColors.seaBlue),
                      const SizedBox(height: 8),
                      Text(l10n.tr('খালি কাউন্টার', 'Blank Counter'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
                      const SizedBox(height: 5),
                      Text(l10n.tr('যেকোনো দোয়া, যিকির বা আমল পড়তে এই কাউন্টার ব্যবহার করুন।', 'Use this counter for any dua, dhikr, or other recitation.'), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: secondary)),
                    ])
                  : Column(children: [
                      Text(currentDhikr['arabic']!, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.seaBlue), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(currentDhikr['bangla']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text), textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(currentDhikr['meaning']!, style: TextStyle(fontSize: 13, color: secondary), textAlign: TextAlign.center),
                    ]),
            ),
            const Spacer(flex: 2),
            Column(children: [
              Text('$_counter', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w800, color: AppColors.seaBlue)),
              Text('${l10n.tr('বার', 'repetitions')} / $_target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary)),
            ]),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(shape: BoxShape.circle, color: context.cardColor, border: Border.all(color: AppColors.seaBlue, width: 4), boxShadow: [BoxShadow(color: AppColors.seaBlue.withValues(alpha: .15), blurRadius: 20, spreadRadius: 5)]),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.touch_app_rounded, size: 38, color: AppColors.seaBlue.withValues(alpha: .78)),
                  const SizedBox(height: 7),
                  Text(l10n.tr('ট্যাপ করুন', 'Tap'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: text)),
                ])),
              ),
            ),
            const Spacer(flex: 2),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _resetCounter, icon: const Icon(Icons.restart_alt_rounded), label: Text(l10n.tr('রিসেট', 'Reset')))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: () => _showTargetDialog(context, l10n), icon: const Icon(Icons.flag_outlined), label: Text(l10n.tr('টার্গেট', 'Target')))),
            ])),
            const SizedBox(height: 12),
            Text(l10n.isBangla ? 'টার্গেট: $_target' : 'Target: $_target', style: TextStyle(fontSize: 12, color: secondary)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showTargetDialog(BuildContext context, AppLocalizations l10n) async {
    const options = <int>[33, 100, 500, 1000];
    final selected = await showModalBottomSheet<int>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 8), child: Text(l10n.tr('টার্গেট নির্বাচন করুন', 'Select target'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
      ...options.map((value) => ListTile(leading: Icon(value == _target ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: value == _target ? AppColors.seaBlue : context.secondaryTextColor), title: Text('$value'), trailing: value == _target ? const Icon(Icons.check_rounded, color: AppColors.seaBlue) : null, onTap: () => Navigator.pop(sheetContext, value))),
      const SizedBox(height: 8),
    ])));
    if (!mounted || selected == null) return;
    setState(() { _target = selected; _counter = 0; });
  }
}
