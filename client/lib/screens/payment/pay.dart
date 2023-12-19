import 'package:client/providers/cart_provider.dart';
import 'package:client/providers/user_provider.dart';
import 'package:client/screens/payment/widget/body_pay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/models/UsersModel.dart';

class PaymentPage extends StatefulWidget {
  static const routerName = '/payment';

  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading =
      false; // Biến để kiểm tra xem yêu cầu POST đang được thực hiện hay không

  @override
  Widget build(BuildContext context) {
    final List<CartItem> purchasedItems =
        ModalRoute.of(context)!.settings.arguments as List<CartItem>;
    final userData = Provider.of<UserProvider>(context).getUser();
    print(userData);
    print(purchasedItems);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh Toán'),
        centerTitle: true,
      ),
      body: BodyPayment(purchasedItems: purchasedItems),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.blue),
          child: TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    // Wait for the userData Future to resolve and then call handlePurchase
                    final Map<String, dynamic> user = await userData;
                    handlePurchase(purchasedItems, user);
                    Navigator.pushReplacementNamed(context, '/listOder'); // Thay '/invoice' bằng đường dẫn đến trang hóa đơn của bạn

                  },
            child: isLoading
                ? CircularProgressIndicator() // Hiển thị CircularProgressIndicator khi đang xử lý
                : Text('Mua hàng', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // Hàm xử lý việc mua hàng và gửi yêu cầu POST lên API
  void handlePurchase(
      List<CartItem> purchasedItems, Map<String, dynamic> userData) async {
    setState(() {
      isLoading = true; // Bắt đầu xử lý, đặt isLoading thành true
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('jwt');

    // Kiểm tra xem savedToken có tồn tại
    if (savedToken == null) {
      setState(() {
        isLoading = false; // Kết thúc xử lý, đặt isLoading thành false
      });
      print('Token not found. Please authenticate the user.');
      // Hiển thị thông báo lỗi hoặc thực hiện hành động xác thực khác tùy ý
      return;
    }

    final apiUrl =
        'http://192.168.1.31:5000/order'; // Thay thế bằng URL thực tế của API

    // Create a JSON object containing the data to send
    final jsonData = {
      'products': purchasedItems.map((item) {
        return {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'image':item.image,
        };
      }).toList(),
      'customer': {
        'address': userData['address'],
        'fullname': userData['fullname'],
        'phone': userData['phone'],
        '_id': userData['_id'],
      },
    };

    print(jsonData);

    // Send a POST request to the API with the Authorization header containing the token
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'Bearer $savedToken', // Thêm Token vào tiêu đề Authorization
      },
      body: jsonEncode(jsonData),
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Successful response from the API
      print('Purchase successful');
      // Thực hiện hành động sau khi mua hàng thành công (ví dụ: hiển thị thông báo)

      setState(() {
        isLoading = false; // Kết thúc xử lý, đặt isLoading thành false
      });
    } else {
      // Handle the error response from the API
      print('Purchase failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      // Xử lý lỗi (ví dụ: hiển thị thông báo lỗi)

      setState(() {
        isLoading = false; // Kết thúc xử lý, đặt isLoading thành false
      });
    }
  }
}
