import 'package:flutter/material.dart';
import 'package:my_shop/providers/the_products.dart';
import 'package:my_shop/screens/product_editing_screen.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});
  static const route = '/user_products';

  Future<void> _refreshFunction(
      TheProducts products, BuildContext context) async {
    await products.getProductsFromServer(true);
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<TheProducts>(context);
    return WillPopScope(
      onWillPop: () =>
          Navigator.pushReplacementNamed(context, '/') as Future<bool>,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("products manegment"),
          actions: [
            IconButton(
              tooltip: "add a new product",
              onPressed: () {
                Navigator.pushNamed(context, ProductEditScreen.route);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body:FutureBuilder(future: Provider.of<TheProducts>(context,listen: false).getProductsFromServer(true),
          builder: (context, snapshot) {
            if (snapshot.connectionState==ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            return Consumer<TheProducts>(builder: (context, products, child) =>RefreshIndicator(
                      onRefresh: () => _refreshFunction(products, context),
                      child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                itemCount: products.list.length,
                itemBuilder: (context, index) => UserProductItem(
                  id: products.list[index].id!,
                  imageUrl: products.list[index].imageUrl,
                  title: products.list[index].title,
                ),
              ),
                      ),
                    ) ,
              
            );
          
        },) ,
        drawer: const AppDrawer(),
      ),
    );
  }
}
