import 'dart:convert';

import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String image;
  final String name;
  final int price;
  final int quantity;

  CartItem({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    required this.quantity,
  });
   Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['_id'] as String, // Chuyển đổi '_id' thành 'id'
      name: map['name'] as String,
      image: map['image'] as String,
      price: map['price'] as int,
      quantity: map['quantity'] as  int
    );
  }

  String toJson() => json.encode(toMap());

  factory CartItem.fromJson(String source) =>
      CartItem.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CartProvider extends ChangeNotifier {
  Map<String, CartItem> items = {};
  void addCart(String productId, String image, String name, int price,
      [int quantity = 1]) {
    if (items.containsKey(productId)) {
      // Sản phẩm đã tồn tại trong giỏ hàng, cập nhật số lượng
      increase(productId, quantity);
    } else {
      // Sản phẩm chưa tồn tại, thêm mới vào giỏ hàng
      items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          image: image,
          name: name,
          price: price,
          quantity: quantity,
        ),
      );
      notifyListeners();
    }
  }

  void increase(String productId, [int quantity = 1]) {
    items.update(
      productId,
      (value) => CartItem(
        id: value.id,
        image: value.image,
        name: value.name,
        price: value.price,
        quantity: value.quantity + quantity,
      ),
    );
    notifyListeners();
  }

  void decrease(String productId, [int quantity = 1]) {
    if (items[productId]?.quantity == quantity) {
      items.removeWhere((key, value) => key == productId);
    } else {
      items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          image: value.image,
          name: value.name,
          price: value.price,
          quantity: value.quantity - quantity,
        ),
      );
    }

    notifyListeners();
  }

  void removeItems() {
    items = {};
    notifyListeners();
  }

  double totalAmount() {
    var total = 0.0;
    items.forEach((key, CartItem) {
      total += CartItem.price * CartItem.quantity;
    });
    return total;
  }

}
