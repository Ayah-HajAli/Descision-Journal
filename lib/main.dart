import 'package:flutter/material.dart';
import 'data/store.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DecisionJournalApp());
}

enum _AppStage { splash, onboarding, home }

class DecisionJournalApp extends StatefulWidget {
  const DecisionJournalApp({super.key});

  @override
  State<DecisionJournalApp> createState() => _DecisionJournalAppState();
}

class _DecisionJournalAppState extends State<DecisionJournalApp> {
  final DecisionStore _store = DecisionStore();
  _AppStage _stage = _AppStage.splash;

  void _finishSplash() {
    setState(() {
      _stage = _store.hasOnboarded ? _AppStage.home : _AppStage.onboarding;
    });
  }

  void _finishOnboarding() {
    _store.completeOnboarding();
    setState(() => _stage = _AppStage.home);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decision Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            child: _buildStage(),
          );
        },
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _AppStage.splash:
        return SplashScreen(key: const ValueKey('splash'), onFinished: _finishSplash);
      case _AppStage.onboarding:
        return OnboardingScreen(key: const ValueKey('onboarding'), onDone: _finishOnboarding);
      case _AppStage.home:
        return HomeScreen(key: const ValueKey('home'), store: _store);
    }
  }
}
