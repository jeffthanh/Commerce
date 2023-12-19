import 'dart:convert';
import 'package:client/screens/home/profile/widget/changepassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PasswordValidationPage extends StatefulWidget {
  static const routerName = '/check-password';

  @override
  _PasswordValidationPageState createState() => _PasswordValidationPageState();
}

class _PasswordValidationPageState extends State<PasswordValidationPage> {
  TextEditingController oldPasswordController = TextEditingController();
  String validationMessage = '';

  Future<void> validatePassword() async {
    final String apiUrl = 'http://192.168.1.31:5000/user/password';

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedToken = prefs.getString('jwt');

      if (savedToken == null) {
        setState(() {
          validationMessage = 'Token không tồn tại. Vui lòng đăng nhập.';
        });
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $savedToken',
        },
        body: jsonEncode({'oldPassword': oldPasswordController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['isValid']) {
          setState(() {
             Navigator.pushReplacementNamed(context, '/change-password');

          });
        } else {
          setState(() {
            validationMessage = 'Mật khẩu không hợp lệ';
          });
        }
      } else {
        setState(() {
          validationMessage = 'Mật khẩu không hợp lệ';
          print('Nội dung phản hồi: ${response.body}');
        });
      }
    } catch (error) {
      setState(() {
        validationMessage = 'Mật khẩu không hợp lệ';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kiểm tra mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nhập mật khẩu cũ',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: validatePassword,
              child: Text('Kiểm tra mật khẩu'),
            ),
            SizedBox(height: 20),
            Text(validationMessage),
          ],
        ),
      ),
    );
  }
}
