import 'dart:async';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  final StorageService _storageService = StorageService();

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'مرحباً بك في دواؤك',
      'body': 'رفيقك الأمثل لتنظيم مواعيد أدويتك والحفاظ على صحتك.',
      'icon': Icons.health_and_safety,
      'color': Colors.teal,
    },
    {
      'title': 'أضف أدويتك بسهولة',
      'body': 'اضغط على الزر (+) لإضافة دواء جديد، حدد الجرعة والمواعيد بدقة.',
      'icon': Icons.add_circle,
      'color': Colors.orange,
    },
    {
      'title': 'تنبيهات ذكية',
      'body': 'لن تفوتك جرعة بعد الآن. سنقوم بتذكيرك في الوقت المحدد.',
      'icon': Icons.notifications_active,
      'color': Colors.blue,
    },
    {
      'title': 'ملفات متعددة',
      'body': 'يمكنك إدارة أدوية جميع أفراد عائلتك من مكان واحد.',
      'icon': Icons.people,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _pages.length - 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      } else {
        _finishOnboarding();
      }
    });
  }

  void _finishOnboarding() async {
    _timer?.cancel();
    await _storageService.setSeenOnboarding(true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: (page['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(page['icon'], size: 100, color: page['color']),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      page['title'],
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page['body'],
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left:
                16, // RTL: left is typically logic-start, but strictly "Skip" usually is on the opposing side of logical start if we want it to feel like "Exit".
            // In layoutDirection RTL, 'left' is physically left.
            child: TextButton(
              onPressed: _finishOnboarding,
              child: const Text('تخطي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // Progress Indicator
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.teal
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
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
