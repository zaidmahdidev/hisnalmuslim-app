import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/core/utils/arabic_normalizer.dart';
import 'package:hisn_almuslim_app/core/utils/day_key.dart';

void main() {
  group('ArabicNormalizer', () {
    test('removes tashkeel and tatweel', () {
      expect(ArabicNormalizer.normalize('سُبْحَانَ اللَّهِ'), 'سبحان الله');
      expect(ArabicNormalizer.normalize('أَمْسَيْـنا'), 'امسينا');
    });

    test('unifies alef, yaa, taa marbuta, hamza carriers', () {
      expect(ArabicNormalizer.normalize('أعوذ إليك آمنت ٱلله'), 'اعوذ اليك امنت الله');
      expect(ArabicNormalizer.normalize('على'), 'علي');
      expect(ArabicNormalizer.normalize('رحمة'), 'رحمه');
      expect(ArabicNormalizer.normalize('مؤمن'), 'مومن');
      expect(ArabicNormalizer.normalize('ملائكة'), 'ملايكه');
    });

    test('unifies Persian letter variants', () {
      expect(ArabicNormalizer.normalize('کتاب یوم'), 'كتاب يوم');
    });

    test('strips punctuation and Quranic brackets, lowercases Latin', () {
      expect(ArabicNormalizer.normalize('﴿قُلْ هُوَ اللَّهُ أَحَدٌ﴾،'), 'قل هو الله احد');
      expect(ArabicNormalizer.normalize('((Morning)) Adhkar!'), 'morning adhkar');
    });

    test('splits terms and ignores empty input', () {
      expect(ArabicNormalizer.terms('  أذكار   الصباح '), ['اذكار', 'الصباح']);
      expect(ArabicNormalizer.terms('  ،،  '), isEmpty);
    });
  });

  group('DayKey', () {
    test('formats and parses local dates', () {
      expect(DayKey.of(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
      expect(DayKey.parse('2026-03-07'), DateTime(2026, 3, 7));
    });

    test('previous crosses month and year boundaries', () {
      expect(DayKey.previous('2026-03-01'), '2026-02-28');
      expect(DayKey.previous('2026-01-01'), '2025-12-31');
    });

    test('ordinal increases by one per day', () {
      final a = DayKey.ordinal(DateTime(2026, 5, 1, 23));
      final b = DayKey.ordinal(DateTime(2026, 5, 2, 1));
      expect(b - a, 1);
    });
  });
}
