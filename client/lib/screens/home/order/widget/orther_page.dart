import 'dart:convert';

import 'package:client/models/order_model.dart';
import 'package:client/screens/admin/orther/orther_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  static const routerName = '/pageorder';
  final Map<String, dynamic> order;

  const OrderPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderPage> createState() => _UpdateStatusState();
}

class _UpdateStatusState extends State<OrderPage> {
  bool _isLoading = false; // Thêm biến _isLoading

  String selectedStatus = ''; // Trạng thái mặc định

  @override
  void initState() {
    super.initState();
    // Khởi tạo selectedStatus bằng giá trị status từ widget.order
    selectedStatus = widget.order['status'];
  }

  Future<bool> putDataToApi(String id, String status, String token) async {
    final url =
        'http://192.168.1.31:5000/order/$id'; // Sửa thành cách dùng $id thay vì ':id'

    final Map<String, dynamic> requestData = {
      'status': status,
    };

    final String requestBody = jsonEncode(requestData);

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(requestBody);
      print('Phản hồi từ API: ${response.body}');
      print('Mã trạng thái của phản hồi: ${response.statusCode}');
      return false;
    }
  }

  int calculateTotalQuantity(List<dynamic> products) {
    int totalQuantity = 0;
    for (var product in products) {
      if (product['quantity'] is int) {
        totalQuantity += (product['quantity'] as int);
      }
    }
    return totalQuantity;
  }

  double calculateTotalPrice(List<dynamic> products) {
    double totalPrice = 0;
    for (var product in products) {
      if (product['quantity'] is int && product['price'] is int) {
        totalPrice += (product['quantity'] as int) * (product['price'] as int);
      } else {
        print('Sản phẩm không hợp lệ: $product');
      }
    }
    return totalPrice;
  }

  String formatPrice(double price) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi', symbol: '₫', decimalDigits: 0);
    return currencyFormatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic products = widget.order['products'];
    final dynamic person = widget.order['customer'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin đơn hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            for (var product in products) ...[
              if (product['image'] != null &&
                  product['name'] != null &&
                  product['quantity'] != null &&
                  product['price'] != null)
                ListTile(
                  leading: Image.network(product['image']),
                  title: Text('Tên sản phẩm: ${product['name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số lượng: ${product['quantity']}'),
                      Text('Giá: ${product['price']}'),
                    ],
                  ),
                ),
              Divider(thickness: 3),
            ],
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trạng Thái:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.order['status'])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Thời gian đặt hàng:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${DateTime.parse(widget.order['orderDate']).day}/${DateTime.parse(widget.order['orderDate']).month}/${DateTime.parse(widget.order['orderDate']).year}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Họ và tên:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(person['fullname'])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Số điện thoại:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(person['phone'])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Địa chỉ:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(person['address'], maxLines: 2)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tổng số lượng:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(
                      calculateTotalQuantity(widget.order['products'])
                          .toString(),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng số tiền:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatPrice(
                          calculateTotalPrice(widget.order['products'])),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
