# Locked UI Components

## Ruqyah Waqf Marker

The waqf marker rendered at the end of the `Bismillahillazi` dua in `lib/screens/tools/ruqyah_screen.dart` is a **locked canonical NurVerse component**.

Do not replace it with:
- a custom circle/dot drawing;
- a Unicode fallback that produces a tofu/missing-glyph box;
- any glyph that contains an ayah number;
- any global font/theme change.

Current canonical rendering:
- glyph: `۝`
- scoped font: `NotoNaskhArabic`
- no digit/ayah number
- no change to the app's global text or digit typography

Any future change to this marker requires explicit product approval.
## Settings Premium Card

The Premium card at the top of `lib/screens/canonical_settings_screen.dart` is a **locked canonical NurVerse component**.

Do not redesign, compact, replace, or remove its approved presentation, account interaction, Premium chips, or SeaBlue styling without explicit product approval.
