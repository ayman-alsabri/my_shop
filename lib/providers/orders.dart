import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_shop/models/http_exception.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double total;
  final DateTime date;
  final List<CartItem> cartItems;

  OrderItem({
    required this.date,
    required this.id,
    required this.cartItems,
    required this.total,
  });
}

class Orders with ChangeNotifier {
  // ignore: prefer_final_fields
  final String? _token;
  final String? _userId; 
  Orders(this._token , this._userId,this._items);
  List<OrderItem> _items = [];

  List<OrderItem> get items {
    return [..._items];
  }

  bool _firstInit = false;

  Future<void> getOrdersFromServer() async {
    if(_firstInit)return;
    final url = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_token');
    final response = await http.get(url);
    final respnsedata = jsonDecode(response.body) as Map<String, dynamic>?;
    final List<OrderItem> loadedList = [];
     if(respnsedata==null)throw HttpException('no orders');
        respnsedata.forEach((orderId, data) {
      loadedList.add(OrderItem(
          date: DateTime.parse( data['date']),
          id: orderId,
          cartItems: (data['cartItems'] as List)
              .map((e) => CartItem(e['quantity'],
                  id: e['id'], price: e['price'], title: e['title']))
              .toList(),
          total: data['total']));
    });
    _items=loadedList.reversed.toList();
    _firstInit=true;
    notifyListeners();
  }

  Future<void> addOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
  }) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_token');
    await http.post(url,
        body: jsonEncode({
          'date': timeStamp.toIso8601String(),
          'total': totalAmount,
          'cartItems': cartItems
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity,
                  })
              .toList()
        }));
    _items.insert(
        0,
        OrderItem(
            date: timeStamp,
            id: DateTime.now().toString(),
            cartItems: cartItems,
            total: totalAmount));
    notifyListeners();
  }

  OrderItem findOrderById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }


Future<void> getfromServerAgain()async{
  _firstInit=false;
  await getOrdersFromServer();
}
}
