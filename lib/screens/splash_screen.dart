import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _exit;
  late final Animation<double> _logoScale, _logoOpacity, _textOpacity, _exitOpacity;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _logoScale = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entry, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entry, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    _exit = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _exit, curve: Curves.easeInOut));

    _entry.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      _exit.forward().then((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      });
    });
  }

  @override
  void dispose() { _entry.dispose(); _exit.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: AppBackground(
        child: FadeTransition(
          opacity: _exitOpacity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBlue.withValues(alpha: 0.2),
                            blurRadius: 50,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    'Reminder App',
                    style: tt.headlineMedium?.copyWith(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    'NEVER MISS A MOMENT',
                    style: tt.labelSmall?.copyWith(
                      letterSpacing: 2.0,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
