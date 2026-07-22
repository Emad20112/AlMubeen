import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/screens/contact_style_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdhkarDuaHubScreen extends StatelessWidget {
  const AdhkarDuaHubScreen({super.key});

  static const String routePath = '/adhkar-duas';

  @override
  Widget build(BuildContext context) {
    return ContactStyleMenuScreen(
      title: 'الأذكار والأدعية',
      subtitle: 'اختر ما تريد قراءته من الأذكار أو الأدعية.',
      icon: Icons.favorite_rounded,
      sections: [
        ContactStyleMenuSection(
          items: [
            ContactStyleMenuItem(
              icon: Icons.brightness_5_rounded,
              title: 'الأذكار',
              subtitle: 'أذكار الصباح والمساء واليوم والليلة.',
              accentColor: AppColors.maroon800,
              onTap: () => context.push('/adhkar'),
            ),
            ContactStyleMenuItem(
              icon: Icons.volunteer_activism_rounded,
              title: 'الأدعية',
              subtitle: 'أدعية مختارة بتصنيفات واضحة.',
              accentColor: const Color(0xFF2E6E6A),
              onTap: () => context.push('/duas'),
            ),
          ],
        ),
      ],
    );
  }
}
