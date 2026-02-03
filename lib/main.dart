import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_tab_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_portainer_flutter/l10n/app_localizations.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  final String? languageCode = prefs.getString('language_code');
  runApp(MyApp(initialLanguageCode: languageCode));
}

class MyApp extends StatefulWidget {
  final String? initialLanguageCode;
  const MyApp({super.key, this.initialLanguageCode});

  static void setLocale(BuildContext context, Locale? newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    if (widget.initialLanguageCode != null) {
      _locale = Locale(widget.initialLanguageCode!);
    }
  }

  void setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
    _saveLocale(locale);
  }

  Future<void> _saveLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('language_code');
    } else {
      await prefs.setString('language_code', locale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docker Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      home: const MainTabScreen(),
    );
  }
}
