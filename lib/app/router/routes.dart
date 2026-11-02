/// Route paths. Reminder notifications deep-link with these too.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const library = '/library';
  static const tasbeeh = '/tasbeeh';
  static const favorites = '/favorites';
  static const settings = '/settings';
  static const search = '/search';
  static const reminders = '/reminders';
  static const about = '/about';
  static const privacy = '/privacy';
  static const sources = '/sources';

  static String category(String id) => '/library/$id';

  static String reader(String categoryId, {String? startId}) => Uri(
    path: '/read/$categoryId',
    queryParameters: startId == null ? null : {'start': startId},
  ).toString();
}
