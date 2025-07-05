import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/url_safety_util.dart';

class SafetyIndicator extends StatefulWidget {
  final String content;
  final String type;
  
  const SafetyIndicator({
    super.key,
    required this.content,
    required this.type,
  });

  @override
  State<SafetyIndicator> createState() => _SafetyIndicatorState();
}

class _SafetyIndicatorState extends State<SafetyIndicator> {
  bool _isLoading = true;
  bool _isSafe = true;
  String _reason = '';

  @override
  void initState() {
    super.initState();
    _checkSafety();
  }

  Future<void> _checkSafety() async {
    // Only URLs need safety checks
    if (widget.type != 'URL') {
      setState(() {
        _isLoading = false;
        _isSafe = true;
        _reason = 'Non-URL content';
      });
      return;
    }

    try {
      // Use our URL safety utility
      final result = await UrlSafetyUtil.checkUrlWithApi(widget.content);
      
      setState(() {
        _isLoading = false;
        _isSafe = result['isSafe'] ?? false;
        _reason = result['reason'] ?? 'Unknown';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSafe = false;
        _reason = 'Error checking safety: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Show loading indicator while checking
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: AppColors.primary.withValues(alpha: 255 * 0.05),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Checking URL safety...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Safety indicator based on result
    final color = _isSafe ? AppColors.success : AppColors.danger;
    final icon = _isSafe ? Icons.check : Icons.warning;
    final message = _isSafe 
        ? 'This link appears safe to open!'
        : 'This link might be unsafe: $_reason';
    
    // Use a lighter background for unsafe warning in light mode
    final backgroundColor = _isSafe 
        ? color.withValues(alpha: 255 * 0.05)
        : !_isSafe && !isDarkMode
          ? const Color(0xFFFFEBEE) // Light red background
          : color.withValues(alpha: 255 * 0.05);

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(15),
        color: backgroundColor,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 