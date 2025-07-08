import 'package:flutter/material.dart';
import '../../models/qr_create_data.dart';
import '../../models/qr_decoration_settings.dart';
import '../../widgets/qr_preview_widget.dart';
import '../../utils/qr_capture_util.dart';
import '../../utils/app_colors.dart';

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
          // 背景（上部グラデーション + 下部背景色）
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 32,
                    width: double.infinity,
                    color: AppColors.background,
                  ),
                  Container(
                    height: gradientHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors:
                            isDark
                                ? [Color(0xFF444444), Color(0xFF222222)]
                                : [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                top: 32 + gradientHeight,
                child: Container(color: AppColors.background),
              ),
            ],
          ),

          // QRコードプレビュー本体
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Expanded(
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
                ],
              ),
            ),
          ),
        ],
      ),

      // ボタン群（SnackBarと被らないよう bottomNavigationBar に配置）
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
                      SnackBar(
                        content: Text("Saved: $path"),
                        //behavior: SnackBarBehavior.floating,
                        //margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Save failed: $e"),
                        //behavior: SnackBarBehavior.floating,
                        //margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            buildMainButton(
              icon: Icons.share,
              label: "Share",
              onPressed: () {
                // TODO: Share implementation
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.home, color: Colors.black),
                label: const Text(
                  "Back to Home",
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
