import 'package:angel_gabriel/features/home-bottombar/screens/attendance/view.dart';
import 'package:angel_gabriel/features/home-bottombar/screens/home/view.dart';
import 'package:angel_gabriel/features/home-bottombar/screens/notifications/view.dart';
import 'package:angel_gabriel/features/home-bottombar/screens/profile/view.dart';
import 'package:angel_gabriel/features/home-bottombar/screens/scanner/view.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/resources/app-colors.dart';


class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int currentIndex = 0;

  // Tab pages only (the QR page is opened from the center button)
  final List<Widget> screens = const [
    HomeScreen(),
    AttendancePage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  final List<IconData> icons = const [
    Icons.home_rounded,
    Icons.calendar_month_outlined,
    Icons.notifications_none_rounded,
    Icons.person_outline_rounded,
  ];

  final List<String> labels = const [
    'الرئيسية',
    'سجل الحضور',
    'الإشعارات',
    'حسابي',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          width: 68,
          height: 68,
          child: FloatingActionButton(
            elevation: 4,
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 4),
            ),
            backgroundColor: AppColors.burgundy,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRPage()),
              );
            },
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        bottomNavigationBar: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedBottomNavigationBar.builder(
              itemCount: icons.length,
              height: 70,
              activeIndex: currentIndex,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.defaultEdge,
              leftCornerRadius: 24,
              rightCornerRadius: 24,
              backgroundColor: Colors.white,
              shadow: BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
              onTap: (index) => setState(() => currentIndex = index),
              tabBuilder: (int index, bool isActive) {
                final color = isActive ? AppColors.burgundy : AppColors.textGrey;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[index], size: 26, color: color),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: GoogleFonts.tajawal(
                        fontSize: 10,
                        color: color,
                        fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
            // Label under the center QR button
            Positioned(
              bottom: 8,
              child: Text(
                'مسح QR',
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}