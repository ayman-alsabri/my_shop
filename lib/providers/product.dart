import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  bool isFavorite;

  Product({
    required this.description,
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.title,
    this.isFavorite = false,
  });

  Future<void> changeIsFavorite(String? token, String? usrtId) async {
    final url = Uri.parse(
        'https://my-shop-6c328-default-rtdb.firebaseio.com/$usrtId/$id.json?auth=$token');
    final currentStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response =
          await http.put(url, body: jsonEncode(isFavorite));

      if (response.statusCode >= 400) {
        isFavorite = currentStatus;

        notifyListeners();
        throw HttpException('');
      }
    } catch (error) {
      isFavorite = currentStatus;
      notifyListeners();
      rethrow;
    }
  }
}
