import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
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
    final colors = context.semanticColors;
    final isLastPage = _currentPage == _pages.length - 1;
    final isFirstPage = _currentPage == 0;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  if (!isFirstPage)
                    TextButton.icon(
                      onPressed: _goPrevious,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('السابق'),
                      style: TextButton.styleFrom(foregroundColor: colors.primaryStrong),
                    )
                  else
                    const SizedBox(width: 72),
                  const Spacer(),
                  TextButton(
                    onPressed: _complete,
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: colors.textTertiary,
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
    final colors = context.semanticColors;
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.primaryStrong.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: Icon(page.icon, color: colors.primaryStrong, size: 44),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SvgPicture.asset(
              AppAssets.decorativeDivider,
              width: 120,
              colorFilter: ColorFilter.mode(
                colors.primaryStrong.withValues(alpha: 0.3),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
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
    required this.onNext,
    required this.onComplete,
  });

  final int count;
  final int current;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageIndicator(
            count: count,
            current: current,
            activeColor: colors.primaryStrong,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: isLastPage
                ? FilledButton(
                    onPressed: onComplete,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primaryStrong,
                      foregroundColor: colors.onPrimaryStrong,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
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
                      foregroundColor: colors.primaryStrong,
                      side: BorderSide(
                        color: colors.borderStrong,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
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
    required this.activeColor,
  });

  final int count;
  final int current;
  final Color activeColor;

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
            color: active ? activeColor : activeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadii.xs),
          ),
        );
      }),
    );
  }
}
