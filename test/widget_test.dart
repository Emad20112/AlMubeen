import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/home/presentation/home_page.dart';
import 'package:al_mubeen/features/onboarding/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _InMemoryPreferencesStore extends AppUserPreferencesStore {
  AppUserPreferences _preferences = const AppUserPreferences.initial();

  @override
  Future<AppUserPreferences> read() async {
    return _preferences;
  }

  @override
  Future<void> write(AppUserPreferences preferences) async {
    _preferences = preferences;
  }
}

void main() {
  testWidgets('home page shows welcome for first-time users', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appUserPreferencesStoreProvider.overrideWithValue(
            _InMemoryPreferencesStore(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('ابدأ الآن', skipOffstage: false), findsOneWidget);
  });
}
