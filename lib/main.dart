import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import './screens/product_overview_screen.dart';
import './providers/the_products.dart';
import './screens/product_detail_screen.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/settengs_screen.dart';
import './providers/themes_data.dart';
import './providers/theme.dart';
import './screens/user_products_screen.dart';
import './screens/product_editing_screen.dart';
import './screens/4.1 auth_screen.dart';
import './providers/auth.dart';
import './screens/loading_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    final deviceBrightness = MediaQuery.platformBrightnessOf(context);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, TheProducts>(
            update: (context, value, previous) =>
                TheProducts(value.token, value.userId, previous!.list),
            create: (context) => TheProducts(null, null, []),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (context, value, previous) =>
                Orders(value.token, value.userId, previous!.items),
            create: (context) => Orders(null, null, []),
          ),
          ChangeNotifierProvider(
            create: (context) => TheThemes(),
          ),
          ChangeNotifierProvider(
            create: (context) => AppTheme(),
          ),
        ],
        builder: (context, child) => MaterialApp(
              title: 'All Shop',
              theme:
                  Provider.of<AppTheme>(context).generalTheme(deviceBrightness),
              home: Provider.of<Auth>(context).isAuthinticated
                  ? const ProductOverviewScreen()
                  : FutureBuilder(
                      future:
                          Provider.of<Auth>(context, listen: false).autoLogin(),
                      builder: (context, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? const LoadingScreen()
                              : const AuthScreen(),
                    ),
              routes: {
                ProductDetailScreen.routeName: (context) =>
                    const ProductDetailScreen(),
                CartScreen.route: (context) => const CartScreen(),
                OrdersScreen.route: (context) => const OrdersScreen(),
                SettengsScreen.route: (context) => const SettengsScreen(),
                UserProductsScreen.route: (context) =>
                    const UserProductsScreen(),
                ProductEditScreen.route: (context) => const ProductEditScreen(),
              },
            ));
  }
}
