import 'package:flutter/material.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:provider/provider.dart';

import '../providers/themes_data.dart';
import '../screens/settengs_screen.dart';

enum ThemesEnum {
  purple,
  pink,
  blue,
  orange,
  amber,
}

enum LightModeEnum {
  light,
  dark,
  auto,
}

class CustomizedDialoge extends StatelessWidget {
  final WichChoice swich;
  final String title;
  const CustomizedDialoge({
    super.key,
    required this.title,
    required this.swich,
  });

  List<Widget> components({
    required TheThemes thems,
    required AppTheme themes,
    required BuildContext cox,
    groupValue,
    groupValueLightMode,
  }) {
    groupValue = thems.groupValue1;
    groupValueLightMode = thems.groupValueLightMode1;
    switch (swich) {
//case whichchoice.themes
      case WichChoice.themes:
        return [
          ListTile(
            title: const Text("purple"),
            trailing: Radio(
              groupValue: groupValue,
              value: ThemesEnum.purple,
              onChanged: (_) {
                thems.changeCurrentTheme(ThemesEnum.purple);
          
              },
            ),
          ),
          ListTile(
            title: const Text("pink"),
            trailing: Radio(
              groupValue: groupValue,
              value: ThemesEnum.pink,
              onChanged: (_) {
                thems.changeCurrentTheme(ThemesEnum.pink);
              },
            ),
          ),
          ListTile(
            title: const Text("blue"),
            trailing: Radio(
              groupValue: groupValue,
              value: ThemesEnum.blue,
              onChanged: (_) {
                thems.changeCurrentTheme(ThemesEnum.blue);
              },
            ),
          ),
          ListTile(
            title: const Text("orange"),
            trailing: Radio(
              groupValue: groupValue,
              value: ThemesEnum.orange,
              onChanged: (_) {
                thems.changeCurrentTheme(ThemesEnum.orange);
              },
            ),
          ),
          ListTile(
            title: const Text("amber"),
            trailing: Radio(
              groupValue: groupValue,
              value: ThemesEnum.amber,
              onChanged: (_) {
                thems.changeCurrentTheme(ThemesEnum.amber);
              },
            ),
          ),
        ];
// case whichchoice.lightmode
      case WichChoice.lightMode:
        return [
          ListTile(
            title: const Text("automatic"),
            trailing: Radio(
              groupValue: groupValueLightMode,
              value: LightModeEnum.auto,
              onChanged: (_) {
                thems.changeCurrentMode(LightModeEnum.auto);
              },
            ),
          ),
          ListTile(
            title: const Text("light mode"),
            trailing: Radio(
              groupValue: groupValueLightMode,
              value: LightModeEnum.light,
              onChanged: (_) {
                thems.changeCurrentMode(LightModeEnum.light);

              },
            ),
          ),
          ListTile(
            title: const Text("dark mode"),
            trailing: Radio(
              groupValue: groupValueLightMode,
              value: LightModeEnum.dark,
              onChanged: (_) {
                thems.changeCurrentMode(LightModeEnum.dark);
              },
            ),
          ),
        ];
    }
  }

  List<Widget> actions(
    BuildContext context,
    TheThemes thems,
    AppTheme themes,
  ) {
    switch (swich) {
      case WichChoice.themes:
        return [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("cancle")),
          TextButton(
              onPressed: () {
                thems.chosenColor();
                themes.changetheme(context);

                Navigator.pop(context);
              },
              child: const Text("apply")),
        ];
//case lightmode
      //
      case WichChoice.lightMode:
        return [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("cancle")),
          TextButton(
              onPressed: () {
                thems.chosenMode();
                themes.changetheme(context);

                Navigator.pop(context);
              },
              child: const Text("apply")),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final TheThemes thems = Provider.of<TheThemes>(context, listen: false);
    final AppTheme themes = Provider.of<AppTheme>(context, listen: false);
    final groupValue = thems.groupValue;
    final groupValueLightMode = thems.groupValueLightMode;
    return AlertDialog(
      scrollable: true,
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Consumer<TheThemes>(
        builder: (context, value, child) => Column(
          children: components(
              cox: context,
              themes: themes,
              thems: value,
              groupValue: groupValue,
              groupValueLightMode: groupValueLightMode),
        ),
      ),
      actions: actions(
        context,
        thems,
        themes,
      ),
    );
  }
}
