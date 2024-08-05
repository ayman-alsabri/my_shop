import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../widgets/product_overview_item.dart';
import '../providers/the_products.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';

enum ShowFavorites {
  favorites,
  all,
}

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showFavorites = false;
  var _firstinit = false;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_firstinit) {
      _isLoading = true;
      Provider.of<TheProducts>(context, listen: false)
          .getProductsFromServer()
          .catchError((error) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
              title:
                  const FittedBox(child: Text("Something went wrong!      ")),
              actions: [
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text("OK"),
                )
              ]),
        );
      }).then((value) {
        setState(() {
          _isLoading = false;
        });
      });
      _firstinit = true;
    }
    super.didChangeDependencies();
  }

  Future<void> _onRsfresh() async {
    await Provider.of<TheProducts>(context, listen: false)
        .getProductsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's start shopping"),
        actions: [
          Badge(
            label: Consumer<Cart>(
              builder: (_, cart, a) => Text("${cart.itemLength}"),
            ),
            offset: const Offset(-7, 7),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, CartScreen.route),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  setState(() {
                    _showFavorites = true;
                  });
                },
                child: const Text("show favorite"),
              ),
              PopupMenuItem(
                onTap: () {
                  setState(() {
                    _showFavorites = false;
                  });
                },
                child: const Text("show all"),
              )
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LinearProgressIndicator()
          : RefreshIndicator(
              onRefresh: _onRsfresh, child: GridViewListener(_showFavorites)),
      drawer: const AppDrawer(),
    );
  }
}

//new local widget that listen to a provider
//
//
//
class GridViewListener extends StatelessWidget {
  final bool showFavorites;
  const GridViewListener(
    this.showFavorites, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TheProducts listener = Provider.of<TheProducts>(context);
    final List loadedProdects =
        showFavorites ? listener.favoriteList : listener.list;

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: loadedProdects.length,
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          value: loadedProdects[index] as Product,
          child: const ProductOverviewItem(),
        );
      },
    );
  }
}
