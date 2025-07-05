# QRious

A comprehensive Flutter application for scanning and creating QR codes with a modern, intuitive interface. This app features robust security measures for URL verification, extensive QR code creation options, and a user-friendly history management system.

## 🚀 Features

### 📱 QR Code Scanning
- **Real-time scanning** using device camera
- **Multiple format support**: QR codes, barcodes, and other 2D codes
- **Flashlight control** for low-light environments
- **Scan mode toggle** between QR and barcode detection
- **Automatic content detection** and parsing
- **Advanced security checking** for potentially malicious URLs
- **Quick actions** for scanned content (open URL, copy, share)

### 🛡️ Security Features
- **Local URL validation** without requiring external APIs:
  - **HTTPS verification**: Warns about insecure connections
  - **Suspicious domain detection**: Flags potentially harmful TLDs
  - **URL shortener identification**: Warns about obscured destinations
  - **Domain structure analysis**: Detects unusual domain patterns
- **Visual safety indicators** with detailed warnings

### 🎨 QR Code Creation
- **Multiple content types**:
  - **URL**: Create QR codes that open websites
  - **Text**: Store plain text information
  - **Phone Number**: Generate dialer QR codes
  - **Wi-Fi**: Share network credentials
- **Customizable appearance** with color selection
- **Preview functionality** before saving
- **Save as image** with high resolution
- **Share generated QR codes**

### 📚 History Management
- **Automatic scan history** with local database storage
- **Safety status tracking** for scanned URLs
- **Favorites system** for important QR codes
- **Bulk operations**: delete multiple items, toggle favorites
- **Search and filter** capabilities
- **Tabbed interface**: All items and Favorites
- **Selection mode** for batch operations

### 🎨 User Interface
- **Dark/Light theme** support with automatic persistence
- **Modern Material Design** with custom color palette
- **Responsive layout** for different screen sizes
- **Smooth animations** and transitions
- **Intuitive navigation** with bottom navigation bar

## 🏗️ Architecture

### Project Structure
```
lib/
├── api/
│   └── db_helper.dart          # SQLite database operations
├── models/
│   ├── qr_code_model.dart      # QR code data model
│   ├── qr_create_data.dart     # QR creation form data
│   └── qr_decoration_settings.dart # QR appearance settings
├── providers/
│   ├── history_provider.dart   # State management for history
│   └── theme_provider.dart     # Theme state management
├── screens/
│   ├── scanner/                # QR scanning functionality
│   │   ├── scanner_controller.dart
│   │   ├── scanner_screen.dart
│   │   └── scanner_view.dart
│   ├── creator/                # QR code creation
│   │   ├── color_selector.dart
│   │   ├── creator_screen.dart
│   │   ├── qr_decorate_result_screen.dart
│   │   ├── qr_decorate_screen.dart
│   │   ├── qr_input_screen.dart
│   │   └── qr_result_screen.dart
│   ├── history/                # History management
│   │   ├── history_controller.dart
│   │   ├── history_list_view.dart
│   │   └── history_screen.dart
│   └── result/                 # Scan result display
│       ├── result_content_view.dart
│       ├── result_controller.dart
│       └── result_screen.dart
├── utils/
│   ├── app_colors.dart         # Theme-aware color system
│   ├── qr_capture_util.dart    # QR capture utilities
│   ├── theme_helper.dart       # Theme utilities
│   └── url_safety_util.dart    # URL security validation
└── widgets/
    ├── bottom_nav_bar.dart     # Main navigation
    ├── qr_pixel_painter.dart   # Custom QR rendering
    ├── qr_preview_widget.dart  # QR preview component
    ├── history/                # History components
    │   ├── history_app_bar.dart
    │   ├── history_empty_state.dart
    │   ├── history_list_item.dart
    │   └── selection_action_bar.dart
    ├── result/                 # Result components
    │   ├── content_card.dart
    │   ├── result_action_button.dart
    │   └── safety_indicator.dart
    └── scanner/                # Scanner components
        ├── scan_frame.dart
        ├── scanner_controls.dart
        └── scanner_loading.dart
```

### State Management
- **Provider pattern** for state management
- **HistoryProvider**: Manages scan history, favorites, and database operations
- **ThemeProvider**: Handles dark/light theme switching with persistence

### Database
- **SQLite** local database for scan history
- **QRCodeModel** for data structure with safety status
- **CRUD operations** for history management
- **Database migrations** for schema updates

## 🛠️ Technology Stack

### Core Dependencies
- **Flutter**: Cross-platform UI framework (^3.7.2)
- **Provider**: State management (^6.1.2)
- **mobile_scanner**: Camera-based QR code scanning (^7.0.1)
- **qr_flutter**: QR code generation (^4.1.0)
- **sqflite**: Local SQLite database (^2.3.3)
- **path_provider**: File system access (^2.1.5)
- **screenshot**: QR code image capture (^3.0.0)
- **share_plus**: Content sharing (^11.0.0)
- **url_launcher**: URL opening (^6.2.5)
- **shared_preferences**: Theme persistence (^2.5.3)
- **flutter_colorpicker**: Color selection UI (^1.1.0)
- **google_fonts**: Typography enhancement (^6.2.1)
- **flutter_iconpicker**: Icon selection (^4.0.1)

### Development Dependencies
- **flutter_lints**: Code quality and style enforcement (^5.0.0)
- **flutter_test**: Unit and widget testing

## 📱 App Flow

### 1. Scanner Flow
```
Camera Access → Real-time Scanning → Content & Safety Detection → Result Screen → History Storage
```

### 2. Creator Flow
```
Type Selection → Content Input → Customization → Preview → Save/Share
```

### 3. History Flow
```
View History → Filter/Search → Select Items → Bulk Operations → Database Update
```

## 🎯 Key Features Explained

### URL Security System

The app employs a multi-layered approach to protect users from potentially harmful URLs:

1. **Basic Validation Layer**:
   - Checks if URL follows proper format standards
   - Verifies HTTPS protocol usage for secure connections
   - Examines domain structure for suspicious patterns

2. **Domain Analysis Layer**:
   - Screens for known suspicious TLDs (.xyz, .tk, etc.)
   - Identifies URL shortener services that could hide malicious destinations
   - Flags domains with excessive subdomains (common in phishing)

3. **User Interface Layer**:
   - Visual indicators show safety status with clear warnings
   - Detailed explanations of potential risks
   - Option to proceed with caution

### QR Code Types Supported
- **URL**: Automatically opens in browser when scanned (with safety checks)
- **Text**: Displays plain text content
- **Phone Number**: Opens phone dialer with pre-filled number
- **Wi-Fi**: Automatically connects to network (requires user confirmation)

### Performance Optimizations
- **Lazy loading** for history items
- **Image caching** for QR code previews
- **Efficient database queries** with proper indexing
- **Memory management** for camera resources

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.7.2)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator / Physical Device

### Installation
1. **Clone the repository**
   ```bash
   git clone https://github.com/NaimiNafis/QRious.git
   cd QRious
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: API 21 (Android 5.0)
- Camera permissions automatically requested
- No additional configuration required

#### iOS
- Minimum iOS version: 12.0
- Camera permissions in Info.plist
- Privacy descriptions for camera usage

#### Web
- Limited camera access (browser-dependent)
- File download for QR code images

## 🔧 Development

### Code Style
- Follows Flutter linting rules
- Consistent naming conventions
- Proper documentation and comments
- Separation of concerns

### Testing
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

### Building for Production
```bash
# Android APK with code obfuscation for security
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# iOS
flutter build ios --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Web
flutter build web --release
```

## 📊 Database Schema

### QR Codes Table
```sql
CREATE TABLE qr_codes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  type TEXT NOT NULL,
  isFavorite INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  isSafe INTEGER NOT NULL DEFAULT 1
)
```

## 🎨 UI/UX Design

### Color Palette
- **Light Theme**: Clean white background with purple accents
- **Dark Theme**: Deep gray background with purple accents
- **Accent Colors**: Deep Purple (primary: #673AB7, variant: #512DA8)
- **Safety Indicators**: Green for safe, red for potentially unsafe

### Navigation
- **Bottom Navigation**: Three main sections (Scan, Creator, History)
- **Tab Navigation**: History screen with All/Favorites tabs
- **Modal Navigation**: QR creation and result screens

## 🔒 Permissions & Security

### Required Permissions
- **Camera**: For QR code scanning
- **Storage**: For saving QR code images
- **Internet**: For URL validation and opening

### Privacy Features
- **Local validation**: Security checks performed on-device
- **No data sharing**: No scan data sent to external servers
- **Camera access**: Only when actively scanning
- **No tracking**: No analytics or user tracking

## 🐛 Known Issues & Limitations

### Current Limitations
- **Web platform**: Limited camera access
- **iOS**: Some QR code types may require additional permissions
- **Large history**: Performance may degrade with very large datasets
- **URL safety**: Local checks only without external API

### Future Enhancements
- **Cloud sync**: Backup history to cloud storage
- **QR code analytics**: Track scan statistics
- **Advanced customization**: More QR code styling options
- **Enhanced security**: Integration with more safety checking APIs
- **Batch QR creation**: Create multiple QR codes at once

## 🤝 Contributing

### Development Guidelines
1. Fork the repository
2. Follow existing code style and patterns
3. Add proper documentation for new features
4. Include tests for new functionality
5. Submit a pull request with detailed description

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Mobile Scanner package contributors
- QR Flutter package maintainers
- All open-source dependencies used in this project

---

**Note**: This app is designed for personal use and educational purposes. While it includes security measures for URL scanning, no system is perfect. Always exercise caution when scanning QR codes from unknown sources. 