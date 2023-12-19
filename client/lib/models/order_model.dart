import 'dart:convert';

import 'package:client/providers/cart_provider.dart';

class Order {
  final Map<String, dynamic> userData;
  final List<CartItem> purchasedItems;
  final String notification;
  final double totalAmount;

  Order({
    required this.userData,
    required this.purchasedItems,
    required this.notification,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userData': userData,
      'purchasedItems': purchasedItems.map((item) => item.toMap()).toList(),
      'notification': notification,
      'totalAmount': totalAmount,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      userData: map['userData'] as Map<String, dynamic>,
      purchasedItems: (map['purchasedItems'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      notification: map['notification'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);
}
