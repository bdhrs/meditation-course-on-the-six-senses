import 'package:flutter/material.dart';
import '../services/update_service.dart';

class UpdateProgressDialog extends StatefulWidget {
  final VoidCallback onUpdateComplete;

  const UpdateProgressDialog({
    super.key,
    required this.onUpdateComplete,
  });

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  double _progress = 0.0;
  String _status = 'Preparing...';
  bool _isComplete = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final updateService = UpdateService();
      await updateService.downloadUpdates((progress, status) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _status = status;
            _isComplete = progress >= 1.0;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _status = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF15271D) : Colors.white;
    final textColor = isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final primaryColor = isDarkMode ? const Color(0xFF96C5A9) : const Color(0xFF366348);

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Updating Content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            if (!_isComplete && !_hasError)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: isDarkMode ? const Color(0xFF264532) : const Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withAlpha(204),
              ),
              textAlign: TextAlign.center,
            ),
            if (_isComplete || _hasError) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (_isComplete && !_hasError) {
                    widget.onUpdateComplete();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                ),
                child: Text(_hasError ? 'Close' : 'Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
