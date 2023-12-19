import 'package:client/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('jwt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              ClipRRect(
                // Sử dụng ClipRRect để bo góc
                borderRadius:
                    BorderRadius.circular(10.0), // Đặt bán kính để bo góc
                child: Image.network(
                  'https://res.cloudinary.com/dqbeplqtc/image/upload/v1695547474/thanhjs/fijkm7tj4y9zwrpoejco.jpg',
                  width: 80, // Đặt chiều rộng của hình ảnh
                  height: 80, // Đặt chiều cao của hình ảnh
                  fit: BoxFit.cover, // Đặt cách hiển thị hình ảnh
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Trang chủ'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.library_books),
                        title: const Text('Danh sách đơn hàng'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Đăng xuất'),
                        onTap: () {
                          setState(() {
                            logOut();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('hello'),
      ),
    );
  }
}
