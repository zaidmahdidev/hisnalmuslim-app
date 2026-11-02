import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_views.dart';
import '../../features/adhkar/presentation/reader_screen.dart';
import '../../features/categories/presentation/category_screen.dart';
import '../../features/categories/presentation/library_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/application/settings_controller.dart';
import '../../features/settings/presentation/info_screens.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tasbeeh/presentation/tasbeeh_screen.dart';
import '../localization/gen/app_localizations.dart';
import 'app_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Created once; reads settings lazily in `redirect` so the router is never
/// rebuilt when preferences change.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboardingDone;
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded && !atOnboarding) return Routes.onboarding;
      if (state.matchedLocation == '/') return Routes.home;
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.explore_off_rounded,
        title: AppLocalizations.of(context).notFoundTitle,
        action: FilledButton(
          onPressed: () => context.go(Routes.home),
          child: Text(AppLocalizations.of(context).goHome),
        ),
      ),
    ),
    routes: [
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (_, _) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: ':categoryId',
                    builder: (_, state) =>
                        CategoryScreen(categoryId: state.pathParameters['categoryId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.tasbeeh, builder: (_, _) => const TasbeehScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.favorites, builder: (_, _) => const FavoritesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),
      // Full-screen pages above the tab bar.
      GoRoute(
        path: '/read/:categoryId',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => ReaderScreen(
          key: ValueKey(state.uri.toString()),
          categoryId: state.pathParameters['categoryId']!,
          startId: state.uri.queryParameters['start'],
        ),
      ),
      GoRoute(
        path: Routes.search,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: Routes.reminders,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const RemindersScreen(),
      ),
      GoRoute(
        path: Routes.about,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: Routes.privacy,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PrivacyScreen(),
      ),
      GoRoute(
        path: Routes.sources,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SourcesScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
