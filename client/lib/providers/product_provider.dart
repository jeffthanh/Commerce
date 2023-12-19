import 'dart:convert';

import 'package:client/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductProvider extends ChangeNotifier {
  List<Product> productSpecial = [];
  List<Product> productSearch = [];

  Future<List<Product>> getProductSpecial() async {
    const url = 'http://192.168.1.31:5000/product?special=true';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);
      List<Product> data = List<Product>.from(
              jsonData.map((product) => Product.fromJson(jsonEncode(product))))
          .toList();
      productSpecial = data;
      return data;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Product>> getProductSearch(String search) async {
    final encodedSearch = Uri.encodeComponent(
        search); // Đảm bảo rằng tìm kiếm không chứa ký tự đặc biệt
    final url = 'http://192.168.1.31:5000/product?name=$encodedSearch';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);
      List<Product> data = List<Product>.from(
              jsonData.map((product) => Product.fromJson(jsonEncode(product))))
          .toList();
      productSearch = data;
      return data;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Product>> getProduct() async {
    const url = 'http://192.168.1.31:5000/product';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);
      List<Product> data = List<Product>.from(
              jsonData.map((product) => Product.fromJson(jsonEncode(product))))
          .toList();
      print(data);
      return data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Product?> getProductById(String productId) async {
    // Gọi API hoặc thực hiện các thao tác để lấy thông tin sản phẩm dựa vào ID
    // Ở đây, giả định rằng bạn sử dụng http package để gọi API
    final response = await http
        .get(Uri.parse('http://192.168.1.31:5000/product/$productId'));

    if (response.statusCode == 200) {
      // Chuyển đổi dữ liệu nhận được từ API thành thông tin sản phẩm
      final Map<String, dynamic> productData = json.decode(response.body);

      // Trả về đối tượng Product hoặc null nếu không tìm thấy sản phẩm
      return Product.fromMap(productData);
    } else {
      // Xử lý lỗi khi gọi API không thành công
      return null;
    }
  }
}
