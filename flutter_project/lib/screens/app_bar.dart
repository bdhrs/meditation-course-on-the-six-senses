import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/update_service.dart';
import '../widgets/update_progress_dialog.dart';

class ThreePaneAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onMenuPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback? onUpdateComplete;

  const ThreePaneAppBar({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.onMenuPressed,
    required this.onSettingsPressed,
    this.onUpdateComplete,
  });

  @override
  State<ThreePaneAppBar> createState() => _ThreePaneAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ThreePaneAppBarState extends State<ThreePaneAppBar> {
  bool _updateAvailable = false;
  bool _checkingForUpdates = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    if (_checkingForUpdates) return;
    
    debugPrint('AppBar: Starting update check...');
    setState(() {
      _checkingForUpdates = true;
    });

    try {
      final updateService = UpdateService();
      final hasUpdates = await updateService.checkForUpdates();
      debugPrint('AppBar: Update check complete. Has updates: $hasUpdates');
      if (mounted) {
        setState(() {
          _updateAvailable = hasUpdates;
          _checkingForUpdates = false;
        });
        debugPrint('AppBar: Update icon visible: $_updateAvailable');
      }
    } catch (e) {
      debugPrint('AppBar: Error checking for updates: $e');
      if (mounted) {
        setState(() {
          _checkingForUpdates = false;
        });
      }
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateProgressDialog(
        onUpdateComplete: () {
          setState(() {
            _updateAvailable = false;
          });
          widget.onUpdateComplete?.call();
        },
      ),
    );
  }

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
      leading: widget.isMobile || widget.isTablet
          ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenuPressed)
          : null,
      actions: [
        // Update icon (only show if updates available)
        if (_updateAvailable)
          IconButton(
            icon: Icon(
              Icons.cloud_download,
              color: iconColor,
              size: 24,
            ),
            onPressed: _showUpdateDialog,
            tooltip: 'Update available',
          ),
        // Dark mode toggle
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: iconColor,
            size: 24,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
      ],
    );
  }
}
