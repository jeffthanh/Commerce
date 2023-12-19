import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartUser extends StatefulWidget {
  static const routerName = '/useradmin';

  const CartUser({Key? key}) : super(key: key);

  @override
  State<CartUser> createState() => _CartUserState();
}

class _CartUserState extends State<CartUser> {
  List<Map<String, dynamic>> allUsers = []; // Danh sách tất cả người dùng

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = 'http://192.168.1.31:5000/user/all';
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('jwt');

      if (savedToken == null) {
        return Future.error('Token không tồn tại hoặc đã hết hạn');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $savedToken',
        },
      );

      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        allUsers = List<Map<String, dynamic>>.from(jsonData);
        setState(() {});
      } else {
        return Future.error('Dữ liệu không hợp lệ');
      }
    } catch (e) {
      return Future.error('Lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách người dùng'),
      ),
      body: ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          final user = allUsers[index];
          return ListTile(
            onTap: () {
              // Navigate to the detailed view passing user details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsPage(user: user),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png'), // Replace with the actual image URL
            ),
            title: Text('Họ tên: ${user['_id']}'),
            subtitle: Text('Email: ${user['email']}'),
            // Add more information as needed
          );
        },
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết người dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserInfo('Họ tên:', user['fullname']),
            buildUserInfo('Email:', user['email']),
            buildUserInfo('Địa chỉ:', user['address']),
            buildUserInfo('Điện thoại:', user['phone']),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfo(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value ?? 'N/A', // Use 'N/A' if value is null
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}


