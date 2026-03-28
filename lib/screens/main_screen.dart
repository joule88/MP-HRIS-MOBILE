import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/notification_provider.dart';
import '../services/fcm_service.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'presensi/presensi_screen.dart';
import 'pengajuan/pengajuan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PresensiScreen(),
    const PengajuanScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchUnreadCount();
      FcmService().initialize(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationProvider>().fetchUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd, AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowLg,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: Colors.transparent,
                selectedItemColor: AppTheme.primaryOrange,
                unselectedItemColor: AppTheme.textTertiary,
                showUnselectedLabels: false,
                showSelectedLabels: true,
                selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.grid_view_rounded, size: 24)),
                    activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.grid_view_rounded, size: 26)),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.fingerprint, size: 24)),
                    activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.fingerprint, size: 26)),
                    label: 'Presensi',
                  ),
                  BottomNavigationBarItem(
                    icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.insert_page_break_outlined, size: 24)),
                    activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.insert_page_break_rounded, size: 26)),
                    label: 'Pengajuan',
                  ),
                  BottomNavigationBarItem(
                    icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline, size: 24)),
                    activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded, size: 26)),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
