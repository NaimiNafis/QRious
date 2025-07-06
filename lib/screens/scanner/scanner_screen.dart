import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import 'scanner_controller.dart';
import 'scanner_view.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late MobileScannerController controller;
  bool isFlashlightOn = false;
  bool isQrMode = true; // true for QR, false for barcode
  bool isScanning = true;
  bool _isInitialized = false;
  
  // Controller
  late ScannerController _scannerController;

  @override
  bool get wantKeepAlive => true; // Keep this screen alive

  @override
  void initState() {
    super.initState();
    
    // Initialize controller with all formats
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
    
    // Register this object as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Allow the frame to be drawn before initializing camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scannerController = ScannerController(
      context: context,
      historyProvider: Provider.of<HistoryProvider>(context, listen: false),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else if (state == AppLifecycleState.paused) {
      controller.stop();
    }
  }
  
  void _setFlashlight(bool value) {
    setState(() {
      isFlashlightOn = value;
    });
  }
  
  void _setScanMode(bool value) {
    setState(() {
      isQrMode = value;
    });
  }
  
  void _setScanning(bool value) {
    setState(() {
      isScanning = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Scan', style: TextStyle(color: AppColors.textLight)),
        automaticallyImplyLeading: false, // Prevent automatic back button
        actions: [
          IconButton(
            color: AppColors.textLight,
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner view with frame
          Expanded(
            child: ScannerView(
              controller: controller,
              isInitialized: _isInitialized,
              isFlashlightOn: isFlashlightOn,
              isQrMode: isQrMode,
              isScanning: isScanning,
              onFlashToggle: _setFlashlight,
              onModeToggle: _setScanMode,
              onDetect: (capture) {
                // Use an async wrapper to handle the Future
                () async {
                  await _scannerController.handleBarcodeDetection(
                    capture, 
                    isQrMode, 
                    isScanning, 
                    _setScanning,
                  );
                }();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // Clean up observers and controller
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }
} 