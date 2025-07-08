import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_create_data.dart';
import '../../utils/app_colors.dart';
import 'qr_decorate_screen.dart';
import '../../utils/qr_capture_util.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class QrResultScreen extends StatelessWidget {
  final QrCreateData qrData;
  final GlobalKey _previewKey = GlobalKey();

  QrResultScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "QR Code Generated",
          style: TextStyle(color: AppColors.textLight),
        ),
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  key: _previewKey,
                  child: QrImageView(
                    data: qrData.content,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Type: ${qrData.type}",
                  style: TextStyle(color: AppColors.textDark, fontSize: 16),
                ),
                Text(
                  "Content: ${qrData.content}",
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: Icon(Icons.brush, color: AppColors.textLight),
                label: Text(
                  "Customize",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lime.shade600,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrDecorateScreen(qrData: qrData),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save_alt, color: AppColors.textLight),
                label: Text(
                  "Save Image",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: Icon(Icons.share, color: AppColors.textLight),
                label: Text(
                  "Share",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                    final file = File('${tempDir.path}/qr_share_${DateTime.now().millisecondsSinceEpoch}.png');
                    await file.writeAsBytes(pngBytes);
                    
                    // Share the file
                    await SharePlus.instance.share(
                      ShareParams(
                        text: 'Check out this QR code for: ${qrData.content}',
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
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: Icon(Icons.refresh, color: Colors.black),
                label: Text(
                  "Back to Top",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
}
