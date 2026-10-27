import 'package:angel_gabriel/core/resources/app-colors.dart';
import 'package:angel_gabriel/core/resources/app-images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/view/login/view.dart';
import '../home-bottombar/view.dart';
// TODO: make sure CashHelper is imported here (add the import of your file).

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    // Keep the splash visible for 5 seconds.
    await Future.delayed(const Duration(seconds: 5));

    String token = '';
    // try {
    //   token = await CashHelper.getToken();
    // } catch (_) {
    //   If reading the token fails, treat the user as logged out.
    // }

    // The page may have been closed while we were waiting.
    if (!mounted) return;

    // pushReplacement so the user can't go back to the splash screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => token.isNotEmpty ? Bottombar() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Logo + title (centered)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppImages.Applogo,
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'اجتماع الملاك غبريال',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.tajawal(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.burgundy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer at the end of the screen
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Designed and Development PR',
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}