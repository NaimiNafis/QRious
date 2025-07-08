import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

Future<String> captureAndSave(GlobalKey repaintKey) async {
  try {
    final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception("RepaintBoundary not found");
    }

    final context = repaintKey.currentContext;
    final pixelRatio = context != null ? MediaQuery.of(context).devicePixelRatio : 1.0;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception("Failed to get byte data");
    }

    final pngBytes = byteData.buffer.asUint8List();

    // Request permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception("Permission denied");
    }

    // Save to gallery
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(pngBytes),
      quality: 100,
      name: 'qr_capture_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (result == null || result['isSuccess'] != true) {
      throw Exception("Failed to save image");
    }

    // ✅ ここでパスを取得して返す
    final path = result['filePath'] ?? 'unknown';
    return path;

  } catch (e) {
    //print("Error: $e");
    rethrow;
  }
}
