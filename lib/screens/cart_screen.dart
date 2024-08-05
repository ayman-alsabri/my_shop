import 'package:flutter/material.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const route = '/cart_screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final orders = Provider.of<Orders>(context);
    final theme = Provider.of<AppTheme>(context, listen: false).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("your cart"),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.outlineVariant,
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    "\$${cart.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 5,
                ),
                Tooltip(
                  message: "place an order",
                  child: OrderButton(cart: cart, orders: orders),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return CartItem(
                    id: cart.items.values.toList()[index].id,
                    productId: cart.items.keys.toList()[index],
                    price: cart.items.values.toList()[index].price,
                    quantity: cart.items.values.toList()[index].quantity,
                    title: cart.items.values.toList()[index].title,
                  );
                },
                itemCount: cart.itemLength,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cart,
    required this.orders,
  });
  final Cart cart;
  final Orders orders;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isOrdering = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.cart.items.isEmpty || _isOrdering
          ? null
          : () async {
              setState(() {
                _isOrdering = true;
              });
              try {
                await widget.orders.addOrder(
                  cartItems: widget.cart.items.values.toList(),
                  totalAmount: widget.cart.totalAmount,
                );
                widget.cart.clearCart();
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("could not place the order")));
              } finally {
                setState(() {
                  _isOrdering = false;
                });
              }
            },
      child:_isOrdering?const CircularProgressIndicator(): const Text("ORDER NOW"),
    );
  }
}
