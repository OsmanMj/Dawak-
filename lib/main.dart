import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/medication_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  final storageService = StorageService();
  final bool hasSeenOnboarding = await storageService.hasSeenOnboarding();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider(storageService)),
        ChangeNotifierProxyProvider<ProfileProvider, MedicationProvider>(
          create: (_) =>
              MedicationProvider(storageService, notificationService),
          update: (_, profileProvider, medicationProvider) {
            medicationProvider ??=
                MedicationProvider(storageService, notificationService);
            if (profileProvider.currentProfileId != null) {
              medicationProvider
                  .updateProfile(profileProvider.currentProfileId!);
            }
            return medicationProvider;
          },
        ),
      ],
      child: DawakApp(
          startScreen: hasSeenOnboarding
              ? const MainScreen()
              : const OnboardingScreen()),
    ),
  );
}

class DawakApp extends StatelessWidget {
  final Widget startScreen;
  const DawakApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دواؤك',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.amber,
          surface: Colors.grey.shade50,
        ),
        useMaterial3: true,
        fontFamily:
            'Cairo', // Assuming we might add a font later, or use default system font
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
              color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          surfaceTintColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      home: startScreen,
    );
  }
}
