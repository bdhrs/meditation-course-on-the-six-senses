import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThreePaneAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onMenuPressed;
  final VoidCallback onSettingsPressed;

  const ThreePaneAppBar({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.onMenuPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode
        ? const Color(0xFF96C5A9) // darkPrimaryColor
        : const Color(0xFF366348); // lightPrimaryColor

    return AppBar(
      title: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/six-senses.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          // Full course title
          const Expanded(
            child: Text(
              'Meditation Course on the Six Senses',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      leading: isMobile || isTablet
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
            )
          : null,
      actions: [
        // Dark mode toggle
        IconButton(
          icon: themeProvider.isDarkMode
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  child: Image.asset('assets/images/theme-icon.png',
                      width: 24, height: 24),
                )
              : ColorFiltered(
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  child: Image.asset('assets/images/theme-icon-moon.png',
                      width: 24, height: 24),
                ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
        // Online/Offline toggle (placeholder)
        IconButton(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            child: Image.asset('assets/images/status-icon.png',
                width: 24, height: 24),
          ),
          onPressed: () {
            // Placeholder for connectivity toggle
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
