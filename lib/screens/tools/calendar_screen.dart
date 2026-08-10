import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

enum CalendarType { gregorian, hijri, bangla }

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarType _selectedType = CalendarType.gregorian;
  DateTime _selectedDate = DateTime.now();

  static const List<String> _banglaMonths = [
    'বৈশাখ',
    'জ্যৈষ্ঠ',
    'আষাঢ়',
    'শ্রাবণ',
    'ভাদ্র',
    'আশ্বিন',
    'কার্তিক',
    'অগ্রহায়ণ',
    'পৌষ',
    'মাঘ',
    'ফাল্গুন',
    'চৈত্র',
  ];

  static const List<String> _banglaWeekdays = [
    'রবিবার',
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
  ];

  static const List<String> _englishMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _englishWeekdays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const List<String> _arabicHijriMonths = [
    'মুহাররম',
    'সফর',
    'রবিউল আউয়াল',
    'রবিউস সানি',
    'জমাদিউল আউয়াল',
    'জমাদিউস সানি',
    'রজব',
    'শাবান',
    'রমজান',
    'শাওয়াল',
    'জিলকদ',
    'জিলহজ',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ক্যালেন্ডার',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarSelector(context),
            const SizedBox(height: 18),
            _buildDateCard(context),
            const SizedBox(height: 18),
            _buildMonthCalendar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSelector(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CalendarTypeButton(
              label: 'খ্রিস্টাব্দ',
              subtitle: 'English',
              selected: _selectedType == CalendarType.gregorian,
              onTap: () {
                setState(() {
                  _selectedType = CalendarType.gregorian;
                });
              },
            ),
          ),
          Expanded(
            child: _CalendarTypeButton(
              label: 'হিজরি',
              subtitle: 'Hijri',
              selected: _selectedType == CalendarType.hijri,
              onTap: () {
                setState(() {
                  _selectedType = CalendarType.hijri;
                });
              },
            ),
          ),
          Expanded(
            child: _CalendarTypeButton(
              label: 'বাংলাব্দ',
              subtitle: 'Bangla',
              selected: _selectedType == CalendarType.bangla,
              onTap: () {
                setState(() {
                  _selectedType = CalendarType.bangla;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final dateInfo = _getSelectedDateInfo();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.calendar_month_rounded, color: primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            dateInfo.primary,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            dateInfo.weekday,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .62),
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: theme.dividerColor.withValues(alpha: .5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DateMiniInfo(
                title: 'খ্রিস্টাব্দ',
                value: _getGregorianShortDate(_selectedDate),
              ),
              _DateMiniInfo(
                title: 'হিজরি',
                value: _getHijriShortDate(_selectedDate),
              ),
              _DateMiniInfo(
                title: 'বাংলাব্দ',
                value: _getBanglaShortDate(_selectedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final monthInfo = _getMonthInfo();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  monthInfo.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildWeekdayHeader(context),
          const SizedBox(height: 6),
          _buildCalendarGrid(context),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    final theme = Theme.of(context);

    final weekdays =
        _selectedType == CalendarType.bangla
            ? _banglaWeekdays
            : _selectedType == CalendarType.hijri
            ? const ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি']
            : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: [
        for (final day in weekdays)
          Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: .55,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final days = _getCalendarDays();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 5,
        crossAxisSpacing: 3,
        childAspectRatio: .92,
      ),
      itemBuilder: (context, index) {
        final day = days[index];

        if (day == null) {
          return const SizedBox.shrink();
        }

        final selected = _isSelectedCalendarDay(day);
        final today = _isTodayCalendarDay(day);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color:
                    selected
                        ? primary
                        : today
                        ? primary.withValues(alpha: .10)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _calendarDayNumber(day),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected || today ? FontWeight.w800 : FontWeight.w500,
                    color:
                        selected
                            ? theme.colorScheme.onPrimary
                            : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DateTime?> _getCalendarDays() {
    switch (_selectedType) {
      case CalendarType.gregorian:
        return _getGregorianCalendarDays();

      case CalendarType.hijri:
        return _getHijriCalendarDays();

      case CalendarType.bangla:
        return _getBanglaCalendarDays();
    }
  }

  List<DateTime?> _getGregorianCalendarDays() {
    final year = _selectedDate.year;
    final month = _selectedDate.month;

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final leading = firstDay.weekday % 7;

    return [
      ...List<DateTime?>.filled(leading, null),
      for (int day = 1; day <= daysInMonth; day++) DateTime(year, month, day),
    ];
  }

  List<DateTime?> _getHijriCalendarDays() {
    final hijri = HijriCalendar.fromDate(_selectedDate);

    final hijriYear = hijri.hYear;
    final hijriMonth = hijri.hMonth;

    final daysInMonth = _getHijriMonthDays(hijriYear, hijriMonth);

    final firstHijri =
        HijriCalendar()
          ..hYear = hijriYear
          ..hMonth = hijriMonth
          ..hDay = 1;

    final firstGregorian = firstHijri.hijriToGregorian(
      hijriYear,
      hijriMonth,
      1,
    );

    final leading = firstGregorian.weekday % 7;

    return [
      ...List<DateTime?>.filled(leading, null),
      for (int day = 1; day <= daysInMonth; day++)
        _hijriDayToGregorian(hijriYear, hijriMonth, day),
    ];
  }

  List<DateTime?> _getBanglaCalendarDays() {
    final info = _banglaDateInfo(_selectedDate);

    final monthIndex = info.monthIndex;
    final banglaYear = info.year;

    final start = _banglaMonthStart(banglaYear, monthIndex);

    final nextStart = _banglaMonthStart(
      monthIndex == 11 ? banglaYear + 1 : banglaYear,
      (monthIndex + 1) % 12,
    );

    final daysInMonth = nextStart.difference(start).inDays;

    final leading = start.weekday % 7;

    return [
      ...List<DateTime?>.filled(leading, null),
      for (int day = 0; day < daysInMonth; day++)
        start.add(Duration(days: day)),
    ];
  }

  int _getHijriMonthDays(int year, int month) {
    final first = _hijriDayToGregorian(year, month, 1);

    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;

    final next = _hijriDayToGregorian(nextYear, nextMonth, 1);

    return next.difference(first).inDays;
  }

  DateTime _hijriDayToGregorian(int year, int month, int day) {
    final hijri =
        HijriCalendar()
          ..hYear = year
          ..hMonth = month
          ..hDay = day;

    return hijri.hijriToGregorian(year, month, day);
  }

  String _calendarDayNumber(DateTime date) {
    switch (_selectedType) {
      case CalendarType.gregorian:
        return date.day.toString();

      case CalendarType.hijri:
        final hijri = HijriCalendar.fromDate(date);
        return _bnNumber(hijri.hDay);

      case CalendarType.bangla:
        final info = _banglaDateInfo(date);
        return _bnNumber(info.day);
    }
  }

  bool _isSelectedCalendarDay(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool _isTodayCalendarDay(DateTime date) {
    final today = DateTime.now();

    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  void _previousMonth() {
    switch (_selectedType) {
      case CalendarType.gregorian:
        setState(() {
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month - 1,
            1,
          );
        });
        break;

      case CalendarType.hijri:
        final current = HijriCalendar.fromDate(_selectedDate);

        final month = current.hMonth == 1 ? 12 : current.hMonth - 1;
        final year = current.hMonth == 1 ? current.hYear - 1 : current.hYear;

        setState(() {
          _selectedDate = _hijriDayToGregorian(year, month, 1);
        });
        break;

      case CalendarType.bangla:
        final info = _banglaDateInfo(_selectedDate);

        final previousMonth = info.monthIndex == 0 ? 11 : info.monthIndex - 1;

        final previousYear = info.monthIndex == 0 ? info.year - 1 : info.year;

        setState(() {
          _selectedDate = _banglaMonthStart(previousYear, previousMonth);
        });
        break;
    }
  }

  void _nextMonth() {
    switch (_selectedType) {
      case CalendarType.gregorian:
        setState(() {
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + 1,
            1,
          );
        });
        break;

      case CalendarType.hijri:
        final current = HijriCalendar.fromDate(_selectedDate);

        final month = current.hMonth == 12 ? 1 : current.hMonth + 1;
        final year = current.hMonth == 12 ? current.hYear + 1 : current.hYear;

        setState(() {
          _selectedDate = _hijriDayToGregorian(year, month, 1);
        });
        break;

      case CalendarType.bangla:
        final info = _banglaDateInfo(_selectedDate);

        final nextMonth = (info.monthIndex + 1) % 12;

        final nextYear = info.monthIndex == 11 ? info.year + 1 : info.year;

        setState(() {
          _selectedDate = _banglaMonthStart(nextYear, nextMonth);
        });
        break;
    }
  }

  _CalendarMonthInfo _getMonthInfo() {
    switch (_selectedType) {
      case CalendarType.gregorian:
        return _CalendarMonthInfo(
          title:
              '${_englishMonths[_selectedDate.month - 1]} ${_selectedDate.year}',
        );

      case CalendarType.hijri:
        final hijri = HijriCalendar.fromDate(_selectedDate);

        return _CalendarMonthInfo(
          title:
              '${_arabicHijriMonths[hijri.hMonth - 1]} ${_bnNumber(hijri.hYear)}',
        );

      case CalendarType.bangla:
        final info = _banglaDateInfo(_selectedDate);

        return _CalendarMonthInfo(
          title: '${_banglaMonths[info.monthIndex]} ${_bnNumber(info.year)}',
        );
    }
  }

  _SelectedDateInfo _getSelectedDateInfo() {
    switch (_selectedType) {
      case CalendarType.gregorian:
        return _SelectedDateInfo(
          primary:
              '${_selectedDate.day} ${_englishMonths[_selectedDate.month - 1]} ${_selectedDate.year}',
          weekday: _englishWeekdays[_selectedDate.weekday % 7],
        );

      case CalendarType.hijri:
        final hijri = HijriCalendar.fromDate(_selectedDate);

        return _SelectedDateInfo(
          primary:
              '${_bnNumber(hijri.hDay)} ${_arabicHijriMonths[hijri.hMonth - 1]} ${_bnNumber(hijri.hYear)}',
          weekday: _banglaWeekdays[_selectedDate.weekday % 7],
        );

      case CalendarType.bangla:
        final info = _banglaDateInfo(_selectedDate);

        return _SelectedDateInfo(
          primary:
              '${_bnNumber(info.day)} ${_banglaMonths[info.monthIndex]} ${_bnNumber(info.year)}',
          weekday: _banglaWeekdays[_selectedDate.weekday % 7],
        );
    }
  }

  String _getGregorianShortDate(DateTime date) {
    return '${date.day} ${_englishMonths[date.month - 1]} ${date.year}';
  }

  String _getHijriShortDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);

    return '${_bnNumber(hijri.hDay)} ${_arabicHijriMonths[hijri.hMonth - 1]} ${_bnNumber(hijri.hYear)}';
  }

  String _getBanglaShortDate(DateTime date) {
    final info = _banglaDateInfo(date);

    return '${_bnNumber(info.day)} ${_banglaMonths[info.monthIndex]} ${_bnNumber(info.year)}';
  }

  _BanglaDateInfo _banglaDateInfo(DateTime date) {
    final year = date.year;

    final starts = [
      DateTime(year, 4, 14),
      DateTime(year, 5, 15),
      DateTime(year, 6, 15),
      DateTime(year, 7, 16),
      DateTime(year, 8, 16),
      DateTime(year, 9, 16),
      DateTime(year, 10, 16),
      DateTime(year, 11, 15),
      DateTime(year, 12, 15),
      DateTime(year + 1, 1, 15),
      DateTime(year + 1, 2, 14),
      DateTime(year + 1, 3, 15),
    ];

    int monthIndex = -1;

    for (int i = 0; i < starts.length; i++) {
      if (!date.isBefore(starts[i])) {
        monthIndex = i;
      }
    }

    if (monthIndex >= 0) {
      final banglaYear =
          date.month >= 4 && (date.month > 4 || date.day >= 14)
              ? year - 593
              : year - 594;

      final day = date.difference(starts[monthIndex]).inDays + 1;

      return _BanglaDateInfo(
        year: banglaYear,
        monthIndex: monthIndex,
        day: day,
      );
    }

    final previousYear = year - 1;

    final previousStarts = [
      DateTime(previousYear, 4, 14),
      DateTime(previousYear, 5, 15),
      DateTime(previousYear, 6, 15),
      DateTime(previousYear, 7, 16),
      DateTime(previousYear, 8, 16),
      DateTime(previousYear, 9, 16),
      DateTime(previousYear, 10, 16),
      DateTime(previousYear, 11, 15),
      DateTime(previousYear, 12, 15),
      DateTime(year, 1, 15),
      DateTime(year, 2, 14),
      DateTime(year, 3, 15),
    ];

    for (int i = 0; i < previousStarts.length; i++) {
      if (!date.isBefore(previousStarts[i])) {
        return _BanglaDateInfo(
          year: year - 594,
          monthIndex: i,
          day: date.difference(previousStarts[i]).inDays + 1,
        );
      }
    }

    return _BanglaDateInfo(year: year - 594, monthIndex: 0, day: 1);
  }

  DateTime _banglaMonthStart(int banglaYear, int monthIndex) {
    final gregorianYear = banglaYear + 593;

    switch (monthIndex) {
      case 0:
        return DateTime(gregorianYear, 4, 14);
      case 1:
        return DateTime(gregorianYear, 5, 15);
      case 2:
        return DateTime(gregorianYear, 6, 15);
      case 3:
        return DateTime(gregorianYear, 7, 16);
      case 4:
        return DateTime(gregorianYear, 8, 16);
      case 5:
        return DateTime(gregorianYear, 9, 16);
      case 6:
        return DateTime(gregorianYear, 10, 16);
      case 7:
        return DateTime(gregorianYear, 11, 15);
      case 8:
        return DateTime(gregorianYear, 12, 15);
      case 9:
        return DateTime(gregorianYear + 1, 1, 15);
      case 10:
        return DateTime(gregorianYear + 1, 2, 14);
      case 11:
        return DateTime(gregorianYear + 1, 3, 15);
      default:
        return DateTime(gregorianYear, 4, 14);
    }
  }

  String _bnNumber(int number) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';

    return number.toString().split('').map((digit) {
      final index = en.indexOf(digit);
      return index == -1 ? digit : bn[index];
    }).join();
  }
}

class _CalendarTypeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _CalendarTypeButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color:
                selected ? primary.withValues(alpha: .12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? primary : theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: .55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateMiniInfo extends StatelessWidget {
  final String title;
  final String value;

  const _DateMiniInfo({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .55),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CalendarMonthInfo {
  final String title;

  const _CalendarMonthInfo({required this.title});
}

class _SelectedDateInfo {
  final String primary;
  final String weekday;

  const _SelectedDateInfo({required this.primary, required this.weekday});
}

class _BanglaDateInfo {
  final int year;
  final int monthIndex;
  final int day;

  const _BanglaDateInfo({
    required this.year,
    required this.monthIndex,
    required this.day,
  });
}
