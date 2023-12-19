import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderProvider extends ChangeNotifier {
  Future<List<Map<String, dynamic>>> getOrder(String id) async {
    final url = 'http://192.168.1.31:5000/order/$id';

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
      if (jsonData is List) {
        // Kiểm tra xem dữ liệu trả về có phải là một danh sách
        // Nếu đúng, chuyển nó sang kiểu dữ liệu bạn mong muốn và trả về
        final List<Map<String, dynamic>> orderList =
            List<Map<String, dynamic>>.from(jsonData);
        return orderList;
      } else {
        return Future.error('Dữ liệu không hợp lệ');
      }
    } catch (e) {
      // Xử lý lỗi nếu có lỗi xảy ra trong quá trình gửi yêu cầu hoặc xử lý dữ liệu
      return Future.error('Lỗi: $e');
    }
  }

}
