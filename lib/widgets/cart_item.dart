import 'package:flutter/material.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;
  const CartItem({
    super.key,
    required this.id,
    required this.price,
    required this.quantity,
    required this.title,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final theme = Provider.of<AppTheme>(context, listen: false).currentTheme;

    return Dismissible(
      key: Key(id.toString()),
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.error,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 10),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        cart.deleteItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("delet item?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("NO"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("YES"),
              ),
            ],
          ),
        );
      },
      child: InkWell(
        onLongPress: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("delet item?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("NO"),
              ),
              TextButton(
                onPressed: () {
                  cart.deleteItem(productId);
                  Navigator.pop(context);
                },
                child: const Text("YES"),
              ),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.outlineVariant,
          ),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: FittedBox(
                child: Text(
                  " \$$price ",
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text("total: \$${(price * quantity).toStringAsFixed(2)}"),
            trailing: Text(
              "$quantity x",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
