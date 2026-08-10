import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../providers/settings_provider.dart';

class JamaatTimeInput extends StatefulWidget {
  final String prayer;
  final String initialTime;
  final SettingsProvider settingsProvider;

  const JamaatTimeInput({
    super.key,
    required this.prayer,
    required this.initialTime,
    required this.settingsProvider,
  });

  @override
  State<JamaatTimeInput> createState() => _JamaatTimeInputState();
}

class _JamaatTimeInputState extends State<JamaatTimeInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: _displayTime(widget.initialTime));

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _normalizeField();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // =========================================================================
  // DISPLAY
  // =========================================================================

  String _displayTime(String value) {
    final parsed = _parseTime(value);

    if (parsed == null) {
      return value.replaceAll(RegExp(r'[^0-9:]'), '');
    }

    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // =========================================================================
  // PARSE
  // =========================================================================

  _ParsedTime? _parseTime(String value) {
    String input = value.trim();

    if (input.isEmpty) {
      return null;
    }

    final upper = input.toUpperCase();

    bool? explicitPm;

    if (upper.contains('AM')) {
      explicitPm = false;
    } else if (upper.contains('PM')) {
      explicitPm = true;
    }

    input = input.replaceAll(RegExp(r'[^0-9:]'), '');

    if (input.isEmpty) {
      return null;
    }

    int hour;
    int minute;

    if (input.contains(':')) {
      final parts = input.split(':');

      if (parts.length != 2) {
        return null;
      }

      hour = int.tryParse(parts[0]) ?? -1;
      minute = int.tryParse(parts[1]) ?? -1;
    } else {
      if (input.length <= 2) {
        hour = int.tryParse(input) ?? -1;
        minute = 0;
      } else if (input.length == 3) {
        hour = int.tryParse(input.substring(0, 1)) ?? -1;
        minute = int.tryParse(input.substring(1)) ?? -1;
      } else if (input.length == 4) {
        hour = int.tryParse(input.substring(0, 2)) ?? -1;
        minute = int.tryParse(input.substring(2)) ?? -1;
      } else {
        return null;
      }
    }

    if (hour < 0 || minute < 0 || minute > 59) {
      return null;
    }

    // -----------------------------------------------------------------------
    // Explicit AM/PM
    // -----------------------------------------------------------------------

    if (explicitPm != null) {
      if (hour == 0 || hour > 12) {
        return null;
      }

      return _ParsedTime(hour: hour, minute: minute, isPm: explicitPm);
    }

    // -----------------------------------------------------------------------
    // 24-hour input support
    // -----------------------------------------------------------------------

    if (hour > 23) {
      return null;
    }

    if (hour == 0) {
      return _ParsedTime(hour: 12, minute: minute, isPm: false);
    }

    if (hour > 12) {
      return _ParsedTime(hour: hour - 12, minute: minute, isPm: true);
    }

    // -----------------------------------------------------------------------
    // NurVerse prayer-aware default
    //
    // User can simply type:
    //
    // Fajr     -> 5:00  => 05:00 AM
    // Dhuhr    -> 1:30  => 01:30 PM
    // Asr      -> 5:15  => 05:15 PM
    // Maghrib  -> 6:57  => 06:57 PM
    // Isha     -> 8:45  => 08:45 PM
    // -----------------------------------------------------------------------

    final bool isPm = widget.prayer != 'Fajr';

    return _ParsedTime(hour: hour, minute: minute, isPm: isPm);
  }

  // =========================================================================
  // NORMALIZE FIELD
  // =========================================================================

  void _normalizeField() {
    final parsed = _parseTime(_controller.text);

    if (parsed == null) {
      if (_controller.text.trim().isEmpty) {
        setState(() {
          _errorText = 'সময় লিখুন';
        });
      }

      return;
    }

    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    final formatted = '$hour:$minute';

    if (_controller.text != formatted) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
  }

  // =========================================================================
  // SAVE
  // =========================================================================

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final parsed = _parseTime(_controller.text);

    if (parsed == null) {
      setState(() {
        _errorText = 'সঠিক সময় লিখুন';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    final period = parsed.isPm ? 'PM' : 'AM';

    final normalizedTime = '$hour:$minute $period';

    await widget.settingsProvider.setJamaatTime(widget.prayer, normalizedTime);

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
      _controller.text = '$hour:$minute';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_prayerName(widget.prayer)}-এর জামাতের সময় $normalizedTime সেট হয়েছে',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =========================================================================
  // PRAYER NAME
  // =========================================================================

  String _prayerName(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return 'ফজর';

      case 'Dhuhr':
        return 'যোহর';

      case 'Asr':
        return 'আসর';

      case 'Maghrib':
        return 'মাগরিব';

      case 'Isha':
        return 'ইশা';

      default:
        return prayer;
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          // -------------------------------------------------------------------
          // PRAYER ICON
          // -------------------------------------------------------------------
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.mosque_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          // -------------------------------------------------------------------
          // PRAYER NAME
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _prayerName(widget.prayer),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'জামাতের সময়',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // TIME INPUT
          // -------------------------------------------------------------------
          SizedBox(
            width: 92,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 5,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: InputDecoration(
                counterText: '',
                hintText: '8:45',
                errorText: _errorText,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                filled: true,
                fillColor: colorScheme.surface.withValues(alpha: 0.65),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.18),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.18),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: (_) => _save(),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
            ),
          ),

          const SizedBox(width: 8),

          // -------------------------------------------------------------------
          // SAVE BUTTON
          // -------------------------------------------------------------------
          SizedBox(
            width: 42,
            height: 42,
            child: Material(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _saving ? null : _save,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child:
                      _saving
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                          : Icon(
                            Icons.check_rounded,
                            color: colorScheme.onPrimary,
                            size: 21,
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParsedTime {
  final int hour;
  final int minute;
  final bool isPm;

  const _ParsedTime({
    required this.hour,
    required this.minute,
    required this.isPm,
  });
}
