import 'dart:convert';
import 'package:client/models/UsersModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> getUser() async {
    final url = 'http://192.168.1.31:5000/user';

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('jwt');

      if (savedToken == null) {
        // Token chưa được lưu hoặc đã hết hạn, xử lý tùy theo logic của bạn.
        // Ví dụ: Đăng xuất người dùng.
        return Future.error('Token không tồn tại hoặc đã hết hạn');
      }

      // Gửi yêu cầu với token của người dùng
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $savedToken',
        },
      );

      final jsonData = jsonDecode(response.body);
      print(jsonData);
      return jsonData; // Trả về dữ liệu JSON như bạn muốn
    } catch (e) {
      // Xử lý lỗi nếu có lỗi xảy ra trong quá trình gửi yêu cầu hoặc xử lý dữ liệu
      return Future.error('Lỗi: $e');
    }
  }

  Future<Map<String, dynamic>> updateUser(
      Map<String, dynamic> updatedUserData) async {
    final url =
        'http://192.168.1.31:5000/user/'; // Điều chỉnh URL cho API cập nhật người dùng

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('jwt');

      if (savedToken == null) {
        return Future.error('Token không tồn tại hoặc đã hết hạn');
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json', // Thiết lập loại nội dung là JSON
        },
        body: jsonEncode(
            updatedUserData), // Chuyển đổi dữ liệu cập nhật thành JSON
      );

      final jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Cập nhật thành công, trả về thông tin người dùng đã được cập nhật
        return jsonData;
      } else {
        // Xử lý lỗi nếu máy chủ trả về lỗi
        return Future.error(
            'Lỗi khi cập nhật thông tin người dùng: ${jsonData['message']}');
      }
    } catch (e) {
      // Xử lý lỗi nếu có lỗi xảy ra trong quá trình gửi yêu cầu hoặc xử lý dữ liệu
      return Future.error('Lỗi: $e');
    }
  }

}
