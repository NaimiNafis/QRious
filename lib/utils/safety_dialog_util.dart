import 'package:flutter/material.dart';
import 'app_colors.dart';

class SafetyDialogUtil {
  /// Shows a confirmation dialog when a user tries to interact with a potentially unsafe URL
  /// Returns true if the user confirms they want to proceed, false otherwise
  static Future<bool> showUnsafeUrlConfirmation({
    required BuildContext context,
    required String action, // "open", "copy", "share"
    required String url,
    required String reason,
  }) async {
    final String actionVerb = _getActionVerb(action);
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded, 
                color: AppColors.danger,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text('Security Warning'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This URL has been flagged as potentially unsafe:'),
              const SizedBox(height: 8),
              Text(
                reason,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Are you sure you want to $actionVerb:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cardBackground
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  url,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textDark),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 1.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes, $actionVerb',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
    
    // Return false if the user dismisses the dialog or presses cancel
    return result ?? false;
  }
  
  /// Converts the action type to a verb for the dialog text
  static String _getActionVerb(String action) {
    switch (action.toLowerCase()) {
      case 'open':
        return 'open this link';
      case 'copy':
        return 'copy this link';
      case 'share':
        return 'share this link';
      default:
        return 'proceed with this link';
    }
  }
} 