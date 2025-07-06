import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/history_provider.dart';
import '../../screens/result/result_screen.dart';
import '../../utils/url_safety_util.dart';

class ScannerController {
  final BuildContext context;
  final HistoryProvider historyProvider;
  
  ScannerController({
    required this.context, 
    required this.historyProvider,
  });
  
  // Filter barcodes based on selected mode
  bool shouldProcessBarcode(Barcode barcode, bool isQrMode) {
    if (isQrMode) {
      return barcode.format == BarcodeFormat.qrCode;
    } else {
      return barcode.format != BarcodeFormat.qrCode;
    }
  }
  
  // Handle barcode detection
  Future<void> handleBarcodeDetection(
    BarcodeCapture capture, 
    bool isQrMode, 
    bool isScanning,
    Function(bool) setScanning,
  ) async {
    final List<Barcode> barcodes = capture.barcodes;
    
    // Filter barcodes based on selected mode
    final matchingBarcodes = barcodes.where((barcode) => shouldProcessBarcode(barcode, isQrMode)).toList();
    
    if (matchingBarcodes.isNotEmpty && isScanning) {
      // Stop scanning temporarily to prevent multiple scans
      setScanning(false);
      
      final String code = matchingBarcodes.first.rawValue ?? '';
      
      // Determine the type based on content heuristics
      String type = determineContentType(code);
      
      // Check safety for URLs
      bool isSafe = true;
      if (type == 'URL') {
        final safetyResult = await UrlSafetyUtil.checkUrlWithApi(code);
        isSafe = safetyResult['isSafe'] ?? true;
      }
      
      // Add to history
      historyProvider.addQRCode(code, type, isSafe: isSafe);
      
      // Navigate to results screen
      if (!context.mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            content: code,
            type: type,
            isSafe: isSafe,
          ),
        ),
      ).then((_) {
        // Resume scanning when returning from result screen
        setScanning(true);
      });
    }
  }
  
  // Helper method to determine content type
  String determineContentType(String content) {
    content = content.toLowerCase();
    
    if (content.startsWith('http://') || content.startsWith('https://')) {
      return 'URL';
    } else if (content.contains('ssid') || content.contains('wifi')) {
      return 'WI-FI';
    } else if (content.contains('tel:') || content.contains('contact')) {
      return 'CONTACTS';
    } else if (content.length >= 8 && content.length <= 14 && num.tryParse(content.replaceAll(RegExp(r'[^0-9]'), '')) != null) {
      return 'PRODUCT';
    }
    
    return 'Text';
  }
} 