import 'package:flutter/material.dart';
import '../../models/qr_create_data.dart';
import '../../models/qr_decoration_settings.dart';
import '../../widgets/qr_preview_widget.dart';
import '../../utils/qr_capture_util.dart';
import '../../utils/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class QrDecorateResultScreen extends StatelessWidget {
  final QrCreateData qrData;
  final QrDecorationSettings decorationSettings;

  QrDecorateResultScreen({
    super.key,
    required this.qrData,
    required this.decorationSettings,
  });

  final GlobalKey _previewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final gradientHeight = screenHeight * 0.65;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.textLight),
        title: Text(
          "Customized QR Preview",
          style: TextStyle(color: AppColors.textLight),
        ),
      ),
      body: Stack(
        children: [
      // 背景全体にグラデーションを適用
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
              ? [Color(0xFF444444), Color(0xFF222222)]
              : [Colors.grey.shade300, Colors.grey.shade400],
          ),
        ),
      ),

          // QRコードプレビュー本体とスクロール対応
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                height: gradientHeight, // 高さを指定して余白確保
                child: Center(
                  child: RepaintBoundary(
                    key: _previewKey,
                    child: QrPreviewWidget(
                      qrData: qrData,
                      settings: decorationSettings,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMainButton(
              icon: Icons.save_alt,
              label: "Save as Image",
              onPressed: () async {
                try {
                  final path = await captureAndSave(_previewKey);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Saved: $path")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Save failed: $e")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            buildMainButton(
              icon: Icons.share,
              label: "Share",
              onPressed: () async {
                try {
                  // Capture the QR code as an image
                  final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
                  if (boundary == null) {
                    throw Exception("RepaintBoundary not found");
                  }

                  final image = await boundary.toImage(pixelRatio: 3.0);
                  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                  if (byteData == null) {
                    throw Exception("Failed to get byte data");
                  }
                  
                  final pngBytes = byteData.buffer.asUint8List();
                  
                  // Create a temporary file
                  final tempDir = await getTemporaryDirectory();
                  final file = File('${tempDir.path}/qr_decorated_${DateTime.now().millisecondsSinceEpoch}.png');
                  await file.writeAsBytes(pngBytes);
                  
                  // Share the file
                  await SharePlus.instance.share(
                    ShareParams(
                      text: 'Check out this customized QR code for: ${qrData.content}',
                      files: [XFile(file.path)],
                    ),
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("QR code shared successfully")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Share failed: $e")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text(
                  "Back to Top",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide.none,
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: AppColors.textLight),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
