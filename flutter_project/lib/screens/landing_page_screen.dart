import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../main.dart';

class LandingPageScreen extends StatelessWidget {
  const LandingPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Title
                  Text(
                    'Meditation Course on the Six Senses',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: isDarkMode 
                          ? const Color(0xFF96c5a9) // Dark mode primary color
                          : const Color(0xFF366348), // Light mode primary color
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Subtitle
                  Text(
                    'A comprehensive guide to developing calm and insight through sense experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: isDarkMode
                          ? const Color(0xFFe0e0e0) // Dark mode text color
                          : const Color(0xFF212121), // Light mode text color
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Navigation buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to lessons screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LessonScreenWrapper(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}