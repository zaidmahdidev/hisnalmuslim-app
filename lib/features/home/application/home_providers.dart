import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/adhkar_category.dart';
import '../../../data/models/dhikr.dart';

enum DayPart { morning, day, evening, night }

/// Coarse time of day used for the greeting and the suggestion.
/// Approximate by design: the app does not use location for prayer times.
DayPart dayPartOf(DateTime time) {
  final h = time.hour;
  if (h >= 3 && h < 11) return DayPart.morning;
  if (h >= 11 && h < 15) return DayPart.day;
  if (h >= 15 && h < 20) return DayPart.evening;
  return DayPart.night;
}

final dayPartProvider = Provider<DayPart>((ref) => dayPartOf(ref.watch(clockProvider)()));

/// Category suggested on the home screen for the current time of day.
final suggestedCategoryProvider = Provider<String>(
  (ref) => switch (ref.watch(dayPartProvider)) {
    DayPart.morning => CategoryIds.morning,
    DayPart.day => CategoryIds.afterPrayer,
    DayPart.evening => CategoryIds.evening,
    DayPart.night => CategoryIds.sleep,
  },
);

final dailyDhikrProvider = Provider<Dhikr?>(
  (ref) => ref.watch(contentRepositoryProvider).dailyDhikr(ref.watch(clockProvider)()),
);
