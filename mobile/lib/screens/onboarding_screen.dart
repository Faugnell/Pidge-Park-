import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.isFrench,
    required this.allowDismiss,
    required this.onComplete,
    super.key,
  });

  final bool isFrench;
  final bool allowDismiss;
  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _icons = <IconData>[
    Icons.park_outlined,
    Icons.restaurant,
    Icons.schedule,
    Icons.menu_book_outlined,
    Icons.calendar_today_outlined,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(widget.isFrench);
    final isLastPage = _currentPage == pages.length - 1;
    return PopScope(
      canPop: widget.allowDismiss,
      child: Scaffold(
        key: const ValueKey('onboarding-screen'),
        backgroundColor: AppColors.splashBackground,
        appBar: AppBar(
          automaticallyImplyLeading: widget.allowDismiss,
          backgroundColor: Colors.transparent,
          actions: [
            if (!isLastPage)
              TextButton(
                key: const ValueKey('skip-onboarding'),
                onPressed: _finish,
                child: Text(widget.isFrench ? 'Passer' : 'Skip'),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  key: const ValueKey('onboarding-pages'),
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.park,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCDBE9D),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _icons[index],
                            size: 72,
                            color: AppColors.selected,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          pages[index].title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pages[index].body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? AppColors.selected
                          : const Color(0xFFD8C9AA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: ValueKey(
                      isLastPage ? 'finish-onboarding' : 'next-onboarding',
                    ),
                    onPressed: isLastPage
                        ? _finish
                        : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                    child: Text(
                      isLastPage
                          ? (widget.isFrench ? 'Jouer !' : 'Play!')
                          : (widget.isFrench ? 'Suivant' : 'Next'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await widget.onComplete();
    if (mounted) Navigator.pop(context);
  }
}

class _OnboardingPage {
  const _OnboardingPage(this.title, this.body);
  final String title;
  final String body;
}

List<_OnboardingPage> _pages(bool isFrench) => isFrench
    ? const [
        _OnboardingPage(
          'Bienvenue à Pidge Park !',
          'Ce petit coin de ville ne demande qu’à prendre vie… et les pigeons ne sont jamais bien loin.',
        ),
        _OnboardingPage(
          'Un petit creux ?',
          'Dépose quelque chose à manger dans le parc. Selon ce que tu choisis, tu pourrais attirer de nouveaux visiteurs.',
        ),
        _OnboardingPage(
          'Ils arrivent à leur rythme',
          'Laisse-leur un peu de temps pour trouver le chemin du parc. Si tu veux, on te préviendra dès qu’ils seront là.',
        ),
        _OnboardingPage(
          'Fais connaissance',
          'Chaque pigeon a son caractère, ses goûts et ses petites habitudes. Retrouve toutes tes rencontres dans le Pigeondex.',
        ),
        _OnboardingPage(
          'À demain ?',
          'De nouvelles missions et quelques miettes t’attendent chaque jour. De quoi prendre soin de toute la bande !',
        ),
      ]
    : const [
        _OnboardingPage(
          'Welcome to Pidge Park!',
          'This little corner of the city is waiting to come alive… and the pigeons are never far away.',
        ),
        _OnboardingPage(
          'Feeling peckish?',
          'Leave something tasty in the park. What you choose might attract some brand-new visitors.',
        ),
        _OnboardingPage(
          'They’ll come in their own time',
          'Give them a little while to find their way. If you like, we’ll let you know as soon as they arrive.',
        ),
        _OnboardingPage(
          'Get to know them',
          'Every pigeon has a personality, favourite things and funny little habits. Find all your new friends in the Pigeondex.',
        ),
        _OnboardingPage(
          'See you tomorrow?',
          'Fresh missions and a few free crumbs are waiting every day—just what you need to look after the whole flock!',
        ),
      ];
