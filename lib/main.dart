import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/error_handler.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/pengajuan_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/face_provider.dart';
import 'providers/poin_provider.dart';
import 'providers/signature_provider.dart';
import 'providers/surat_izin_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/presensi/presensi_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/pengajuan/pengajuan_screen.dart';

import 'screens/pengajuan/forms/cuti_form_screen.dart';
import 'screens/pengajuan/forms/sakit_form_screen.dart';
import 'screens/pengajuan/forms/izin_form_screen.dart';
import 'screens/pengajuan/forms/lembur_form_screen.dart';

import 'screens/onboarding/face_enrollment_screen.dart';
import 'screens/poin/point_usage_screen.dart';
import 'screens/poin/poin_history_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/salary/salary_estimator_screen.dart';
import 'screens/api_settings_screen.dart';
import 'screens/profile/face_test_screen.dart';
import 'screens/profile/signature_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/documents/surat_izin_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/cache_manager.dart';
import 'core/constants/api_url.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await CacheManager.init();

  await ApiUrl.initialize();

  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => PengajuanProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => FaceProvider()),
        ChangeNotifierProvider(create: (_) => PoinProvider()),
        ChangeNotifierProvider(create: (_) => SignatureProvider()),
        ChangeNotifierProvider(create: (_) => SuratIzinProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'MPG HRIS',
        scaffoldMessengerKey: ErrorHandler.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MainScreen(),
          '/presensi': (context) => const PresensiScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/pengajuan': (context) => const PengajuanScreen(),
          '/pengajuan/cuti': (context) => const CutiFormScreen(),
          '/pengajuan/sakit': (context) => const SakitFormScreen(),
          '/pengajuan/izin': (context) => const IzinFormScreen(),
          '/pengajuan/lembur': (context) => const LemburFormScreen(),
          '/onboarding/face-enrollment': (context) => const FaceEnrollmentScreen(),
          '/poin/usage': (context) => const PointUsageScreen(),
          '/poin/history': (context) => const PoinHistoryScreen(),
          '/notification': (context) => const NotificationScreen(),
          '/salary/estimator': (context) => const SalaryEstimatorScreen(),
          '/settings/api': (context) => const ApiSettingsScreen(),
          '/profile/face-test': (context) => const FaceTestScreen(),
          '/profile/signature': (context) => const SignatureScreen(),
          '/profile/edit': (context) => const EditProfileScreen(),
          '/surat-izin': (context) => const SuratIzinScreen(),
        },
      ),
    );
  }
}
