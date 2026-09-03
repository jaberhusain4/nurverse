from pathlib import Path

path = Path('lib/screens/canonical_settings_screen.dart')
text = path.read_text(encoding='utf-8')

replacements = {
    "subtitle: Text(s.use24HourFormat ? '24-hour' : '12-hour'),": "subtitle: Text(s.is24Hour ? '24-hour' : '12-hour'),",
    "selected: {s.use24HourFormat},": "selected: {s.is24Hour},",
    "if (v.isNotEmpty) s.set24HourFormat(v.first);": "if (v.isNotEmpty) s.setTimeFormat(v.first ? '24' : '12');",
    "String textSizeLabel(TextScaleLevel level, String l) => choice(level.name, l);": "String textSizeLabel(int level, String l) {\n    switch (level) {\n      case 0:\n        return t(l, 'ছোট', 'Small');\n      case 2:\n        return t(l, 'বড়', 'Large');\n      case 3:\n        return t(l, 'অতিরিক্ত বড়', 'Extra Large');\n      default:\n        return t(l, 'স্বাভাবিক', 'Normal');\n    }\n  }",
}

for old, new in replacements.items():
    if old not in text:
        raise SystemExit(f'Expected text not found: {old}')
    text = text.replace(old, new, 1)

path.write_text(text, encoding='utf-8')
