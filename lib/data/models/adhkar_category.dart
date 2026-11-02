import 'package:flutter/foundation.dart';

@immutable
class AdhkarCategory {
  const AdhkarCategory({
    required this.id,
    required this.order,
    required this.icon,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
  });

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) => AdhkarCategory(
    id: json['id'] as String,
    order: json['order'] as int,
    icon: json['icon'] as String,
    titleAr: json['titleAr'] as String,
    titleEn: json['titleEn'] as String,
    subtitleAr: json['subtitleAr'] as String,
    subtitleEn: json['subtitleEn'] as String,
  );

  final String id;
  final int order;

  /// Key resolved to an icon by `CategoryIcon`.
  final String icon;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;

  String title({required bool arabic}) => arabic ? titleAr : titleEn;
  String subtitle({required bool arabic}) => arabic ? subtitleAr : subtitleEn;

  @override
  bool operator ==(Object other) => other is AdhkarCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Well-known category identifiers used by shortcuts and reminders.
abstract final class CategoryIds {
  static const morning = 'morning';
  static const evening = 'evening';
  static const sleep = 'sleep';
  static const waking = 'waking';
  static const afterPrayer = 'after_prayer';
  static const quranDuas = 'quran_duas';

  /// Pseudo category: the user's favorites, read in order.
  static const favorites = 'favorites';
}
