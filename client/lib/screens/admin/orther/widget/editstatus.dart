import 'dart:convert';
import 'dart:ffi';

import 'package:client/models/order_model.dart';
import 'package:client/screens/admin/orther/orther_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateStatus extends StatefulWidget {
  static const routerName = '/editstatus';
  final Map<String, dynamic> order;

  const UpdateStatus({Key? key, required this.order}) : super(key: key);

  @override
  State<UpdateStatus> createState() => _UpdateStatusState();
}

class _UpdateStatusState extends State<UpdateStatus> {
  bool _isLoading = false; // Thêm biến _isLoading

  String selectedStatus = ''; // Trạng thái mặc định

  @override
  void initState() {
    super.initState();
    // Khởi tạo selectedStatus bằng giá trị status từ widget.order
    selectedStatus = widget.order['status'];
  }

  Future<void> _updatastatus() async {
    setState(() {
      _isLoading = true;
    });
    final orderId = widget.order['_id'];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('jwt');

    if (savedToken == null) {
      // Token không tồn tại, xử lý lỗi hoặc đăng xuất người dùng
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi: Token không tồn tại hoặc đã hết hạn'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Token tồn tại, tiếp tục xử lý
    try {
      if (savedToken != null) {
        final Map<String, dynamic> payload = JwtDecoder.decode(savedToken);

        if (payload['role'] == 'admin') {
          final success =
              await putDataToApi(orderId, selectedStatus, savedToken);
          print(success);
          if (success && selectedStatus == 'Thành công') {
            await updateProductInfo(widget.order['products'], savedToken);
            // print('object');
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Lưu thành công'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => OrderList(),
                      ));
                    },
                    child: Text('Đóng'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Lỗi khi gửi yêu cầu lên máy chủ');
        }
      }
    } catch (e) {
      print('Lỗi giải mã token: $e');
    }
  }

  Future<bool> putDataToApi(String id, String status, String token) async {
    final url = 'http://192.168.1.31:5000/order/$id';

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

  Future<void> updateProductInfo(List<dynamic> products, String token) async {
  for (var product in products) {
    var productInfo = await getProductInfoById(product['id'], token);
    print(productInfo);
    if (productInfo['sl'] != null && product['quantity'] != null) {
      productInfo['sl'] -= product['quantity'];
      print(productInfo['sl']);
      await updateProductInfoById(productInfo['sl'],product['id'], token);
    } else {
      print('Lỗi: Giá trị quantity không hợp lệ');
    }
  }
}


  Future<Map<String, dynamic>> getProductInfoById(
      String productId, String token) async {
    final url = 'http://192.168.1.31:5000/product/$productId';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Lỗi khi lấy thông tin sản phẩm từ API');
      return Map<String, dynamic>();
    }
  }

  Future<void> updateProductInfoById(
      int productInfo,String id, String token) async {
    final url = 'http://192.168.1.31:5000/product/sl/$id';

    final String requestBody = jsonEncode({
      'sl':productInfo
    });

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode != 200) {
      print('Lỗi khi cập nhật thông tin sản phẩm từ API');
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                            'Giá: ${formatPrice(product['price'].toDouble())}'),
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
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: selectedStatus,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                        items: <String>[
                          'Chờ xử lý',
                          'Đang giao hàng',
                          'Thành công',
                          'Đã hủy'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Thời gian đặt hàng:',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(widget.order['orderDate'])
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
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _updatastatus,
                  child: Text('Lưu'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
