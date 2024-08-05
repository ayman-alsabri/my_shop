import 'package:flutter/material.dart';
import '../widgets/dialoge_widget.dart';

class TheThemes with ChangeNotifier {
  final Map<ThemesEnum, MaterialColor> _themeColors = {
    ThemesEnum.purple: Colors.purple,
    ThemesEnum.pink: Colors.pink,
    ThemesEnum.blue: Colors.blue,
    ThemesEnum.orange: Colors.orange,
    ThemesEnum.amber: Colors.amber
  };

  // ignore: prefer_final_fields
  var _groupValue = ThemesEnum.purple;
  // ignore: prefer_typing_uninitialized_variables
  var _groupValue1;
  ThemesEnum get groupValue {
    _groupValue1 = _groupValue;
    return _groupValue;
  }

  ThemesEnum get groupValue1 {
    return _groupValue1;
  }

  // ignore: prefer_final_fields
  var _groupValueLightMode = LightModeEnum.auto;
  // ignore: prefer_typing_uninitialized_variables
  var _groupValueLightMode1;
  LightModeEnum get groupValueLightMode {
    _groupValueLightMode1 = _groupValueLightMode;
    return _groupValueLightMode;
  }

  LightModeEnum get groupValueLightMode1 {
    return _groupValueLightMode1;
  }

  void changeCurrentTheme(ThemesEnum value) {
    _groupValue1 = value;
    notifyListeners();
  }

  void changeCurrentMode(LightModeEnum value) {
    _groupValueLightMode1 = value;
    notifyListeners();
  }

  static LightModeEnum mainLightMode = LightModeEnum.auto;
  static MaterialColor mainAppColor = Colors.blue;

  void chosenColor() {
    _groupValue = _groupValue1;
    mainAppColor = _themeColors[_groupValue1]!;

    // return _themeColors[key]! ;
  }

  void chosenMode() {
    _groupValueLightMode = _groupValueLightMode1;
    mainLightMode = _groupValueLightMode1;
  }
}
