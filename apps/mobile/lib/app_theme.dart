import 'package:material_ui/material_ui.dart';

class VestiaColors {
  static const canvas = Color(0xFFF7F4EF);
  static const forest = Color(0xFF203D32);
  static const forestLight = Color(0xFF49665A);
  static const coral = Color(0xFFD97B5D);
  static const ink = Color(0xFF19231F);
  static const muted = Color(0xFF6D756F);
}

class VestiaTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: VestiaColors.forest,
      primary: VestiaColors.forest,
      secondary: VestiaColors.coral,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: VestiaColors.canvas,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: VestiaColors.ink,
        displayColor: VestiaColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: VestiaColors.canvas,
        foregroundColor: VestiaColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: VestiaColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: VestiaColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: VestiaColors.forestLight,
            width: 1.4,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFE4EBE6),
        height: 72,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0ECE6),
        selectedColor: const Color(0xFFDCE7E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
    );
  }
}
