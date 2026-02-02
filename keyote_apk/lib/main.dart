import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/keyboard_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/keyboard_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'views/keyboard_screen.dart';
import 'views/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final storageService = await StorageService.getInstance();
  final keyboardService = KeyboardService();

  runApp(
    MyApp(storageService: storageService, keyboardService: keyboardService),
  );
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final KeyboardService keyboardService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.keyboardService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(keyboardService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => KeyboardViewModel(keyboardService),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'Keyote Remote',
            debugShowCheckedModeBanner: false,
            themeMode: settingsViewModel.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const KeyboardScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
