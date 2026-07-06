import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/constants/app_assets.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _PageData {
  final IconData icon;
  final String title;
  final String description;

  const _PageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

const _pages = [
  _PageData(
    icon: Icons.menu_book_rounded,
    title: 'المصحف الشامل',
    description:
        'اقرأ القرآن الكريم كاملاً مع التفسير والترجمة بعدة لغات،'
        ' واستعرض الصفحات بسلاسة.',
  ),
  _PageData(
    icon: Icons.waving_hand_rounded,
    title: 'الأذكار اليومية',
    description:
        'مجموعة متكاملة من الأذكار الصباحية والمسائية مع عداد'
        ' تفاعلي يساعدك على المداومة.',
  ),
  _PageData(
    icon: Icons.headphones_rounded,
    title: 'الاستماع والتلاوة',
    description:
        'استمع للقرآن بأصوات أشهر القراء، واختر قارئك المفضل'
        ' واستمتع بالتلاوة.',
  ),
  _PageData(
    icon: Icons.track_changes_rounded,
    title: 'تتبّع التقدّم',
    description:
        'يواصل التطبيق قراءتك من حيث انتهيت، ويحفظ آخر موضع'
        ' لك مع إحصائيات المتابعة.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _complete() {
    ref.read(appUserPreferencesProvider.notifier).completeWelcome();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkScaffold : AppColors.parchment;
    final accentColor = isDark ? AppColors.parchmentMuted : AppColors.maroon800;
    final isLastPage = _currentPage == _pages.length - 1;
    final isFirstPage = _currentPage == 0;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  if (!isFirstPage)
                    TextButton.icon(
                      onPressed: _goPrevious,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('السابق'),
                      style: TextButton.styleFrom(foregroundColor: accentColor),
                    )
                  else
                    const SizedBox(width: 72),
                  const Spacer(),
                  TextButton(
                    onPressed: _complete,
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: accentColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _PageContent(page: _pages[i]),
              ),
            ),
            _BottomBar(
              count: _pages.length,
              current: _currentPage,
              isLastPage: isLastPage,
              isDark: isDark,
              accentColor: accentColor,
              onNext: _goNext,
              onComplete: _complete,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _PageData page;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkInk : AppColors.ink;
    final accentColor = isDark ? AppColors.parchmentMuted : AppColors.maroon800;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(page.icon, color: accentColor, size: 44),
            ),
            const SizedBox(height: 32),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: fgColor,
                fontFamily: 'DiwaniBent',
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            SvgPicture.asset(
              AppAssets.decorativeDivider,
              width: 120,
              colorFilter: ColorFilter.mode(
                accentColor.withValues(alpha: 0.3),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: fgColor.withValues(alpha: 0.8),
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.count,
    required this.current,
    required this.isLastPage,
    required this.isDark,
    required this.accentColor,
    required this.onNext,
    required this.onComplete,
  });

  final int count;
  final int current;
  final bool isLastPage;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageIndicator(count: count, current: current, accentColor: accentColor),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: isLastPage
                ? FilledButton(
                    onPressed: onComplete,
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor:
                          isDark ? AppColors.darkScaffold : AppColors.parchmentLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('ابدأ الرحلة'),
                  )
                : OutlinedButton(
                    onPressed: onNext,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('التالي'),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios, size: 15),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.current,
    required this.accentColor,
  });

  final int count;
  final int current;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? accentColor : accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
