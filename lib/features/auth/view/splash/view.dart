import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../home-bottombar/view.dart';
import '../login/view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final bool loggedIn = CacheHelper.isLoggedIn();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => loggedIn ? const Bottombar() : const LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F6),
      body: Column(
        children: [
          const SizedBox(height: 185),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset('assets/icons/Background+Shadow (1).svg'),
                SvgPicture.asset(
                  'assets/icons/Overlay+Border+Shadow.svg',
                  width: 112,
                  height: 112,
                ),
                Image.asset('assets/images/logo.png', width: 93, height: 93),
              ],
            ),
          ),
          const SizedBox(height: 29),
          const Text(
            'أُسْرَةُ المَلَاكِ غَبْرِيَالَ',
            style: TextStyle(
              color: Color(0xff7A182B),
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'كنيسة السيدة العذراء مريم بالزيتون',
            style: TextStyle(
              color: Color(0xff554244),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 64,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFFCC260),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          const SizedBox(height: 150),
          const Text(
            'جَارِي التَّحْمِيل...',
            style: TextStyle(
              color: Color(0xff554244),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'أمانة الخدمة الجامعية • ٢٠٢٦',
            style: TextStyle(
              color: Color(0xff554244),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
