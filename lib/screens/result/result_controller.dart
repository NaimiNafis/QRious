import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/history_provider.dart';
import '../../models/qr_code_model.dart';
import '../../utils/url_safety_util.dart';
import '../../utils/safety_dialog_util.dart';

class ResultController {
  final BuildContext context;
  final HistoryProvider historyProvider;
  
  ResultController({
    required this.context,
    required this.historyProvider,
  });
  
  // Launch URL with safety check
  Future<void> launchURL(String url, {bool? isSafeOverride}) async {
    // Check if this URL is potentially unsafe
    bool isSafe = isSafeOverride ?? true;
    String reason = '';
    
    if (isSafeOverride == null) {
      final safetyResult = await UrlSafetyUtil.checkUrlWithApi(url);
      isSafe = safetyResult['isSafe'] ?? true;
      reason = safetyResult['reason'] ?? 'Unknown reason';
    }
    
    // Check if context is still valid
    if (!context.mounted) return;
    
    // If URL is unsafe, show confirmation dialog
    if (!isSafe) {
      final shouldProceed = await SafetyDialogUtil.showUnsafeUrlConfirmation(
        context: context,
        action: 'open',
        url: url,
        reason: reason,
      );
      
      // Check if context is still valid after awaiting dialog
      if (!context.mounted) return;
      
      if (!shouldProceed) {
        // User canceled the operation
        return;
      }
    }
    
    // Proceed with opening the URL
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this URL'),
        ),
      );
    }
  }
  
  // Copy to clipboard with safety check for URLs
  Future<void> copyToClipboard(String content, {String? type, bool? isSafeOverride}) async {
    // Check if this is a URL and potentially unsafe
    bool isSafe = isSafeOverride ?? true;
    String reason = '';
    final isURL = type == 'URL' || content.startsWith('http://') || content.startsWith('https://');
    
    if (isURL && isSafeOverride == null) {
      final safetyResult = await UrlSafetyUtil.checkUrlWithApi(content);
      isSafe = safetyResult['isSafe'] ?? true;
      reason = safetyResult['reason'] ?? 'Unknown reason';
    }
    
    // Check if context is still valid
    if (!context.mounted) return;
    
    // If URL is unsafe, show confirmation dialog
    if (isURL && !isSafe) {
      final shouldProceed = await SafetyDialogUtil.showUnsafeUrlConfirmation(
        context: context,
        action: 'copy',
        url: content,
        reason: reason,
      );
      
      // Check if context is still valid after awaiting dialog
      if (!context.mounted) return;
      
      if (!shouldProceed) {
        // User canceled the operation
        return;
      }
    }
    
    // Proceed with copying to clipboard
    await Clipboard.setData(ClipboardData(text: content));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content copied to clipboard')),
      );
    }
  }
  
  // Share content with safety check for URLs
  Future<void> shareContent(String content, {String? type, bool? isSafeOverride}) async {
    // Check if this is a URL and potentially unsafe
    bool isSafe = isSafeOverride ?? true;
    String reason = '';
    final isURL = type == 'URL' || content.startsWith('http://') || content.startsWith('https://');
    
    if (isURL && isSafeOverride == null) {
      final safetyResult = await UrlSafetyUtil.checkUrlWithApi(content);
      isSafe = safetyResult['isSafe'] ?? true;
      reason = safetyResult['reason'] ?? 'Unknown reason';
    }
    
    // Check if context is still valid
    if (!context.mounted) return;
    
    // If URL is unsafe, show confirmation dialog
    if (isURL && !isSafe) {
      final shouldProceed = await SafetyDialogUtil.showUnsafeUrlConfirmation(
        context: context,
        action: 'share',
        url: content,
        reason: reason,
      );
      
      // Check if context is still valid after awaiting dialog
      if (!context.mounted) return;
      
      if (!shouldProceed) {
        // User canceled the operation
        return;
      }
    }
    
    // Proceed with sharing content
    SharePlus.instance.share(
      ShareParams(text: content),
    );
  }
  
  // Toggle favorite status
  Future<void> toggleFavorite(int id) async {
    await historyProvider.toggleFavorite(id);
  }
  
  // Save, mark as favorite, and return the new item
  Future<QRCodeModel> saveAndGetNewItem(String content, String type) async {
    // First check if this exact content already exists in history
    await historyProvider.fetchHistory();
    QRCodeModel? existingItem;
    
    try {
      existingItem = historyProvider.history.firstWhere(
        (item) => item.content == content && item.type == type,
      );
      
      // If the item already exists, use it
      if (existingItem.id != null) {
        // Only toggle if it's not already a favorite
        if (!existingItem.isFavorite) {
          await historyProvider.toggleFavorite(existingItem.id!);
          
          // Refresh to get updated item
          await historyProvider.fetchHistory();
          return historyProvider.history.firstWhere(
            (item) => item.id == existingItem!.id,
          );
        }
        return existingItem;
      }
    } catch (e) {
      // Item doesn't exist, continue to create it
    }
    
    // Check safety for URLs before adding
    bool isSafe = true;
    if (type == 'URL') {
      final safetyResult = await UrlSafetyUtil.checkUrlWithApi(content);
      isSafe = safetyResult['isSafe'] ?? true;
    }
    
    // Add to history with safety flag
    await historyProvider.addQRCode(content, type, isSafe: isSafe);
    
    // Find the newly added code
    await historyProvider.fetchHistory();
    final newItem = historyProvider.history.firstWhere(
      (item) => item.content == content && item.type == type,
      orElse: () => throw Exception('Could not find newly added QR code'),
    );
    
    // Mark as favorite
    if (newItem.id != null) {
      await historyProvider.toggleFavorite(newItem.id!);
      
      // Refresh to get updated item
      await historyProvider.fetchHistory();
      return historyProvider.history.firstWhere(
        (item) => item.id == newItem.id,
      );
    }
    
    return newItem;
  }
  
  // Get icon for content type
  IconData getIconForType(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'WI-FI':
        return Icons.wifi;
      case 'CONTACTS':
        return Icons.person;
      case 'PRODUCT':
        return Icons.shopping_cart;
      default:
        return Icons.text_snippet;
    }
  }
  
  // Save and mark as favorite (for backward compatibility)
  Future<void> saveAndFavorite(String content, String type) async {
    await saveAndGetNewItem(content, type);
  }
} 