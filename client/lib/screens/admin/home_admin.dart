import 'package:client/screens/admin/widget/categorybody_admin.dart';
import 'package:client/screens/home/home.dart';
import 'package:client/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('jwt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('John Doe'), // Tên người dùng
              accountEmail: Text('john.doe@example.com'), // Email
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://res.cloudinary.com/dqbeplqtc/image/upload/v1696129643/thanhjs/logo_bqqqxl.jpg',
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue, // Màu nền của header
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Trang chủ'),
              onTap: () {
                // Navigate to the home page here
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()),
                );
              },
            ),
          
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                setState(() {
                  logOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Trang Admin'),
        centerTitle: true,
      ),
      body: CategoryAdminPage(),
    );
  }
}
