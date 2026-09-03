from pathlib import Path

p = Path('lib/screens/canonical_settings_screen.dart')
s = p.read_text(encoding='utf-8')

# Restore the historical layout: the large Premium hero appears first,
# before the Personalization section.
premium_call = "          _premium(context, s, premium),\n"
s = s.replace(premium_call, '', 1)

personalization = """        children: [
          _section(
            context,
            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),"""
if personalization not in s:
    raise SystemExit('Personalization section not found')

replacement = """        children: [
          _premium(context, s, premium),
          const SizedBox(height: 18),
          _section(
            context,
            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),"""
s = s.replace(personalization, replacement, 1)

# Match the historical larger Premium presentation.
s = s.replace(
    'padding: const EdgeInsets.all(20),\n          decoration: BoxDecoration(',
    'padding: const EdgeInsets.all(22),\n          decoration: BoxDecoration(',
    1,
)
s = s.replace(
    'borderRadius: BorderRadius.circular(28),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),',
    'borderRadius: BorderRadius.circular(30),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),',
    1,
)
s = s.replace('width: 54,\n                    height: 54,', 'width: 60,\n                    height: 60,', 1)
s = s.replace('size: 30,\n                    ),', 'size: 32,\n                    ),', 1)
s = s.replace(
    'fontSize: 18,\n                                  fontWeight: FontWeight.w900,',
    'fontSize: 20,\n                                  fontWeight: FontWeight.w900,',
    1,
)
s = s.replace(
    'padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),',
    'padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),',
    1,
)

p.write_text(s, encoding='utf-8')
