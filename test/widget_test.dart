import 'package:al_mubeen/app/bootstrap/app_bootstrap.dart';
import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _InMemoryPreferencesStore extends AppUserPreferencesStore {
  _InMemoryPreferencesStore() : super();
}

void main() {
  testWidgets('shows onboarding screen for first-time users', (tester) async {
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
          home: const AppBootstrap(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('التالي', skipOffstage: false), findsWidgets);
  });
}
