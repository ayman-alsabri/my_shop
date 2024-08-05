import 'package:flutter/material.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:provider/provider.dart';

import '../providers/the_products.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  static String routeName = '/detail_screen';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final theDesplayedProduct =
        Provider.of<TheProducts>(context, listen: false).productWithId(id);
    final mediaQuery = MediaQuery.of(context);
    final theme = Provider.of<AppTheme>(context,listen: false).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(theDesplayedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Hero(tag: theDesplayedProduct.id!,
                child: Image.network(
                  theDesplayedProduct.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "\$${theDesplayedProduct.price}",
                style: TextStyle(
                    color: theme.hintColor,
                    fontSize: mediaQuery.size.width * 0.07),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              child: Text(
                theDesplayedProduct.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: mediaQuery.size.width * 0.07),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
