import 'package:client/models/product_model.dart';
import 'package:client/providers/cart_provider.dart';
import 'package:client/providers/product_provider.dart';
import 'package:client/screens/home/cart/cart.dart';
import 'package:client/screens/home/product/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class ProductSearchPage extends StatefulWidget {
  static const routerName = '/search';
  
  const ProductSearchPage({Key? key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearchPage> {
  TextEditingController searchController = TextEditingController();
  String? searchQuery;
  late Future<List<Product>> productSearchFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Truy cập tham số arguments và cập nhật giá trị tìm kiếm
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      searchQuery = args;
      searchController.text = searchQuery!;
      final productProvider = Provider.of<ProductProvider>(context);
      productSearchFuture = productProvider.getProductSearch(searchQuery!);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(searchQuery ?? ''), // Hiển thị thông tin tìm kiếm trên AppBar
        actions: [
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
        ],
      ),
      body: FutureBuilder<List<Product>>(
        initialData: const [],
        future: productSearchFuture,
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
                            data[index].price.toString() + ' VND',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          // Lấy CartProvider
                          var cartProvider =
                              Provider.of<CartProvider>(context, listen: false);

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
                              content: Text('Đã thêm sản phẩm vào giỏ hàng'),
                            ),
                          );
                        },
                        icon: Icon(Icons.shopping_cart),
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(data[index].images[0]),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
