from pathlib import Path

p = Path('lib/screens/canonical_settings_screen.dart')
s = p.read_text(encoding='utf-8')

# Restore the historical placement: Personalization first, then the large Premium hero.
old = """        children: [
          _premium(context, s, premium),
          const SizedBox(height: 18),
          _section(
            context,
            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),"""
new = """        children: [
          _section(
            context,
            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),"""
if old in s:
    s = s.replace(old, new, 1)
    marker = """          ),
          const SizedBox(height: 20),
          _section(
            context,
            t(l, 'অ্যাপের চেহারা', 'Appearance'),"""
    insert = """          ),
          const SizedBox(height: 16),
          _premium(context, s, premium),
          const SizedBox(height: 20),
          _section(
            context,
            t(l, 'অ্যাপের চেহারা', 'Appearance'),"""
    if marker not in s:
        raise SystemExit('Appearance marker not found after personalization')
    s = s.replace(marker, insert, 1)

# Make the hero visibly match the older, larger presentation.
s = s.replace('padding: const EdgeInsets.all(20),\n          decoration: BoxDecoration(', 'padding: const EdgeInsets.all(22),\n          decoration: BoxDecoration(', 1)
s = s.replace('borderRadius: BorderRadius.circular(28),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),', 'borderRadius: BorderRadius.circular(30),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),', 1)
s = s.replace('width: 54,\n                    height: 54,', 'width: 60,\n                    height: 60,', 1)
s = s.replace('size: 30,\n                    ),', 'size: 32,\n                    ),', 1)
s = s.replace('fontSize: 18,\n                                  fontWeight: FontWeight.w900,', 'fontSize: 20,\n                                  fontWeight: FontWeight.w900,', 1)
s = s.replace('padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),', 'padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),', 1)

p.write_text(s, encoding='utf-8')
