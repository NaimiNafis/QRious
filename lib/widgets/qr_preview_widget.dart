import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_create_data.dart';
import '../models/qr_decoration_settings.dart';

class QrPreviewWidget extends StatelessWidget {
  final QrCreateData qrData;
  final QrDecorationSettings settings;

  const QrPreviewWidget({
    super.key,
    required this.qrData,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    // 背景の装飾スタイル決定
    BoxDecoration decoration;
    if (settings.backgroundStyle == 'transparent') {
      decoration = const BoxDecoration(color: Colors.transparent);
    } else if (settings.backgroundStyle == 'rounded') {
      decoration = BoxDecoration(
        color: settings.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      );
    } else if (settings.backgroundStyle == 'gradient') {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [settings.backgroundColor, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      decoration = BoxDecoration(color: settings.backgroundColor);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 上部テキスト
        if (settings.topText != null && settings.topText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: SizedBox(
                width: 400,
                child: Text(
                  settings.topText!,
                  style: settings.topLabelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        // QRコード本体 + 中央Icon（Stackで重ねる）
        Container(
          padding: const EdgeInsets.all(16),
          decoration: decoration,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  data: qrData.content,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.transparent,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  eyeStyle: QrEyeStyle(
                    eyeShape: parseEyeShape(settings.pixelShape),
                    color: settings.foregroundColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: parseDataShape(settings.pixelShape),
                    color: settings.foregroundColor,
                  ),
                ),

                // 中央アイコン（Widgetとして重ねる）
                if (settings.embeddedImage != null)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.file(settings.embeddedImage!),
                    ),
                  )
                else if (settings.centerIcon != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: settings.iconBackgroundColor,
                    ),
                    child: Center(
                      child: Icon(
                        settings.centerIcon,
                        color: settings.iconColor,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 下部テキスト
        if (settings.bottomText != null && settings.bottomText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: SizedBox(
                width: 400,
                child: Text(
                  settings.bottomText!,
                  style: settings.bottomLabelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// ピクセル形状に対応する EyeShape を返す（仮）
  QrEyeShape parseEyeShape(String shape) {
    switch (shape) {
      case 'circle':
        return QrEyeShape.circle;
      case 'square':
      default:
        return QrEyeShape.square;
    }
  }

  /// ピクセル形状に対応する DataModuleShape を返す（仮）
  QrDataModuleShape parseDataShape(String shape) {
    switch (shape) {
      case 'circle':
        return QrDataModuleShape.circle;
      case 'square':
      default:
        return QrDataModuleShape.square;
    }
  }
}
