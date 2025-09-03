import 'package:flutter/material.dart';

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
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
