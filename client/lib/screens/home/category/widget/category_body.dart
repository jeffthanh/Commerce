import 'package:client/providers/cart_provider.dart';
import 'package:client/providers/category_provider.dart';
import 'package:client/screens/home/product/product.dart';
import 'package:client/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryBody extends StatefulWidget {
  const CategoryBody({Key? key}) : super(key: key);

  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> {
  late Future<List> productInCategoryFuture;
  bool login = false;

  @override
  void initState() {
    super.initState();
    checkTokenAndLogin();
  }

  String formatPrice(int price) {
    final currencyFormatter = NumberFormat("#,##0", "vi_VN");
    return currencyFormatter.format(price);
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
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final categoryId = args['id'];
    final categoryProvider = Provider.of<CategoryProvider>(context);

    productInCategoryFuture = categoryProvider.getProductCategory(categoryId);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      initialData: const [],
      future: productInCategoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }

        final data = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 3 / 4,
          ),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ProductPage.routerName,
                  arguments: {"data": data[index]},
                );
              },
              child: GridTile(
                footer: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: GridTileBar(
                      backgroundColor: Colors.black45,
                      title: Text(data[index].name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Giảm ${data[index].percent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${formatPrice(data[index].price)} VND',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      trailing: login
                          ? IconButton(
                              onPressed: () {
                                // Lấy CartProvider
                                var cartProvider = Provider.of<CartProvider>(
                                    context,
                                    listen: false);

                                // Thêm sản phẩm vào giỏ hàng
                                cartProvider.addCart(
                                  data[index]
                                      .id
                                      .toString(), // productId (chuyển sang chuỗi)
                                  data[index].images[0], // image
                                  data[index].name, // name
                                  data[index].price, // price
                                );

                                // Hiển thị snackbar để thông báo sản phẩm đã được thêm vào giỏ hàng
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Đã thêm sản phẩm vào giỏ hàng'),
                                  ),
                                );
                              },
                              icon: Icon(Icons.shopping_cart),
                            )
                          : IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                              icon: Icon(Icons.shopping_cart_checkout))),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(data[index].images[0]),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
