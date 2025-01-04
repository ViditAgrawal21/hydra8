import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:my_app/screens/setup_screen.dart';
import 'package:my_app/screens/start_screen.dart';

class StartupNavigation extends StatefulWidget {
  static const routeName = "/startup-navigation";
  const StartupNavigation({super.key});

  @override
  State<StartupNavigation> createState() => _StartupNavigationState();
}

class _StartupNavigationState extends State<StartupNavigation> {
  PageController pageController = PageController();

  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      floatingActionButton: SmoothPageIndicator(
        controller: pageController, // PageController
        count: 2,
        effect: ScrollingDotsEffect(
            dotColor:
                isDarkTheme ? const Color(0xff454545) : const Color(0xffC5C5C5),
            dotWidth: 10,
            dotHeight: 10,
            activeDotColor:
                Theme.of(context).primaryColor), // your preferred effect
        onDotClicked: (index) {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            StartScreen((int index) => pageController.animateToPage(index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut)),
            const SetupScreen(),
          ]),
    );
  }
}
