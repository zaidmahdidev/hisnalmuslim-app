/// Normalises Arabic (and Latin) text so that searching is forgiving:
///
/// * removes tashkeel, Quranic annotation marks and tatweel,
/// * unifies alef forms (أ إ آ ٱ → ا), ى → ي, ة → ه, ؤ → و, ئ → ي,
/// * unifies Persian/Urdu letter variants (ک → ك, ی → ي),
/// * strips punctuation and lower-cases Latin letters.
abstract final class ArabicNormalizer {
  static final RegExp _marks = RegExp('[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]');
  static final RegExp _nonWord = RegExp(r'[^\u0621-\u064Aa-z0-9\s]');
  static final RegExp _spaces = RegExp(r'\s+');

  static const Map<String, String> _letters = {
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ٱ': 'ا',
    'ى': 'ي',
    'ی': 'ي',
    'ئ': 'ي',
    'ة': 'ه',
    'ؤ': 'و',
    'ک': 'ك',
  };

  static String normalize(String input) {
    final stripped = input.replaceAll(_marks, '').toLowerCase();
    final buffer = StringBuffer();
    for (final rune in stripped.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_letters[char] ?? char);
    }
    return buffer.toString().replaceAll(_nonWord, ' ').replaceAll(_spaces, ' ').trim();
  }

  /// Splits a normalised query into search terms.
  static List<String> terms(String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) return const [];
    return normalized.split(' ');
  }
}
