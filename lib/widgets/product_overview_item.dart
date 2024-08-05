import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductOverviewItem extends StatelessWidget {
  const ProductOverviewItem({
    super.key,
  });

  Future<void> isFavoriteToggler(
      BuildContext context, Product product, Auth auth) async {
    try {
      await product.changeIsFavorite(auth.token, auth.userId);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("couldn't change status"),
        duration: Duration(milliseconds: 1200),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: true);
    final cart = Provider.of<Cart>(context, listen: false);
    final theme = Provider.of<AppTheme>(context, listen: false).currentTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, ProductDetailScreen.routeName,
            arguments: product.id),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.6),
            leading: IsFavIconButton(
              product: product,
              theme: theme,
              isFavoriteToggler: isFavoriteToggler,
            ),
            title: Text(
              product.title,
              style: TextStyle(color: theme.colorScheme.onPrimary),
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Added to cart"),
                    action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.deleteFromCart(product.id!);
                      },
                    ),
                  ),
                );
                cart.addToCart(
                  id: product.id!,
                  title: product.title,
                  price: product.price,
                );
              },
              tooltip: "add to cart",
              icon: Icon(
                Icons.shopping_cart,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          child: Hero(
            tag: product.id!,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class IsFavIconButton extends StatefulWidget {
  const IsFavIconButton({
    super.key,
    required this.isFavoriteToggler,
    required this.product,
    required this.theme,
  });
  final Function(BuildContext, Product, Auth) isFavoriteToggler;
  final Product product;
  final ThemeData theme;

  @override
  State<IsFavIconButton> createState() => _IsFavIconButtonState();
}

class _IsFavIconButtonState extends State<IsFavIconButton> {
  var _isSendingData = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    return IconButton(
      onPressed: _isSendingData
          ? () {}
          : () async {
              setState(() {
                _isSendingData = true;
              });
              await widget.isFavoriteToggler(context, widget.product, auth);
              setState(() {
                _isSendingData = false;
              });
            },
      tooltip: "add to favorite",
      icon: widget.product.isFavorite
          ? const Icon(
              Icons.favorite,
              color: Colors.red,
            )
          : Icon(
              Icons.favorite_outline,
              color: widget.theme.colorScheme.onPrimary,
            ),
    );
  }
}
