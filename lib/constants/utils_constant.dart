import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

/// Custom scroll behavior that supports both touch and mouse drag devices
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  TargetPlatform getPlatform(BuildContext context) {
    return Theme.of(context).platform;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}

/// Safe font loader with fallback to default font
/// Returns a TextStyle using Google Fonts with proper error handling
TextStyle safeGoogleFont(
  String fontFamily, {
  TextStyle? textStyle,
  Color? color,
  Color? backgroundColor,
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? wordSpacing,
  TextBaseline? textBaseline,
  double? height,
  Locale? locale,
  Paint? foreground,
  Paint? background,
  List<Shadow>? shadows,
  List<FontFeature>? fontFeatures,
  // Dihapus: List<FontVariation>? fontVariations, // Parameter ini tidak tersedia di Google Fonts
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
  double? decorationThickness,
}) {
  try {
    return GoogleFonts.getFont(
      fontFamily,
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      // Dihapus: fontVariations: fontVariations, // Parameter ini tidak tersedia
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  } catch (exception, stackTrace) {
    debugPrint('Error loading font $fontFamily: $exception');
    debugPrint('Stack trace: $stackTrace');

    // Fallback to Roboto with proper null safety
    return GoogleFonts.roboto(
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      // Dihapus: fontVariations: fontVariations, // Parameter ini tidak tersedia
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }
}

/// Predefined text styles for consistent typography across the app
class AppTextStyles {
  // Display
  static TextStyle displayLarge(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle displayMedium(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Headline
  static TextStyle headlineLarge(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineMedium(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Title
  static TextStyle titleLarge(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleMedium(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Body
  static TextStyle bodyLarge(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyMedium(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodySmall(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  // Label
  static TextStyle labelLarge(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle labelMedium(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle labelSmall(BuildContext context) => safeGoogleFont(
    'Roboto',
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// Utility functions for common operations
class AppUtils {
  /// Hides the soft keyboard
  static void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Copies text to clipboard with feedback
  static Future<void> copyToClipboard({
    required BuildContext context,
    required String text,
    String? successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage ?? 'Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Formats a number with thousand separators
  static String formatNumber(num value, {String locale = 'en_US'}) {
    final formatter = NumberFormat('#,###', locale);
    return formatter.format(value);
  }

  /// Returns a human-readable file size
  static String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Checks if the current platform is dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Gets the appropriate color based on brightness
  static Color getAdaptiveColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black;
  }
}

/// Extension methods for BuildContext
extension ContextExtensions on BuildContext {
  /// Returns the text theme from current theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns the color scheme from current theme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Returns the media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the screen size
  Size get screenSize => mediaQuery.size;

  /// Returns the screen width
  double get screenWidth => screenSize.width;

  /// Returns the screen height
  double get screenHeight => screenSize.height;

  /// Returns true if dark mode is enabled
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Hides the soft keyboard
  void hideKeyboard() => AppUtils.hideKeyboard(this);
}

/// Extension methods for String
extension StringExtensions on String {
  /// Returns true if the string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Returns true if the string is not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Capitalizes the first letter of the string
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Returns a truncated string with ellipsis if longer than maxLength
  String truncate(int maxLength, {bool showEllipsis = true}) {
    if (length <= maxLength) return this;
    return showEllipsis
        ? '${substring(0, maxLength)}...'
        : substring(0, maxLength);
  }
}
