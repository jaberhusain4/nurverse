import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/jamaat_service.dart';
import '../../theme/app_theme.dart';

class JamaatSettingsScreen extends StatefulWidget {
  const JamaatSettingsScreen({super.key});

  static const List<String> prayers = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const Map<String, String> bnNames = <String, String>{
    'Fajr': 'ফজর',
    'Dhuhr': 'যোহর / জুমু\'আ',
    'Asr': 'আসর',
    'Maghrib': 'মাগরিব',
    'Isha': 'ইশা',
  };

  @override
  State<JamaatSettingsScreen> createState() => _JamaatSettingsScreenState();
}

class _JamaatSettingsScreenState extends State<JamaatSettingsScreen> {
  @override
  void initState() {
    super.initState();
    JamaatService.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  TimeOfDay? _parseTime(String value) {
    final text = value.trim();
    if (text.isEmpty || text == '--:--') return null;
    final amPm = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(text);
    if (amPm != null) {
      var hour = int.tryParse(amPm.group(1)!) ?? -1;
      final minute = int.tryParse(amPm.group(2)!) ?? -1;
      final period = amPm.group(3)!.toUpperCase();
      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (twentyFour != null) {
      final hour = int.tryParse(twentyFour.group(1)!) ?? -1;
      final minute = int.tryParse(twentyFour.group(2)!) ?? -1;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  String _formatTime(TimeOfDay time, bool is24Hour) {
    final minute = time.minute.toString().padLeft(2, '0');
    if (is24Hour) return '${time.hour.toString().padLeft(2, '0')}:$minute';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return '$hour:$minute ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  String _displayTime(String value, bool is24Hour) {
    final parsed = _parseTime(value);
    return parsed == null ? '--:--' : _formatTime(parsed, is24Hour);
  }

  Future<void> _useDefault(String prayer) async {
    await JamaatService.useDefault(prayer);
    if (mounted) setState(() {});
  }

  Future<void> _openPicker(BuildContext context, String prayer) async {
    final settings = context.read<SettingsProvider>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _JamaatTimePickerScreen(
          prayer: prayer,
          prayerName: JamaatSettingsScreen.bnNames[prayer] ?? prayer,
          initialTime: _parseTime(JamaatService.get(prayer)),
          is24Hour: settings.is24Hour,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final isEnglish = settings.isEnglish;

    return Scaffold(
      appBar: AppBar(title: Text(isEnglish ? 'Jamaat Times' : 'জামাআত সেটিংস')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.groups_rounded, color: primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEnglish
                        ? 'Choose Default for the changing Dhaka reference time, or Set to enter your local mosque time.'
                        : 'সময় অনুযায়ী পরিবর্তনশীল ঢাকার রেফারেন্স সময় ব্যবহার করতে ডিফল্ট নির্বাচন করুন। আপনার এলাকার মসজিদের সময় দিতে সেট নির্বাচন করুন।',
                    style: TextStyle(color: secondary, fontSize: 12.5, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...JamaatSettingsScreen.prayers.map(
            (prayer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _JamaatTimeCard(
                name: JamaatSettingsScreen.bnNames[prayer] ?? prayer,
                time: _displayTime(JamaatService.get(prayer), settings.is24Hour),
                isEnglish: isEnglish,
                isDefault: JamaatService.isDhakaDefault(prayer),
                onDefault: () => _useDefault(prayer),
                onSet: () => _openPicker(context, prayer),
                primary: primary,
                text: text,
                secondary: secondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEnglish
                ? 'Default = the Dhaka reference time that changes with the date. Set = your local mosque time saved on this device.'
                : 'ডিফল্ট = তারিখ ও সালাতের সময়ের সঙ্গে পরিবর্তনশীল ঢাকার রেফারেন্স সময়। সেট = আপনার এলাকার মসজিদের সময়, যা এই ডিভাইসে সংরক্ষিত থাকবে।',
            style: TextStyle(color: secondary, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _JamaatTimeCard extends StatelessWidget {
  const _JamaatTimeCard({
    required this.name,
    required this.time,
    required this.isEnglish,
    required this.isDefault,
    required this.onDefault,
    required this.onSet,
    required this.primary,
    required this.text,
    required this.secondary,
  });

  final String name;
  final String time;
  final bool isEnglish;
  final bool isDefault;
  final VoidCallback onDefault;
  final VoidCallback onSet;
  final Color primary;
  final Color text;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.schedule_rounded, color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(name, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                        isDefault
                            ? (isEnglish ? 'Dhaka default time' : 'ঢাকার ডিফল্ট সময়')
                            : (isEnglish ? 'Local mosque time' : 'আপনার এলাকার মসজিদের সময়'),
                        style: TextStyle(color: secondary, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(time, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: isDefault
                      ? FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_rounded, size: 17),
                          label: Text(isEnglish ? 'Default' : 'ডিফল্ট'),
                        )
                      : OutlinedButton.icon(
                          onPressed: onDefault,
                          icon: const Icon(Icons.public_rounded, size: 17),
                          label: Text(isEnglish ? 'Default' : 'ডিফল্ট'),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSet,
                    icon: const Icon(Icons.edit_rounded, size: 17),
                    label: Text(isEnglish ? 'Set' : 'সেট'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JamaatTimePickerScreen extends StatefulWidget {
  const _JamaatTimePickerScreen({
    required this.prayer,
    required this.prayerName,
    required this.initialTime,
    required this.is24Hour,
  });

  final String prayer;
  final String prayerName;
  final TimeOfDay? initialTime;
  final bool is24Hour;

  @override
  State<_JamaatTimePickerScreen> createState() => _JamaatTimePickerScreenState();
}

class _JamaatTimePickerScreenState extends State<_JamaatTimePickerScreen> {
  late int _hour;
  late int _minute;
  late bool _isPm;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTime ?? TimeOfDay.now();
    _hour = widget.is24Hour ? initial.hour : (initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod);
    _minute = initial.minute;
    _isPm = initial.period == DayPeriod.pm;
  }

  Future<void> _save() async {
    final settings = context.read<SettingsProvider>();
    final hour24 = widget.is24Hour
        ? _hour
        : (_isPm ? (_hour == 12 ? 12 : _hour + 12) : (_hour == 12 ? 0 : _hour));
    final value = widget.is24Hour
        ? '${hour24.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}'
        : '$_hour:${_minute.toString().padLeft(2, '0')} ${_isPm ? 'PM' : 'AM'}';
    await settings.setJamaatTime(widget.prayer, value);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final isEnglish = settings.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prayerName),
        actions: <Widget>[
          TextButton(onPressed: _save, child: Text(isEnglish ? 'Save' : 'সংরক্ষণ')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isEnglish
                  ? 'Set the actual Jamaat time of your local mosque.'
                  : 'আপনার এলাকার মসজিদের প্রকৃত জামাআতের সময় সেট করুন।',
              style: TextStyle(color: secondary, fontSize: 12.5, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.is24Hour)
            _NumberGrid(
              title: isEnglish ? 'Hour' : 'ঘণ্টা',
              values: List<int>.generate(24, (index) => index),
              selected: _hour,
              format: (value) => value.toString().padLeft(2, '0'),
              onSelected: (value) => setState(() => _hour = value),
              primary: primary,
            )
          else ...<Widget>[
            _NumberGrid(
              title: isEnglish ? 'Hour' : 'ঘণ্টা',
              values: List<int>.generate(12, (index) => index + 1),
              selected: _hour,
              format: (value) => value.toString(),
              onSelected: (value) => setState(() => _hour = value),
              primary: primary,
            ),
            const SizedBox(height: 20),
            _PeriodSelector(
              isPm: _isPm,
              isEnglish: isEnglish,
              primary: primary,
              onChanged: (value) => setState(() => _isPm = value),
            ),
          ],
          const SizedBox(height: 20),
          _NumberGrid(
            title: isEnglish ? 'Minute' : 'মিনিট',
            values: List<int>.generate(60, (index) => index),
            selected: _minute,
            format: (value) => value.toString().padLeft(2, '0'),
            onSelected: (value) => setState(() => _minute = value),
            primary: primary,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(isEnglish ? 'Save Jamaat Time' : 'জামাআতের সময় সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }
}

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({
    required this.title,
    required this.values,
    required this.selected,
    required this.format,
    required this.onSelected,
    required this.primary,
  });

  final String title;
  final List<int> values;
  final int selected;
  final String Function(int) format;
  final ValueChanged<int> onSelected;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final value = values[index];
            final isSelected = value == selected;
            return Material(
              color: isSelected ? primary : context.cardColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onSelected(value),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    format(value),
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.isPm,
    required this.isEnglish,
    required this.primary,
    required this.onChanged,
  });

  final bool isPm;
  final bool isEnglish;
  final Color primary;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isEnglish ? 'Period' : 'সময়কাল',
          style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _periodButton(
                context,
                label: 'AM',
                selected: !isPm,
                onTap: () => onChanged(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _periodButton(
                context,
                label: 'PM',
                selected: isPm,
                onTap: () => onChanged(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _periodButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final text = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Material(
      color: selected ? primary : context.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Theme.of(context).colorScheme.onPrimary : text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
