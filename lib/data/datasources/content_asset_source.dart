import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/content_bundle.dart';

/// Loads the bundled content database. Parsing runs on a background isolate
/// so app start-up never blocks the UI thread.
class ContentAssetSource {
  const ContentAssetSource({this.bundle, this.path = defaultPath});

  static const defaultPath = 'assets/content/adhkar.json';

  /// Defaults to [rootBundle]; injectable for tests.
  final AssetBundle? bundle;
  final String path;

  Future<ContentBundle> load() async {
    final raw = await (bundle ?? rootBundle).loadString(path);
    return compute(parseContent, raw);
  }
}

/// Top-level so it can run in an isolate.
ContentBundle parseContent(String raw) =>
    ContentBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
