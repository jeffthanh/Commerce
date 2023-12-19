import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  static const routerName = '/change-password';

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String message = '';

  Future<void> changePassword() async {
    final String apiUrl = 'http://10.13.129.222:3000/user/password';

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedToken = prefs.getString('jwt');

      if (savedToken == null) {
        setState(() {
          message = 'Token không tồn tại. Vui lòng đăng nhập.';
        });
        return;
      }

      if (newPasswordController.text != confirmPasswordController.text) {
        setState(() {
          message = 'Mật khẩu mới và xác nhận mật khẩu không trùng khớp.';
        });
        return;
      }

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $savedToken',
        },
        body: jsonEncode({'password': newPasswordController.text}),
      );

      if (response.statusCode == 200) {
        setState(() {
          message = 'Đổi mật khẩu thành công';
        });
      } else {
        setState(() {
          message = 'Lỗi trong quá trình đổi mật khẩu';
          print('Nội dung phản hồi: ${response.body}');
        });
      }
    } catch (error) {
      setState(() {
        message = 'Lỗi trong quá trình đổi mật khẩu';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đổi mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
              ),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: changePassword,
              child: Text('Đổi mật khẩu'),
            ),
            SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
