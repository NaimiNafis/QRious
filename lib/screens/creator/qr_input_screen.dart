import 'package:flutter/material.dart';
import '../../models/qr_create_data.dart';
import 'qr_result_screen.dart';
import '../../utils/app_colors.dart';
import 'package:flutter/services.dart';

class QrInputScreen extends StatefulWidget {
  final String qrType;

  const QrInputScreen({super.key, required this.qrType});

  @override
  State<QrInputScreen> createState() => _QrInputScreenState();
}

class _QrInputScreenState extends State<QrInputScreen> {
  final TextEditingController input1 = TextEditingController();
  final TextEditingController input2 = TextEditingController();
  final TextEditingController input3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.qrType == 'URL') {
      input1.text = 'https://';
      input1.selection = TextSelection.fromPosition(
        TextPosition(offset: input1.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            'Enter ${widget.qrType} Info',
            style: TextStyle(color: AppColors.textLight),
          ),
          iconTheme: IconThemeData(color: AppColors.textLight),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [..._buildInputsForType(widget.qrType)],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 50),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              icon: Icon(Icons.qr_code, color: AppColors.textLight, size: 24),
              label: Text(
                "Generate QR Code",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _onCreatePressed,
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: TextStyle(color: AppColors.textMuted),
        ),
        style: TextStyle(color: AppColors.textDark),
      ),
    );
  }

  List<Widget> _buildInputsForType(String type) {
    switch (type) {
      case 'Wi-Fi':
        return [
          _styledTextField('SSID', input1),
          _styledTextField('Password', input2),
        ];
      case 'Phone Number':
        return [
          _styledTextField(
            'Enter phone number',
            input1,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ];
      case 'URL':
        return [_styledTextField('Enter URL', input1)];
      default:
        return [_styledTextField('Enter text', input1)];
    }
  }

  void _onCreatePressed() {
    if (input1.text.trim().isEmpty ||
        (widget.qrType == 'Wi-Fi' && input2.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    String qrData;

    switch (widget.qrType) {
      case 'Wi-Fi':
        qrData = 'WIFI:T:WPA;S:${input1.text};P:${input2.text};;';
        break;
      case 'Phone Number':
        qrData = 'tel:${input1.text}';
        break;
      default:
        qrData = input1.text;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrResultScreen(
          qrData: QrCreateData(type: widget.qrType, content: qrData),
        ),
      ),
    );
  }
}
