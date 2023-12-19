import 'package:client/models/product_model.dart';
import 'package:client/providers/cart_provider.dart';
import 'package:client/providers/product_provider.dart';
import 'package:client/screens/home/cart/cart.dart';
import 'package:client/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  static const routerName = '/product';
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int currentImageIndex = 0;
  int quantity = 1;
  bool login = false;

  @override
  void initState() {
    super.initState();
    checkTokenAndLogin();
  }

  Future<List<Product>> checkProductQuantity(List<CartItem> cartItems) async {
    List<Product> productsWithInsufficientQuantity = [];

    for (var item in cartItems) {
      var product = await ProductProvider().getProductById(item.id);

      if (product == null || item.quantity > product.sl) {
        productsWithInsufficientQuantity.add(product!);
      }
    }

    return productsWithInsufficientQuantity;
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
    final data = ModalRoute.of(context)!.settings.arguments as Map;
    final product = data['data'];
    final imageCount = product.images.length;
    final itemsData = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
            product.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          actions: login
              ? [
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
                ]
              : []),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300.0,
              child: PhotoViewGallery.builder(
                backgroundDecoration: BoxDecoration(color: Colors.white),
                itemCount: imageCount,
                pageController: PageController(initialPage: currentImageIndex),
                onPageChanged: (index) {
                  setState(() {
                    currentImageIndex = index;
                  });
                },
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(product.images[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 1,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng: ${intl.NumberFormat.currency(locale: 'vi', symbol: 'VND', decimalDigits: 0).format(product.price * quantity)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                icon: Icon(Icons.remove),
                              ),
                              Text(
                                quantity.toString(),
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                icon: Icon(Icons.add),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              login
                  ? ElevatedButton(
                      onPressed: () {
                        var cartProvider =
                            Provider.of<CartProvider>(context, listen: false);

                        // Thêm sản phẩm vào giỏ hàng với số lượng được hiển thị trong widget
                        cartProvider.addCart(
                          product.id
                              .toString(), // productId (chuyển sang chuỗi)
                          product.images[0], // image
                          product.name, // name
                          product.price, // price
                          quantity, // sử dụng quantity hiện tại trong widget
                        );
                        // Cập nhật lại giao diện với quantity mới
                        setState(() {
                          quantity =
                              1; // Đặt quantity về 1 sau khi thêm sản phẩm
                        });

                        // Hiển thị snackbar để thông báo sản phẩm đã được thêm vào giỏ hàng
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm sản phẩm vào giỏ hàng'),
                          ),
                        );
                      },
                      child: Text(
                        'Thêm vào giỏ hàng',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ElevatedButton(
                      child: Text('Thêm vào giỏ hàng'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
              login
                  ? ElevatedButton(
                      onPressed: () async {
                        // Lấy danh sách sản phẩm đã mua từ Provider
                        List<CartItem> purchasedItems = [
                          CartItem(
                            id: product.id.toString(),
                            image: product.images[0],
                            name: product.name,
                            price: product.price,
                            quantity: quantity,
                          ),
                        ];

                        // Kiểm tra số lượng sản phẩm trong giỏ hàng
                        List<Product> insufficientProducts =
                            await checkProductQuantity(purchasedItems);

                        if (insufficientProducts.isEmpty) {
                          // Số lượng sản phẩm đủ, tiến hành thanh toán
                          // Chuyển đến trang thanh toán và truyền danh sách sản phẩm
                          Navigator.of(context)
                              .pushNamed('/payment', arguments: purchasedItems);

                          // Xóa các sản phẩm đã thanh toán khỏi giỏ hàng
                        } else {
                          // Số lượng sản phẩm không đủ, hiển thị thông báo
                           String message = 'Số lượng sản phẩm sau không đủ:';
                          for (var product in insufficientProducts) {
                            message +=
                                '\n- ${product.name} (Số lượng còn lại: ${product.sl})';
                          }
                          showAlertDialog(context, 'Thông báo', message);
                        }
                      },
                      child: Text(
                        'Mua ngay',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('Mua ngay'))
            ],
          ),
        ),
      ),
    );
  }
}
