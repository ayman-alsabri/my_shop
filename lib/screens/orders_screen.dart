import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  static const route = '/orders_screen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    _isLoading = true;
    Future.delayed(Duration.zero).then((value) async {
      try {
        await Provider.of<Orders>(context, listen: false).getOrdersFromServer();
      } catch (e) {
        if (!mounted) return;
        String errorMessage = "could not load orders";
        if(e.toString()=='no orders'){
          errorMessage='no orders yet';
        }
        ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(errorMessage)));
      }
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context);

    return WillPopScope(
      onWillPop: () =>
          Navigator.pushReplacementNamed(context, '/') as Future<bool>,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your orders!"),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  try {
                    await orders.getfromServerAgain();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("could not refresh!")));
                  }
                },
                child: ListView.builder(
                  itemBuilder: (context, index) =>
                      OrderItem(id: orders.items[index].id),
                  itemCount: orders.items.length,
                ),
              ),
        drawer: const AppDrawer(),
      ),
    );
  }
}
