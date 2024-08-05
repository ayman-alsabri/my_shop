

import 'package:flutter/material.dart';
import 'package:my_shop/models/custom_transaction_builder.dart';
import 'package:my_shop/widgets/dialoge_widget.dart';
import './themes_data.dart';

class AppTheme with ChangeNotifier {
  MaterialColor _mainThemeColor = Colors.purple;
  LightModeEnum _mainLightMode = LightModeEnum.auto;
  late ThemeData _generalTheme;


  ThemeData get currentTheme {
  
    return _generalTheme;
  }

  ThemeData generalTheme(Brightness deviceBrightness) {
     
    _generalTheme = ThemeData(
      pageTransitionsTheme: PageTransitionsTheme(builders: { TargetPlatform.android:CustomTransactionBuilder()}),
      colorScheme: ColorScheme.fromSeed(
          seedColor: _mainThemeColor,
          brightness: _lightModeBrightness(deviceBrightness)),
      fontFamily: 'Lato',
      useMaterial3: true,
    );
    _generalTheme = _generalTheme.copyWith(
      colorScheme: _generalTheme.colorScheme.copyWith(
        onError: _mainLightMode == LightModeEnum.auto
            ? deviceBrightness == Brightness.light
                ? _generalTheme.colorScheme.onError
                : _generalTheme.colorScheme.error
            : _mainLightMode == LightModeEnum.light
                ? _generalTheme.colorScheme.onError
                : _generalTheme.colorScheme.error,
        error: _mainLightMode == LightModeEnum.auto
            ? deviceBrightness != Brightness.light
                ? _generalTheme.colorScheme.onError
                : _generalTheme.colorScheme.error
            : _mainLightMode != LightModeEnum.light
                ? _generalTheme.colorScheme.onError
                : _generalTheme.colorScheme.error,
                surface: _generalTheme.colorScheme.background
                
      ),
      scaffoldBackgroundColor:
          _generalTheme.colorScheme.background.withAlpha(230),
      popupMenuTheme: _generalTheme.popupMenuTheme.copyWith(
        elevation: 2,
        color: _generalTheme.colorScheme.background,
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(
            color: _generalTheme.colorScheme.onSurface,
          ),
        ),
      ),
      badgeTheme: _generalTheme.badgeTheme.copyWith(
        backgroundColor: _generalTheme.colorScheme.primary,
        textColor: _generalTheme.colorScheme.onPrimary,
      ),
      drawerTheme: _generalTheme.drawerTheme
          .copyWith(backgroundColor: _generalTheme.colorScheme.background),
      
    );
    return _generalTheme;
  }

  Brightness _lightModeBrightness(Brightness deviceBrightness) {
    switch (_mainLightMode) {
      case LightModeEnum.auto:
        return deviceBrightness;
      case LightModeEnum.dark:
        return Brightness.dark;
      case LightModeEnum.light:
        return Brightness.light;
    }
  }

  void changetheme(BuildContext context) {
    _mainThemeColor = TheThemes.mainAppColor;
    _mainLightMode = TheThemes.mainLightMode;

    _generalTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: _mainThemeColor,
          brightness:
              _lightModeBrightness(MediaQuery.platformBrightnessOf(context))),
      fontFamily: 'Lato',
    );
    notifyListeners();
  }
}
