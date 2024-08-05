import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  int quantity;

  CartItem(this.quantity,
      {required this.id, required this.price, required this.title});
}

class Cart with ChangeNotifier {
  // ignore: prefer_final_fields
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemLength {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void addToCart(
      {required String id, required String title, required double price}) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (value) => CartItem(value.quantity + 1,
            id: value.id, price: value.price, title: value.title),
      );
    } else {
      _items.putIfAbsent(id,
          () => CartItem(1, id: DateTime.now().toString(), price: price, title: title));
    }
    notifyListeners();
  }

  void deleteFromCart(
       String id,) {
    if (!_items.containsKey(id)) {
      
      return;
    } else if(_items[id]!.quantity==1) {
      _items.remove(id);
    }
    else {
      _items[id]!.quantity=_items[id]!.quantity-1;
    }
    notifyListeners();
  }

  void deleteItem( productId){
    _items.remove(productId);
    notifyListeners();

  }

  void clearCart(){
    _items={};
    notifyListeners();
  }

}
