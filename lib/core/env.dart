// lib/core/env.dart
// class Env {
//   static const apiBaseUrl = String.fromEnvironment(
//     'API_BASE_URL',
//     defaultValue: 'http://127.0.0.1:8000/api', // fallback local
//   );
// }

class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://marianela-api-szvfe.sevalla.app/api', // fallback local
  );
}
