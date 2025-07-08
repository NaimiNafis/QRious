import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_create_data.dart';
import '../../models/qr_decoration_settings.dart';
import 'color_selector.dart';
import 'qr_decorate_result_screen.dart';
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

  final List<Tab> _tabs = [
    const Tab(icon: Icon(Icons.qr_code), text: "Code"),
    const Tab(icon: Icon(Icons.image), text: "BG Style"),
    const Tab(icon: Icon(Icons.insert_emoticon), text: "Icon"),
    const Tab(icon: Icon(Icons.title), text: "Label"),
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
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: TextButton.icon(
              onPressed: _onSave,
              icon: Icon(Icons.visibility, color: AppColors.textLight),
              label: Text(
                "Preview",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final tabBarHeight = 48.0; // タブバー高さの目安
          final previewHeight = totalHeight * 0.35;

          return Column(
            children: [
              // プレビュー：高さ最大 previewHeight でスクロール可能に
              SizedBox(
                height: previewHeight,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Center(child: _buildQrPreview()),
                ),
              ),

              // タブバー（スクリーン幅いっぱいに）
              SizedBox(
                height: tabBarHeight,
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                  ),
                ),
              ),

              // 残りはタブビューで埋める
              Expanded(
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
          );
        },
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
      embeddedImage: _isImageVisible ? _selectedImage : null,
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
                  child: SizedBox(
                    width: 400,
                    child: Text(
                      topText!,
                      style: topLabelStyle,
                      textAlign: TextAlign.center,
                    ),
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
                    if (_selectedImage != null && _isImageVisible != false)
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
                  child: SizedBox(
                    width: 400,
                    child: Text(
                      bottomText!,
                      style: bottomLabelStyle,
                      textAlign: TextAlign.center,
                    ),
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
    final subTabs = const [
      Tab(icon: Icon(Icons.color_lens, size: 18), text: "Color"),
      Tab(icon: Icon(Icons.grid_on, size: 18), text: "Pixel Shape"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 0.25),
          Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
              //borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              tabs: subTabs,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).primaryColor.withAlpha((0.8 * 255).round()),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                //borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 12),
          // --- 中身 ---
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              alignment: WrapAlignment.center,
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
        width: 120,
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
              width: 72,
              height: 72,
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
    final subTabs = const [
      Tab(icon: Icon(Icons.color_lens, size: 18), text: "Color"),
      Tab(icon: Icon(Icons.texture, size: 18), text: "Style"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 0.25), // 微妙に下の余白を減らす
          Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
            ),
            child: TabBar(
              tabs: subTabs,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).primaryColor.withAlpha((0.8 * 255).round()),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicator: BoxDecoration(color: Theme.of(context).primaryColor),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 12),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                _buildBackgroundChoice(
                  label: "Square",
                  value: "normal",
                  child: Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[300],
                  ),
                ),
                _buildBackgroundChoice(
                  label: "Rounded",
                  value: "rounded",
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                _buildBackgroundChoice(
                  label: "Transparent",
                  value: "transparent",
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(200, 200, 200, 0.3),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(Icons.blur_on),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundChoice({
    required String label,
    required String value,
    required Widget child,
  }) {
    final bool isSelected = backgroundStyle == value;

    return GestureDetector(
      onTap: () {
        setState(() => backgroundStyle = value);
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 72, height: 72, child: child),
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

  //中央部分のタブ
  Widget _buildIconTab() {
    final subTabs = const [
      Tab(icon: Icon(Icons.insert_emoticon, size: 18), text: "Icon"),
      Tab(icon: Icon(Icons.color_lens, size: 18), text: "Color"),
      Tab(icon: Icon(Icons.image, size: 18), text: "Image"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 0.25), // 微調整
          Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
            ),
            child: TabBar(
              tabs: subTabs,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).primaryColor.withAlpha((0.8 * 255).round()),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicator: BoxDecoration(color: Theme.of(context).primaryColor),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 12),
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

  int iconPageIndex = 0;

  Widget _buildIconSelection() {
    final iconsPerPage = 24;
    final totalPages = (availableIcons.length / iconsPerPage).ceil();
    final pageController = PageController(initialPage: iconPageIndex);

    List<Widget> buildPages() {
      return List.generate(totalPages, (pageIndex) {
        final start = pageIndex * iconsPerPage;
        final end = (start + iconsPerPage).clamp(0, availableIcons.length);
        final icons = availableIcons.sublist(start, end);

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children:
              icons.map((iconData) {
                final isSelected = _selectedIcon == iconData;
                return GestureDetector(
                  onTap:
                      () => setState(() {
                        _selectedIcon = isSelected ? null : iconData;
                        _isImageVisible = false;
                      }),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? Colors.blueAccent.withAlpha(51)
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(8), // 丸のサイズ調整ポイント
                    child: Icon(
                      iconData,
                      size: 36,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                );
              }).toList(),
        );
      });
    }

    return Column(
      children: [
        // ページ切替ボタンとページ表示
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed:
                  iconPageIndex > 0
                      ? () {
                        setState(() {
                          iconPageIndex--;
                          pageController.animateToPage(
                            iconPageIndex,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      }
                      : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text("Page ${iconPageIndex + 1} / $totalPages"),
            IconButton(
              onPressed:
                  iconPageIndex < totalPages - 1
                      ? () {
                        setState(() {
                          iconPageIndex++;
                          pageController.animateToPage(
                            iconPageIndex,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      }
                      : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // アイコン一覧部分
        Flexible(
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                iconPageIndex = index;
              });
            },
            children: buildPages(),
          ),
        ),

        //const SizedBox(height: 12),

        // Deleteボタンをアイコン群の真下に配置
        Center(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedIcon = null;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close),
                SizedBox(width: 4),
                Text("Deselect", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),
      ],
    );
  }

  final List<IconData> availableIcons = [
    // URL・リンク系（URL, Link, Public, Open_in_new, Shareなど）
    Icons.link,
    Icons.public,
    Icons.open_in_new,
    Icons.share,
    Icons.language,

    // テキスト系（Text, Message, Chat, Forum, Email, Book, Bookmark）
    Icons.text_fields,
    Icons.message,
    Icons.chat,
    Icons.forum,
    Icons.email,
    Icons.book,
    Icons.bookmark,

    // 電話系（Phone, Call）
    Icons.phone,
    Icons.call,

    // WiFi・通信系（WiFi, Bluetooth, Network系）
    Icons.wifi,
    Icons.bluetooth,
    Icons.dns,
    Icons.network_check, // 追加候補
    // 基本アクション・UI系
    Icons.favorite,
    Icons.favorite_border,
    Icons.star,
    Icons.thumb_up,
    Icons.check,
    Icons.close,
    Icons.done,
    Icons.edit,
    Icons.search,
    Icons.filter_vintage,
    Icons.zoom_in,
    Icons.zoom_out,
    Icons.send,
    Icons.security,
    Icons.lock,
    Icons.notifications,
    Icons.help,
    Icons.info,
    Icons.menu,

    // 人・プロフィール系
    Icons.person,
    Icons.account_circle,
    Icons.group,
    Icons.face,
    Icons.face_retouching_natural,
    Icons.fingerprint,
    Icons.android,
    Icons.apple,

    // 生活・場所・交通系
    Icons.home,
    Icons.location_on,
    Icons.map,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.local_hospital,
    Icons.local_library,
    Icons.local_mall,
    Icons.local_offer,
    Icons.local_parking,
    Icons.local_pharmacy,
    Icons.local_play,
    Icons.local_post_office,
    Icons.local_shipping,
    Icons.directions_car,
    Icons.directions_bike,
    Icons.directions_walk,
    Icons.flight,
    Icons.hotel,
    Icons.calendar_today,
    Icons.drive_eta,

    // 仕事・勉強・趣味系
    Icons.school,
    Icons.work,
    Icons.code,
    Icons.build,
    Icons.gamepad,
    Icons.fitness_center,
    Icons.sports_esports,
    Icons.headphones,
    Icons.handyman,

    // 趣味・芸術・自然系
    Icons.palette,
    Icons.emoji_emotions,
    Icons.emoji_food_beverage,
    Icons.emoji_nature,
    Icons.emoji_people,
    Icons.emoji_symbols,
    Icons.emoji_transportation,
    Icons.eco,
    Icons.bug_report,
    Icons.hiking,
    Icons.highlight,
    Icons.history,

    // お金・買い物系
    Icons.attach_money,
    Icons.credit_card,
    Icons.shopping_cart,
    Icons.print,
    Icons.battery_full,
    Icons.brightness_5,

    // その他
    Icons.face,
    Icons.desktop_windows,
  ];

  bool isIconColorSelected = true;

  Widget _buildIconColorSelection() {
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
                  onPressed: () => setState(() => isIconColorSelected = true),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        isIconColorSelected ? AppColors.primary : null,
                    foregroundColor:
                        isIconColorSelected ? Colors.white : AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.color_lens, size: 18),
                      SizedBox(width: 4),
                      Text("Icon Color"),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => isIconColorSelected = false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        !isIconColorSelected ? AppColors.primary : null,
                    foregroundColor:
                        !isIconColorSelected ? Colors.white : AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.format_color_fill, size: 18),
                      SizedBox(width: 4),
                      Text("Background Color"),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // カラーセレクター
          if (isIconColorSelected)
            Column(
              children: [
                ColorSelector(
                  key: const ValueKey('icon_color'),
                  title: "",
                  selectedColor: selectedIconColor,
                  onColorSelected: (color) {
                    setState(() {
                      selectedIconColor = color;
                    });
                  },
                ),
              ],
            )
          else
            Column(
              children: [
                ColorSelector(
                  key: const ValueKey('background_color'),
                  title: "",
                  selectedColor: selectedIconBackgroundColor,
                  onColorSelected: (color) {
                    setState(() {
                      selectedIconBackgroundColor = color;
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  bool _isImageVisible = true; // QRコード上の表示・非表示フラグ

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _isImageVisible = true; // 新規選択時は表示オンに
        _selectedIcon = null;
      });
    }
  }

  Widget _buildImageSelection() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImage != null)
              SizedBox(
                width: 150,
                height: 150,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.file(_selectedImage!),
                ),
              )
            else
              const Text('No image selected.'),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isImageVisible,
                    onChanged: (checked) {
                      setState(() {
                        _isImageVisible = checked ?? false;
                        if (_isImageVisible) {
                          _selectedIcon = null;
                        }
                      });
                    },
                  ),
                  const Text('Show this image on QR code'),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Select Image ボタン
                OutlinedButton(
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image),
                      SizedBox(width: 4),
                      Text(
                        'Select Image',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (_selectedImage != null)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _isImageVisible = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //上下文字のタブ
  Widget _buildLabelTab() {
    final subTabs = const [
      Tab(icon: Icon(Icons.text_fields, size: 18), text: "Top Label"),
      Tab(icon: Icon(Icons.text_fields, size: 18), text: "Bottom Label"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 0.25), // 微調整
          Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
            ),
            child: TabBar(
              tabs: subTabs,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).primaryColor.withAlpha((0.8 * 255).round()), // 安全な不透明度指定
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicator: BoxDecoration(color: Theme.of(context).primaryColor),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 12),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.text_fields, size: 18),
                      SizedBox(width: 4),
                      Text("Label Text"),
                    ],
                  ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.color_lens, size: 18),
                      SizedBox(width: 4),
                      Text("Font Color"),
                    ],
                  ),
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
                Row(
                  children: const [
                    Icon(Icons.text_fields, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Top Label Text",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle),
                          const SizedBox(width: 4),
                          const Text(
                            'Apply',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete),
                          const SizedBox(width: 4),
                          const Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  children: const [
                    Icon(Icons.font_download, size: 20),
                    SizedBox(width: 4),
                    Text("Font", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
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
                Row(
                  children: const [
                    Icon(Icons.format_size, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Text Size",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: topLabelStyle.fontSize ?? 16,
                  min: 12,
                  max: 36,
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
                //const Text(""),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.text_fields, size: 18),
                      SizedBox(width: 4),
                      Text("Label Text"),
                    ],
                  ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.color_lens, size: 18),
                      SizedBox(width: 4),
                      Text("Font Color"),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (!showColorSettingBottom)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.text_fields, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Bottom Label Text",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle),
                          const SizedBox(width: 4),
                          const Text(
                            'Apply',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete),
                          const SizedBox(width: 4),
                          const Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  children: const [
                    Icon(Icons.font_download, size: 20),
                    SizedBox(width: 4),
                    Text("Font", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
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
                Row(
                  children: const [
                    Icon(Icons.format_size, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Text Size",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: bottomLabelStyle.fontSize ?? 16,
                  min: 12,
                  max: 36,
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
                //const Text(""),
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
