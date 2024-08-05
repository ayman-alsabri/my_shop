import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../screens/settengs_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text("Let's go"),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text("shopping"),
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                ),
                ListTile(
                  leading: const Icon(Icons.local_shipping),
                  title: const Text("orders"),
                  onTap: () => Navigator.pushReplacementNamed(
                      context, OrdersScreen.route),
                ),
                ListTile(
                  leading: const Icon(Icons.dataset),
                  title: const Text("products"),
                  onTap: () => Navigator.pushReplacementNamed(
                      context, UserProductsScreen.route),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("settengs"),
                  onTap: () => Navigator.pushReplacementNamed(
                      context, SettengsScreen.route),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("log out"),
                  onTap: () =>
                      Provider.of<Auth>(context, listen: false).logOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
