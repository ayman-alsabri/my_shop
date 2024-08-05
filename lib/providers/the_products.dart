import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

class TheProducts with ChangeNotifier {
  final String? _token;
  final String? _userId;
  TheProducts(this._token, this._userId, this._list);
  // ignore: prefer_final_fields
  List<Product> _list = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get list {
    return [..._list];
  }

  List<Product> get favoriteList {
    return _list.where((element) => element.isFavorite).toList();
  }

  Future<void> getProductsFromServer([bool onlyUsersProducts = false]) async {
    final urlSnippit =
        onlyUsersProducts ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    final url = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/products.json?auth=$_token$urlSnippit');

    final url2 = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/$_userId.json?auth=$_token');
    final response2 = await http.get(url2);
    final recevedData2 = jsonDecode(response2.body);
    final response = await http.get(url);
    final recevedData = jsonDecode(response.body) as Map;

    final List<Product> temperaryList = [];
    recevedData.forEach((prodId, prodInfo) {
      temperaryList.add(Product(
          description: prodInfo['description'],
          id: prodId,
          imageUrl: prodInfo['imageUrl'],
          price: prodInfo['price'],
          title: prodInfo['title'],
          isFavorite:
              recevedData2 == null ? false : recevedData2[prodId] ?? false));
    });
    _list = temperaryList;

    notifyListeners();
  }

  Future<void> addProduct(Product item) async {
    final url = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/products.json?auth=$_token');

    final value = await http.post(url,
        body: json.encode({
          'title': item.title,
          'price': item.price,
          'description': item.description,
          'imageUrl': item.imageUrl,
          'isFavorite': item.isFavorite,
        }));

    final newProduct = Product(
      description: item.description,
      id: jsonDecode(value.body)['name'],
      imageUrl: item.imageUrl,
      price: item.price,
      title: item.title,
    );
    _list.add(newProduct);

    notifyListeners();
  }

  void editProduct(Product item, String id) {
    final url = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/products/$id.json?auth=$_token');

    http.patch(url,
        body: jsonEncode({
          'title': item.title,
          'description': item.description,
          'price': item.price,
          'imageUrl': item.imageUrl
        }));
    var index = _list.indexWhere((element) => element.id == id);
    _list[index] = item;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/products/$id.json?auth=$_token');
    final productIndex = _list.indexWhere((element) => element.id == id);
    final product = _list[productIndex];
    _list.removeWhere((element) => element.id == id);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _list.insert(productIndex, product);
      notifyListeners();
      throw const HttpException('could not delete');
    }
  }

  Product productWithId(String id) {
    return _list.firstWhere((element) => element.id == id);
  }
}
