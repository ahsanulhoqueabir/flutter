import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../onboarding_provider.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

// Replace with your product's story.
const _pages = [
  _Page(Icons.rocket_launch_rounded, 'Welcome', 'Everything you need, in one simple place.'),
  _Page(Icons.bolt_rounded, 'Fast by design', 'Your content loads quickly and stays up to date.'),
  _Page(Icons.shield_rounded, 'Yours and secure', 'Your account and data stay under your control.'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The router redirects as soon as this completes.
  void _finish() => ref.read(onboardingSeenProvider.notifier).complete();

  void _next() {
    if (_isLast) return _finish();
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Visibility.maintain(
                  visible: !_isLast,
                  child: TextButton(onPressed: _finish, child: const Text('Skip')),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardingPage(page: _pages[i]),
              ),
            ),
            _Dots(count: _pages.length, index: _index),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Breakpoints.formMaxWidth),
                child: AppButton(label: _isLast ? 'Get started' : 'Next', onPressed: _next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: AppSpacing.screen,
      child: Column(
        children: [
          const Gap(AppSpacing.xl),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primaryContainer, colors.tertiaryContainer],
              ),
            ),
            child: Icon(page.icon, size: 84, color: colors.primary),
          ),
          const Gap(AppSpacing.xl),
          Text(page.title, textAlign: TextAlign.center, style: context.textTheme.headlineMedium),
          const Gap(AppSpacing.sm),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? colors.primary : colors.outlineVariant,
                borderRadius: AppRadius.smAll,
              ),
            ),
        ],
      ),
    );
  }
}
