import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/favoritos_service.dart';
import 'core/services/producto_service.dart';
import 'core/services/wearable_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

class SportWearWearableApp extends StatelessWidget {
  const SportWearWearableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiClient()),
        ChangeNotifierProxyProvider<ApiClient, AuthService>(
          create: (context) => AuthService(context.read<ApiClient>()),
          update: (context, apiClient, previous) => previous ?? AuthService(apiClient),
        ),
        ChangeNotifierProxyProvider<ApiClient, WearableService>(
          create: (context) => WearableService(context.read<ApiClient>()),
          update: (context, apiClient, previous) => previous ?? WearableService(apiClient),
        ),
        ChangeNotifierProxyProvider<ApiClient, FavoritosService>(
          create: (context) => FavoritosService(context.read<ApiClient>()),
          update: (context, apiClient, previous) => previous ?? FavoritosService(apiClient),
        ),
        ChangeNotifierProxyProvider<ApiClient, ProductoService>(
          create: (context) => ProductoService(context.read<ApiClient>()),
          update: (context, apiClient, previous) => previous ?? ProductoService(apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'SportWear Band',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
