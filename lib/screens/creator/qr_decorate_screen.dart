import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_create_data.dart';
import '../../models/qr_decoration_settings.dart';
import 'color_selector.dart';
import 'qr_decorate_result_screen.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';

class QrDecorateScreen extends StatefulWidget {
  final QrCreateData qrData;

  const QrDecorateScreen({super.key, required this.qrData});

  @override
  State<QrDecorateScreen> createState() => _QrDecorateScreenState();
}

class _QrDecorateScreenState extends State<QrDecorateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Color foregroundColor = Colors.black;
  Color backgroundColor = Colors.white;

  String selectedPixelShape = 'square';
  String backgroundStyle = "normal";

  IconData? _selectedIcon;
  Color selectedIconColor = Colors.black;
  Color selectedIconBackgroundColor = Colors.white;
  File? _selectedImage;

  String? topText;
  String? bottomText;
  late TextEditingController _topTextController;
  late TextEditingController _bottomTextController;
  String _tempTopText = "";
  String _tempBottomText = "";

  TextStyle topLabelStyle = const TextStyle(fontSize: 16, color: Colors.black);
  String selectedTopFont = 'Roboto';
  TextStyle bottomLabelStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
  String selectedBottomFont = 'Roboto';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _topTextController = TextEditingController(text: topText ?? "");
    _bottomTextController = TextEditingController(text: bottomText ?? "");

    _tempTopText = topText ?? "";
    _tempBottomText = bottomText ?? "";
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topTextController.dispose();
    _bottomTextController.dispose();
    super.dispose();
  }

  final List<Tab> _tabs = const [
    Tab(text: "コード"),
    Tab(text: "背景"),
    Tab(text: "アイコン"), //元"中央"
    Tab(text: "ラベル"), //元"文字"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "QR Customize",
          style: TextStyle(color: AppColors.textLight),
        ),
        iconTheme: IconThemeData(color: AppColors.textLight),
        actions: [
          TextButton(
            onPressed: () {
              // 「生成」ボタンの処理
              _onSave();
            },
            child: const Text("保存", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          //const SizedBox(height: 16),
          Center(child: _buildQrPreview()),
          const SizedBox(height: 8),

          // 上段のカテゴリタブ（コード・背景・中央・文字）
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),

          // タブビュー
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCodeTab(),
                _buildBackgroundTab(),
                _buildIconTab(),
                _buildLabelTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final settings = QrDecorationSettings(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      pixelShape: selectedPixelShape,
      backgroundStyle: backgroundStyle,
      centerIcon: _selectedIcon,
      iconColor: selectedIconColor,
      iconBackgroundColor: selectedIconBackgroundColor,
      embeddedImage: _selectedImage,
      topText: topText,
      bottomText: bottomText,
      topLabelStyle: topLabelStyle,
      bottomLabelStyle: bottomLabelStyle,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QrDecorateResultScreen(
              qrData: widget.qrData,
              decorationSettings: settings,
            ),
      ),
    );
  }

  Widget _buildQrPreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    BoxDecoration decoration;

    if (backgroundStyle == 'transparent') {
      decoration = const BoxDecoration(color: Colors.transparent);
    } else if (backgroundStyle == 'rounded') {
      decoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      );
    } else if (backgroundStyle == 'gradient') {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      decoration = BoxDecoration(color: backgroundColor);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [Color(0xFF444444), Color(0xFF222222)]
                  : [Colors.grey.shade300, Colors.grey.shade400],
          stops: [0.67, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topText != null && topText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    topText!,
                    style: topLabelStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // QRコード本体（Stackで重ねる）
            Container(
              decoration: decoration,
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // QRコード本体
                    QrImageView(
                      data: widget.qrData.content,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.transparent,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      eyeStyle: QrEyeStyle(
                        eyeShape:
                            selectedPixelShape == 'circle'
                                ? QrEyeShape.circle
                                : QrEyeShape.square,
                        color: foregroundColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape:
                            selectedPixelShape == 'circle'
                                ? QrDataModuleShape.circle
                                : QrDataModuleShape.square,
                        color: foregroundColor,
                      ),
                    ),

                    // 中央のアイコン（直接表示）
                    if (_selectedImage != null)
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.file(_selectedImage!),
                        ),
                      )
                    else if (_selectedIcon != null)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedIconBackgroundColor,
                        ),
                        child: Center(
                          child: Icon(
                            _selectedIcon,
                            color: selectedIconColor,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (bottomText != null && bottomText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    bottomText!,
                    style: bottomLabelStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //コード部分のタブ
  Widget _buildCodeTab() {
    final subTabs = const [Tab(text: "Color"), Tab(text: "Pixel Shape")];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [_buildColorSettings(), _buildPixelShapeSettings()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ColorSelector(
        title: "",
        selectedColor: foregroundColor,
        onColorSelected: (color) {
          setState(() {
            foregroundColor = color;
          });
        },
      ),
    );
  }

  Widget _buildPixelShapeSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 32,
            runSpacing: 24,
            alignment: WrapAlignment.center, // 中央揃え
            children: [
              _buildPixelShapeChoice(
                label: "Square",
                value: 'square',
                isSelected: selectedPixelShape == 'square',
              ),
              _buildPixelShapeChoice(
                label: "Circle",
                value: 'circle',
                isSelected: selectedPixelShape == 'circle',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPixelShapeChoice({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPixelShape = value;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: QrImageView(
                data: "sample",
                size: 64,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(
                  eyeShape:
                      value == 'circle' ? QrEyeShape.circle : QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape:
                      value == 'circle'
                          ? QrDataModuleShape.circle
                          : QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //背景部分のタブ
  Widget _buildBackgroundTab() {
    final subTabs = const [Tab(text: "色"), Tab(text: "スタイル")];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBackgroundColorSettings(),
                _buildBackgroundStyleSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ColorSelector(
        title: "",
        selectedColor: backgroundColor,
        onColorSelected: (newColor) {
          setState(() {
            backgroundColor = newColor;
          });
        },
      ),
    );
  }

  Widget _buildBackgroundStyleSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("背景スタイルを選択"),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text("通常"),
                selected: backgroundStyle == "normal",
                onSelected: (_) {
                  setState(() => backgroundStyle = "normal");
                },
              ),
              ChoiceChip(
                label: const Text("丸形"),
                selected: backgroundStyle == "rounded",
                onSelected: (_) {
                  setState(() => backgroundStyle = "rounded");
                },
              ),
              ChoiceChip(
                label: const Text("透過"),
                selected: backgroundStyle == "transparent",
                onSelected: (_) {
                  setState(() => backgroundStyle = "transparent");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //中央部分のタブ
  Widget _buildIconTab() {
    final subTabs = const [
      Tab(text: "Icon"),
      Tab(text: "Color"),
      Tab(text: "Image"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildIconSelection(),
                _buildIconColorSelection(),
                _buildImageSelection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children:
          availableIcons.map((iconData) {
            final isSelected = _selectedIcon == iconData;
            return GestureDetector(
              onTap: () {
                _onIconSelected(isSelected ? null : iconData);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //color: selectedIconBackgroundColor,
                  color:
                      isSelected
                          ? Colors.blueAccent.withValues(
                            alpha: 51,
                          ) // 0.2 * 255 = 51
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected ? Colors.blueAccent : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  iconData,
                  size: 36,
                  color: Colors.black /*selectedIconColor*/,
                ),
              ),
            );
          }).toList(),
    );
  }

  final List<IconData> availableIcons = [
    CupertinoIcons.heart,
    CupertinoIcons.star,
    CupertinoIcons.camera,
    CupertinoIcons.person,
    CupertinoIcons.phone,
    CupertinoIcons.mail,
    CupertinoIcons.home,
    CupertinoIcons.cart,
    CupertinoIcons.location,
    CupertinoIcons.settings,
    CupertinoIcons.wifi,
    CupertinoIcons.wifi_exclamationmark,
    CupertinoIcons.link,
    CupertinoIcons.globe,
    CupertinoIcons.cloud,
    CupertinoIcons.share,

    // … 必要に応じて追加
  ];

  Future<void> _onIconSelected(IconData? iconData) async {
    setState(() {
      _selectedIcon = iconData;
      _selectedImage = null;
    });
  }

  Widget _buildIconColorSelection() {
    final subTabs = const [
      Tab(text: "Icon Color"),
      Tab(text: "Background Color"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ColorSelector(
                    title: "",
                    selectedColor: selectedIconColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedIconColor = color;
                        //_updateEmbeddedIcon();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ColorSelector(
                    title: "",
                    selectedColor: selectedIconBackgroundColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedIconBackgroundColor = color;
                        //_updateEmbeddedIcon();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _selectedIcon = null;
      });
    }
  }

  Widget _buildImageSelection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Select Image'),
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null)
            SizedBox(
              width: 150,
              height: 150,
              child: FittedBox(
                fit: BoxFit.contain, // ここで縦横比を保ったまま縮小
                child: Image.file(_selectedImage!),
              ),
            )
          else
            const Text('No image selected.'),
        ],
      ),
    );
  }

  //上下文字のタブ
  Widget _buildLabelTab() {
    final subTabs = const [Tab(text: "Top Label"), Tab(text: "Bottom Label")];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [_buildTopLabelInput(), _buildBottomLabelInput()],
            ),
          ),
        ],
      ),
    );
  }

  final availableFonts = [
    'Noto Sans JP',
    'Roboto',
    'Open Sans',
    'Kosugi Maru',
    'Shippori Mincho',
  ];

  final Map<String, TextStyle Function({double? fontSize, Color? color})>
  fontMap = {
    'Noto Sans JP': GoogleFonts.notoSansJp,
    'Roboto': GoogleFonts.roboto,
    'Open Sans': GoogleFonts.openSans,
    'Kosugi Maru': GoogleFonts.kosugiMaru,
    'Shippori Mincho': GoogleFonts.shipporiMincho,
  };

  bool showColorSettingTop = false; // 画面状態に追加（Stateに記述）
  bool showColorSettingBottom = false;

  Widget _buildTopLabelInput() {
    //_topTextController.text = topText ?? "";
    //_tempTopText = topText ?? "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 切り替えボタン
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => showColorSettingTop = false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        !showColorSettingTop ? AppColors.primary : null,
                    foregroundColor:
                        !showColorSettingTop ? Colors.white : AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text("Label Text"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => showColorSettingTop = true),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        showColorSettingTop ? AppColors.primary : null,
                    foregroundColor:
                        showColorSettingTop ? Colors.white : AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text("Font Color"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 表示切り替え：テキスト設定 or 色設定
          if (!showColorSettingTop)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Text displayed at the top (max 20 characters)"),
                TextField(
                  controller: _topTextController,
                  maxLength: 20,
                  onChanged: (value) {
                    _tempTopText = value;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 🔸 右寄せ
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          topText = _tempTopText;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          topText = null;
                          _tempTopText = "";
                          _topTextController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text("Font"),
                DropdownButton<String>(
                  value: selectedTopFont,
                  isExpanded: true,
                  items:
                      availableFonts.map((font) {
                        return DropdownMenuItem(
                          value: font,
                          child: Text(
                            font,
                            style: fontMap[font]!(fontSize: 16),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedTopFont = value;
                        topLabelStyle = fontMap[selectedTopFont]!(
                          fontSize: topLabelStyle.fontSize,
                          color: topLabelStyle.color,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                const Text("Font Size"),
                Slider(
                  value: topLabelStyle.fontSize ?? 16,
                  min: 8,
                  max: 32,
                  divisions: 24,
                  label: "${(topLabelStyle.fontSize ?? 16).round()}",
                  onChanged: (value) {
                    setState(() {
                      topLabelStyle = topLabelStyle.copyWith(fontSize: value);
                    });
                  },
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(""),
                ColorSelector(
                  title: "",
                  selectedColor: topLabelStyle.color ?? Colors.black,
                  onColorSelected: (color) {
                    setState(() {
                      topLabelStyle = topLabelStyle.copyWith(color: color);
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomLabelInput() {
    //_bottomTextController.text = bottomText ?? "";
    //_tempBottomText = bottomText ?? "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 切り替えボタン（テキスト⇔色設定）
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      () => setState(() => showColorSettingBottom = false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        !showColorSettingBottom ? AppColors.primary : null,
                    foregroundColor:
                        !showColorSettingBottom
                            ? Colors.white
                            : AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text("Label Text"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      () => setState(() => showColorSettingBottom = true),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        showColorSettingBottom ? AppColors.primary : null,
                    foregroundColor:
                        showColorSettingBottom
                            ? Colors.white
                            : AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text("Font Color"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (!showColorSettingBottom)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Text displayed at the bottom (max 20 characters)"),
                TextField(
                  controller: _bottomTextController,
                  maxLength: 20,
                  onChanged: (value) {
                    _tempBottomText = value;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          bottomText = _tempBottomText;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          bottomText = null;
                          _tempBottomText = "";
                          _bottomTextController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text("Font"),
                DropdownButton<String>(
                  value: selectedBottomFont,
                  isExpanded: true,
                  items:
                      availableFonts.map((font) {
                        return DropdownMenuItem(
                          value: font,
                          child: Text(
                            font,
                            style: fontMap[font]!(fontSize: 16),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedBottomFont = value;
                        bottomLabelStyle = fontMap[selectedBottomFont]!(
                          fontSize: bottomLabelStyle.fontSize,
                          color: bottomLabelStyle.color,
                        );
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),
                const Text("Font Size"),
                Slider(
                  value: bottomLabelStyle.fontSize ?? 16,
                  min: 8,
                  max: 32,
                  divisions: 24,
                  label: "${(bottomLabelStyle.fontSize ?? 16).round()}",
                  onChanged: (value) {
                    setState(() {
                      bottomLabelStyle = bottomLabelStyle.copyWith(
                        fontSize: value,
                      );
                    });
                  },
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(""),
                ColorSelector(
                  title: "",
                  selectedColor: bottomLabelStyle.color ?? Colors.black,
                  onColorSelected: (color) {
                    setState(() {
                      bottomLabelStyle = bottomLabelStyle.copyWith(
                        color: color,
                      );
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
