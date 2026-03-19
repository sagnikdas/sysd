import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../providers/user_prefs_provider.dart';
import 'widgets/goal_picker.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;
  int _selectedGoal = 10;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    FocusScope.of(context).unfocus();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    final prefsNotifier = ref.read(userPrefsProvider.notifier);
    prefsNotifier.setDisplayName(_nameController.text);
    prefsNotifier.setDailyGoal(_selectedGoal);
    prefsNotifier.ensureJoinDateRecorded();

    if (!mounted) return;
    context.go('/home');
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                children: [
                  _WelcomePage(
                    nameController: _nameController,
                    theme: theme,
                  ),
                  _HowItWorksPage(theme: theme),
                  _GoalPage(
                    theme: theme,
                    selectedGoal: _selectedGoal,
                    onGoalChanged: (g) => setState(() => _selectedGoal = g),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 10,
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 2 ? 'Start Learning' : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final TextEditingController nameController;
  final ThemeData theme;

  const _WelcomePage({required this.nameController, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.architecture,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'SysDesign Flash',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Master system design visually',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Your name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HowItWorksPage extends StatelessWidget {
  final ThemeData theme;

  const _HowItWorksPage({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _SwipeDemoIllustration(theme: theme),
          const SizedBox(height: 28),
          Text(
            'How it works',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _InstructionRow(
            icon: Icons.arrow_forward,
            color: Colors.green,
            text: 'Swipe right — Got it!',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InstructionRow(
            icon: Icons.arrow_back,
            color: Colors.orange,
            text: 'Swipe left — Review again',
            theme: theme,
          ),
          const SizedBox(height: 28),
          Text(
            'Each card has 3 tabs:\nDiagram · Key Points · Interview Q&A',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeDemoIllustration extends StatelessWidget {
  final ThemeData theme;

  const _SwipeDemoIllustration({required this.theme});

  @override
  Widget build(BuildContext context) {
    final c = theme.colorScheme;
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24,
            child: Icon(Icons.arrow_back, color: c.outline, size: 28),
          ),
          Positioned(
            right: 24,
            child: Icon(Icons.arrow_forward, color: c.outline, size: 28),
          ),
          Transform.rotate(
            angle: -0.06,
            child: Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: c.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: c.shadow.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.layers_outlined, size: 40, color: c.primary),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(28, 8),
            child: Transform.rotate(
              angle: 0.04,
              child: Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: c.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                ),
                child: Center(
                  child: Icon(
                    Icons.swipe,
                    size: 36,
                    color: c.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final ThemeData theme;

  const _InstructionRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _GoalPage extends StatelessWidget {
  final ThemeData theme;
  final int selectedGoal;
  final ValueChanged<int> onGoalChanged;

  const _GoalPage({
    required this.theme,
    required this.selectedGoal,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.flag_outlined,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Set your goal',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How many cards do you want to study per day?',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          GoalPicker(
            selectedGoal: selectedGoal,
            onChanged: onGoalChanged,
          ),
        ],
      ),
    );
  }
}
