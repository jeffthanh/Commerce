import 'package:client/providers/cart_provider.dart';
import 'package:client/providers/product_provider.dart';
import 'package:client/screens/home/product/product.dart';
import 'package:client/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class ListProductSpecial extends StatelessWidget {
  final bool login; // Thêm tham số login

  const ListProductSpecial({Key? key, required this.login}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: FutureBuilder(
        future: Provider.of<ProductProvider>(context).getProductSpecial(),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var data = snapshot.data! as List;
          return snapshot.hasData
              ? ListView.separated(
                  itemBuilder: ((context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ProductPage.routerName,
                          arguments: {"data": data[index]},
                        );
                      },
                      child: ListTile(
                        leading: Image(
                          image: NetworkImage('${data[index].images[0]}'),
                          fit: BoxFit.fill,
                        ),
                        title: Text(
                          '${data[index].name}',
                          maxLines: 2,
                        ),
                        subtitle: Text(intl.NumberFormat.simpleCurrency(
                                locale: 'vi', decimalDigits: 0)
                            .format(data[index].price)),
                        trailing: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: login
                                ? InkWell(
                                    onTap: () {
                                      // Lấy CartProvider
                                      var cartProvider =
                                          Provider.of<CartProvider>(context,
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Đã thêm sản phẩm vào giỏ hàng'),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                        Icons.shopping_cart_checkout),
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
                    );
                  }),
                  separatorBuilder: ((context, index) {
                    return const Divider(
                      height: 1,
                    );
                  }),
                  itemCount: data.length,
                )
              : const Center(
                  child: Text('Empty Product'),
                );
        },
      ),
    );
  }
}
