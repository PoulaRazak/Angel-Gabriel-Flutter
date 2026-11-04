import 'package:angel_gabriel/features/home-bottombar/screens/attendance/view.dart';
import 'package:angel_gabriel/features/home-bottombar/screens/home/view.dart';
import 'package:angel_gabriel/features/home-bottombar/screens/notifications/view.dart';
import 'package:angel_gabriel/features/home-bottombar/screens/profile/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  final List<Widget> screens = const [
    HomeScreen(),
    AttendanceHistoryPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            backgroundColor: const Color(0xffFFF8F6),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xff7A182B),
            unselectedItemColor: const Color(0xff554244),
            selectedLabelStyle: const TextStyle(
              color: Color(0xff7A182B),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              color: Color(0xff554244),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            currentIndex: currentIndex,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/home.svg',
                  colorFilter: ColorFilter.mode(
                    currentIndex == 0
                        ? const Color(0xff7A182B)
                        : const Color(0xff554244),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/attendece.svg',
                  colorFilter: ColorFilter.mode(
                    currentIndex == 1
                        ? const Color(0xff7A182B)
                        : const Color(0xff554244),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'الحضور',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/notifications.svg',
                  colorFilter: ColorFilter.mode(
                    currentIndex == 2
                        ? const Color(0xff7A182B)
                        : const Color(0xff554244),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'الإشعارات',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/profile.svg',
                  colorFilter: ColorFilter.mode(
                    currentIndex == 3
                        ? const Color(0xff7A182B)
                        : const Color(0xff554244),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xffFFF8F6),
      body: screens[currentIndex],
    );
  }
}
