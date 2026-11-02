import 'package:flutter/foundation.dart';

import 'adhkar_category.dart';
import 'dhikr.dart';

/// The complete, parsed content database.
@immutable
class ContentBundle {
  const ContentBundle({required this.version, required this.categories, required this.items});

  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    final categories = [
      for (final c in json['categories'] as List<dynamic>)
        AdhkarCategory.fromJson(c as Map<String, dynamic>),
    ]..sort((a, b) => a.order.compareTo(b.order));
    final items = [
      for (final i in json['items'] as List<dynamic>) Dhikr.fromJson(i as Map<String, dynamic>),
    ];
    return ContentBundle(version: json['version'] as int, categories: categories, items: items);
  }

  final int version;
  final List<AdhkarCategory> categories;
  final List<Dhikr> items;
}
