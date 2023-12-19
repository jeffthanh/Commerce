import 'dart:convert';

import 'package:client/models/category_model.dart';
import 'package:client/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryProvider extends ChangeNotifier {
  Future<List<Category>> getCategory() async {
    const url = 'http://192.168.1.31:5000/category';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);
      List<Category> data = List<Category>.from(
          jsonData.map((category) => Category.fromJson(jsonEncode(category)))).toList();
      return data;
    } catch (e) {
      // Xử lý lỗi ở đây nếu cần
      return [];
    }
  }

  Future<List<Product>> getProductCategory(String id) async {
    final url = 'http://192.168.1.31:5000/category/$id';
    Uri uri = Uri.parse(url);
    final finalUri = uri.replace(queryParameters: {});
    try {
      final response = await http.get(finalUri);
      print(response);
      final jsonData = jsonDecode(response.body);
      print(jsonData);
      List<Product> data = List<Product>.from(
              jsonData.map((product) => Product.fromJson(jsonEncode(product)))).toList();
         
      print(data);
      return data;
    } catch (e) {
      return Future.error(e);
    }
  }
}
