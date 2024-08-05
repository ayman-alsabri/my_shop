import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../widgets/dialoge_widget.dart';

enum WichChoice {
  themes,
  lightMode,
}

class SettengsScreen extends StatelessWidget {
  const SettengsScreen({super.key});
  static const route = '/settengs_screen';

  Widget buildlistTile(
    String title,
    String subTitle,
    IconData icon,
    BuildContext context,
    WichChoice swich,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subTitle),
      leading: Icon(icon),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => CustomizedDialoge(
                  title: title,
                  swich: swich,
                ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () =>
          Navigator.pushReplacementNamed(context, '/') as Future<bool>,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settengs"),
        ),
        body: ListView(
          children: [
            buildlistTile(
              "themes",
              "chose the theme to apply in app",
              Icons.color_lens,
              context,
              WichChoice.themes,
            ),
            buildlistTile(
              "light mode",
              "chose the mode to apply in app",
              Icons.light_mode,
              context,
              WichChoice.lightMode,
            ),
          ],
        ),
        drawer: const AppDrawer(),
      ),
    );
  }
}
