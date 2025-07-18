//import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

Future<String> captureAndSave(GlobalKey repaintKey) async {
  try {
    // 描画オブジェクトの取得
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception("RepaintBoundary not found");

    final context = repaintKey.currentContext;
    final pixelRatio =
        context != null ? MediaQuery.of(context).devicePixelRatio : 3.0;

    // 画像としてキャプチャ
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception("Failed to get byte data");

    final pngBytes = byteData.buffer.asUint8List();

    // パーミッション要求（Android）
    //final status = await Permission.storage.request();
    //if (!status.isGranted) throw Exception("Storage permission denied");
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      final media = await Permission.mediaLibrary.request();
      if (photos.isDenied && media.isDenied) {
        throw Exception("Storage permission denied");
      }
    } else {
      if (!await Permission.storage.request().isGranted) {
        throw Exception("Storage permission denied");
      }
    }

    // 一時ファイルにPNG保存
    final tempDir = await getTemporaryDirectory();
    final fileName = 'qr_capture_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pngBytes);

    // ギャラリーに保存（ファイルとして）
    final result = await ImageGallerySaverPlus.saveFile(file.path);
    if (result == null || result['isSuccess'] != true) {
      throw Exception("Failed to save image");
    }

    return result['filePath'] ?? 'unknown';
  } catch (e) {
    rethrow;
  }
}
