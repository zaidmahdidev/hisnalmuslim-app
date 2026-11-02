import '../../core/utils/arabic_normalizer.dart';
import '../../core/utils/day_key.dart';
import '../models/adhkar_category.dart';
import '../models/content_bundle.dart';
import '../models/dhikr.dart';

/// A group of adhkar sharing the same chapter heading inside a category.
class DhikrSection {
  const DhikrSection({required this.titleAr, required this.titleEn, required this.items});

  final String titleAr;
  final String titleEn;
  final List<Dhikr> items;

  String title({required bool arabic}) => arabic || titleEn.isEmpty ? titleAr : titleEn;
}

class SearchResult {
  const SearchResult(this.dhikr, this.score);

  final Dhikr dhikr;
  final int score;
}

/// Read-only, in-memory access to the bundled content with an offline
/// search index. Built once at start-up.
class ContentRepository {
  ContentRepository(ContentBundle bundle)
    : version = bundle.version,
      categories = List.unmodifiable(bundle.categories) {
    final byCategory = <String, List<Dhikr>>{};
    for (final item in bundle.items) {
      _byId[item.id] = item;
      byCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }
    for (final entry in byCategory.entries) {
      entry.value.sort((a, b) => a.order.compareTo(b.order));
      _byCategory[entry.key] = List.unmodifiable(entry.value);
    }
    for (final category in categories) {
      _categories[category.id] = category;
    }
    for (final item in bundle.items) {
      final category = _categories[item.categoryId];
      _index[item.id] = _IndexEntry(
        heading: ArabicNormalizer.normalize(
          '${item.sectionAr} ${item.sectionEn} ${category?.titleAr ?? ''} ${category?.titleEn ?? ''}',
        ),
        body: ArabicNormalizer.normalize('${item.text} ${item.translation}'),
      );
    }
  }

  final int version;
  final List<AdhkarCategory> categories;

  final Map<String, Dhikr> _byId = {};
  final Map<String, List<Dhikr>> _byCategory = {};
  final Map<String, AdhkarCategory> _categories = {};
  final Map<String, _IndexEntry> _index = {};

  int get itemCount => _byId.length;

  AdhkarCategory? category(String id) => _categories[id];

  Dhikr? byId(String id) => _byId[id];

  List<Dhikr> itemsOf(String categoryId) => _byCategory[categoryId] ?? const [];

  /// Resolves ids (e.g. favorites) to items, silently skipping ids that no
  /// longer exist after a content update.
  List<Dhikr> resolve(Iterable<String> ids) => [for (final id in ids) ?_byId[id]];

  List<DhikrSection> sectionsOf(String categoryId) {
    final sections = <String, List<Dhikr>>{};
    final titlesEn = <String, String>{};
    for (final item in itemsOf(categoryId)) {
      sections.putIfAbsent(item.sectionAr, () => []).add(item);
      titlesEn[item.sectionAr] = item.sectionEn;
    }
    return [
      for (final e in sections.entries)
        DhikrSection(titleAr: e.key, titleEn: titlesEn[e.key] ?? '', items: e.value),
    ];
  }

  /// Offline search across text, translation, chapter and category titles.
  /// Every query term must match; heading matches rank above body matches.
  List<SearchResult> search(String query, {int limit = 80, Set<String>? onlyIds}) {
    final terms = ArabicNormalizer.terms(query);
    if (terms.isEmpty) return const [];
    final results = <SearchResult>[];
    for (final entry in _index.entries) {
      if (onlyIds != null && !onlyIds.contains(entry.key)) continue;
      final index = entry.value;
      var score = 0;
      var matched = true;
      for (final term in terms) {
        if (index.heading.contains(term)) {
          score += 3;
        } else if (index.body.contains(term)) {
          score += 1;
        } else {
          matched = false;
          break;
        }
      }
      if (matched) results.add(SearchResult(_byId[entry.key]!, score));
    }
    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final catA = _categories[a.dhikr.categoryId]?.order ?? 0;
      final catB = _categories[b.dhikr.categoryId]?.order ?? 0;
      return catA != catB ? catA.compareTo(catB) : a.dhikr.order.compareTo(b.dhikr.order);
    });
    return results.length > limit ? results.sublist(0, limit) : results;
  }

  /// A deterministic "remembrance of the day": a short, referenced item that
  /// changes once per local day.
  Dhikr? dailyDhikr(DateTime now) {
    final pool = _dailyPool ??= [
      for (final item in _byId.values)
        if (item.hasReference &&
            item.text.length >= 25 &&
            item.text.length <= 240 &&
            !item.text.contains('[') &&
            item.categoryId != CategoryIds.morning &&
            item.categoryId != CategoryIds.evening)
          item,
    ]..sort((a, b) => a.id.compareTo(b.id));
    if (pool.isEmpty) return null;
    return pool[DayKey.ordinal(now) % pool.length];
  }

  List<Dhikr>? _dailyPool;
}

class _IndexEntry {
  const _IndexEntry({required this.heading, required this.body});

  final String heading;
  final String body;
}
