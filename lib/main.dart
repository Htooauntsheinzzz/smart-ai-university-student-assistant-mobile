import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/token_store.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

/// Composition root for the application (DEC-010).
///
/// The configuration, HTTP client, token store, session storage and
/// [AuthController] are built once here and handed down to the widget
/// tree. Nothing else performs HTTP calls directly.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final tokenStore = TokenStore();
  final sessionStorage = SecureSessionStorage();
  final apiClient = ApiClient(
    baseUrl: config.apiBaseUrl,
    tokenStore: tokenStore,
  );
  final controller = AuthController(
    api: HttpAuthApi(apiClient.dio),
    sessionStorage: sessionStorage,
    tokenStore: tokenStore,
  );

  runApp(App(authController: controller));
}
