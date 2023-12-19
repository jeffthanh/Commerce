import 'package:client/providers/cart_provider.dart';
import 'package:client/screens/home/cart/cart.dart';
import 'package:client/screens/home/category/widget/category_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  static const routerName = '/category';

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool login = false;

  @override
  void initState() {
    super.initState();
    checkTokenAndLogin();
  }

  Future<void> checkTokenAndLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token != null && token.isNotEmpty) {
      // A valid token exists, set login to true
      setState(() {
        login = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arg =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(arg['name']),
         actions: login ? [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 15),
            child: Consumer<CartProvider>(
              builder: (context, value, child) {
                return badges.Badge(
                  badgeContent: Text('${value.items.length}'),
                  position: badges.BadgePosition.topEnd(top: -10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, CartPage.routerName);
                    },
                    child: const Icon(Icons.shopping_cart),
                  ),
                );
              },
            ),
          )
        ] : []
      ),
      body: const CategoryBody(),
    );
  }
}
