import 'package:flutter/foundation.dart';

/// Whether the text is (predominantly) Quranic or from the Sunnah.
enum DhikrKind { quran, sunnah }

/// A short source label derived from the book's footnote, e.g. "مسلم".
@immutable
class DhikrReference {
  const DhikrReference({required this.ar, required this.en});

  factory DhikrReference.fromJson(Map<String, dynamic> json) =>
      DhikrReference(ar: json['ar'] as String, en: json['en'] as String);

  final String ar;
  final String en;

  String label({required bool arabic}) => arabic ? ar : en;
}

/// One remembrance / supplication. Content is immutable and bundled with the
/// app (see assets/content/adhkar.json and docs/CONTENT_GUIDELINES.md).
@immutable
class Dhikr {
  const Dhikr({
    required this.id,
    required this.categoryId,
    required this.order,
    required this.sectionAr,
    required this.sectionEn,
    required this.text,
    required this.repeat,
    required this.kind,
    this.note = '',
    this.footnote = '',
    this.refs = const [],
    this.translation = '',
    this.translationSource = '',
    this.transliteration = '',
    this.source = '',
    this.flags = const [],
  });

  factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    order: json['order'] as int,
    sectionAr: json['sectionAr'] as String,
    sectionEn: json['sectionEn'] as String? ?? '',
    text: json['text'] as String,
    repeat: json['repeat'] as int,
    kind: json['kind'] == 'quran' ? DhikrKind.quran : DhikrKind.sunnah,
    note: json['note'] as String? ?? '',
    footnote: json['footnote'] as String? ?? '',
    refs: [
      for (final r in (json['refs'] as List<dynamic>? ?? const []))
        DhikrReference.fromJson(r as Map<String, dynamic>),
    ],
    translation: json['translation'] as String? ?? '',
    translationSource: json['translationSource'] as String? ?? '',
    transliteration: json['transliteration'] as String? ?? '',
    source: json['source'] as String? ?? '',
    flags: [for (final f in (json['flags'] as List<dynamic>? ?? const [])) f as String],
  );

  final String id;
  final String categoryId;
  final int order;
  final String sectionAr;
  final String sectionEn;

  /// Arabic text exactly as in the source (only typographic clean-up).
  final String text;

  /// Number of repetitions the source prescribes (at least 1).
  final int repeat;
  final DhikrKind kind;

  /// A note from the book, e.g. the evening wording of a morning dhikr.
  final String note;

  /// The book's footnote: takhrij and, where present, the virtue.
  final String footnote;
  final List<DhikrReference> refs;
  final String translation;
  final String translationSource;
  final String transliteration;

  /// Provenance identifier, e.g. `hisnmuslim:77` or `tanzil:quran-simple`.
  final String source;

  /// Review flags recorded by the content build (see the verification report).
  final List<String> flags;

  bool get hasReference => footnote.isNotEmpty || refs.isNotEmpty;
  bool get isQuran => kind == DhikrKind.quran;

  String section({required bool arabic}) => arabic || sectionEn.isEmpty ? sectionAr : sectionEn;

  @override
  bool operator ==(Object other) => other is Dhikr && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
