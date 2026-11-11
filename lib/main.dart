import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'controllers/quote_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/task_controller.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'database/db_init.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await initDatabaseFactory();

  final settings = SettingsController();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<TaskController>(
          create: (_) => TaskController()..load(),
        ),
        ChangeNotifierProvider<QuoteController>(
          create: (_) => QuoteController()..loadToday(),
        ),
      ],
      child: const OrganizaApp(),
    ),
  );
}

class OrganizaApp extends StatelessWidget {
  const OrganizaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
