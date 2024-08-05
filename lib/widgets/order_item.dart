import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_shop/providers/theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart';

class OrderItem extends StatefulWidget {
  final String id;

  const OrderItem({required this.id, super.key});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    final currentOrder =
        Provider.of<Orders>(context, listen: false).findOrderById(widget.id);
    final currentTime = DateTime.now();
    final theme = Provider.of<AppTheme>(context, listen: false).currentTheme;

    //check to desplay dateformat accordingly
    //
    String dateformat() {
      if (currentOrder.date.year == currentTime.year) {
        if ((currentTime.subtract(const Duration(days: 7)))
                .isBefore(currentOrder.date) &&
            currentOrder.date.weekday <= currentTime.weekday) {
          if (currentOrder.date.day == currentTime.day) return "HH:mm";

          return "EEEE  HH:mm";
        } else {
          return "dd/MMMF";
        }
      } else {
        return "dd/MMM/yyy";
      }
    }

    return Column(
      children: [
        Container(
          color: theme.colorScheme.outlineVariant,
          alignment: AlignmentDirectional.centerEnd,
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: ListTile(
            title: Text('\$${currentOrder.total.toStringAsFixed(2)}'),
            subtitle: Text(DateFormat(dateformat()).format(currentOrder.date)),
            trailing: IconButton(
              icon: _expanded
                  ? const Icon(Icons.expand_less)
                  : const Icon(Icons.expand_more),
              onPressed: () => setState(() {
                _expanded = !_expanded;
              }),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: theme.colorScheme.outlineVariant,
          height:
              _expanded ? min(currentOrder.cartItems.length * 40 + 10, 140) : 0,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ListView(
            children: currentOrder.cartItems
                .map(
                  (e) => SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground),
                        ),
                        Text("${e.quantity} x \$${e.price}",
                            style: TextStyle(color: theme.disabledColor))
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
