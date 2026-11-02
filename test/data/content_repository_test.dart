import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/core/utils/arabic_normalizer.dart';
import 'package:hisn_almuslim_app/data/models/adhkar_category.dart';
import 'package:hisn_almuslim_app/data/models/dhikr.dart';

import '../helpers/test_helpers.dart';

void main() {
  final repo = loadContent();

  group('content integrity', () {
    test('has the 13 required categories, each with items', () {
      expect(repo.categories.map((c) => c.id), [
        'morning',
        'evening',
        'sleep',
        'waking',
        'after_prayer',
        'prayer',
        'mosque',
        'food',
        'home',
        'travel',
        'quran_duas',
        'prophetic_duas',
        'misc',
      ]);
      for (final c in repo.categories) {
        expect(repo.itemsOf(c.id), isNotEmpty, reason: c.id);
        expect(c.titleAr, isNotEmpty);
        expect(c.titleEn, isNotEmpty);
      }
    });

    test('every item has text, a positive repeat count and a traceable source', () {
      expect(repo.itemCount, greaterThan(300));
      for (final c in repo.categories) {
        for (final d in repo.itemsOf(c.id)) {
          expect(d.text.trim(), isNotEmpty, reason: d.id);
          expect(d.repeat, greaterThanOrEqualTo(1), reason: d.id);
          expect(d.sectionAr, isNotEmpty, reason: d.id);
          expect(d.source, matches(RegExp(r'^(hisnmuslim|tanzil|rn0x):')), reason: d.id);
        }
      }
    });

    test('items are ordered without gaps inside each category', () {
      for (final c in repo.categories) {
        final orders = repo.itemsOf(c.id).map((d) => d.order).toList();
        expect(orders, List.generate(orders.length, (i) => i), reason: c.id);
      }
    });

    test('Quranic supplications are marked as Quran with a surah reference', () {
      final quran = repo.itemsOf(CategoryIds.quranDuas);
      for (final d in quran) {
        expect(d.kind, DhikrKind.quran);
        expect(d.text, startsWith('﴿'));
        expect(d.refs.single.en, startsWith('Quran '));
      }
    });

    test('morning starts with Ayat al-Kursi and uses morning wording', () {
      final morning = repo.itemsOf(CategoryIds.morning);
      expect(ArabicNormalizer.normalize(morning.first.text), contains('الحي القيوم'));
      final texts = morning.map((d) => ArabicNormalizer.normalize(d.text)).join(' ');
      expect(texts, contains('اصبحنا واصبح الملك لله'));
    });

    test('evening uses the evening wording noted by the book', () {
      final evening = repo
          .itemsOf(CategoryIds.evening)
          .map((d) => ArabicNormalizer.normalize(d.text));
      expect(evening.join(' '), contains('امسينا وامسي الملك لله'));
      // "أصبحنا وأصبح الملك" must not appear in the evening list.
      expect(evening.join(' '), isNot(contains('اصبحنا واصبح الملك')));
    });

    test('at least 95% of items carry a reference', () {
      final all = repo.categories.expand((c) => repo.itemsOf(c.id)).toList();
      final referenced = all.where((d) => d.hasReference).length;
      expect(referenced / all.length, greaterThan(0.95));
    });
  });

  group('sections', () {
    test('group items by the book chapter heading in order', () {
      final sections = repo.sectionsOf('prayer');
      expect(sections.length, greaterThan(5));
      expect(sections.expand((s) => s.items).length, repo.itemsOf('prayer').length);
    });
  });

  group('search', () {
    test('finds text regardless of diacritics and alef forms', () {
      final withMarks = repo.search('أَعُوذُ بِكَلِمَاتِ');
      final plain = repo.search('اعوذ بكلمات');
      expect(plain, isNotEmpty);
      expect(withMarks.map((r) => r.dhikr.id), plain.map((r) => r.dhikr.id));
    });

    test('matches category and chapter titles with a higher score', () {
      final results = repo.search('الصباح');
      expect(results, isNotEmpty);
      expect(results.first.dhikr.categoryId, anyOf('morning', 'evening'));
    });

    test('requires every term to match', () {
      final results = repo.search('سبحان الله وبحمده');
      for (final r in results) {
        final body = ArabicNormalizer.normalize(r.dhikr.text);
        expect(body.contains('سبحان') || r.score > 3, isTrue);
      }
      expect(repo.search('سبحان كلمةغيرموجودة'), isEmpty);
    });

    test('searches English translations and chapter titles', () {
      expect(repo.search('travel'), isNotEmpty);
      expect(repo.search('Morning'), isNotEmpty);
    });

    test('can be limited to a set of ids (favorites search)', () {
      final ids = {repo.itemsOf('sleep').first.id};
      final results = repo.search('الله', onlyIds: ids);
      expect(results.map((r) => r.dhikr.id).toSet(), ids);
    });

    test('empty query returns nothing', () {
      expect(repo.search('   '), isEmpty);
    });
  });

  group('daily dhikr', () {
    test('is stable within a day and changes across days', () {
      final a = repo.dailyDhikr(DateTime(2026, 1, 1, 6));
      final b = repo.dailyDhikr(DateTime(2026, 1, 1, 22));
      final c = repo.dailyDhikr(DateTime(2026, 1, 2, 6));
      expect(a, isNotNull);
      expect(a!.id, b!.id);
      expect(c!.id, isNot(a.id));
      expect(a.hasReference, isTrue);
    });
  });

  test('resolve skips unknown ids', () {
    final first = repo.itemsOf('morning').first;
    expect(repo.resolve([first.id, 'removed-id']), [first]);
  });
}
