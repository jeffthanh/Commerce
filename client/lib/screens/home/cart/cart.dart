import 'package:client/helper/alert.dart';
import 'package:client/models/product_model.dart';
import 'package:client/providers/cart_provider.dart';
import 'package:client/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  static const routerName = '/cart';
  const CartPage({Key? key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final itemsData = Provider.of<CartProvider>(context);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang giỏ hàng'),
        actions: <Widget>[
          // Hiển thị giá trị tổng ở đây
          Padding(
            padding: const EdgeInsets.only(top: 19),
            child: Text(
              'Tổng: ${intl.NumberFormat.currency(locale: 'vi', symbol: 'VND', decimalDigits: 0).format(itemsData.totalAmount())}',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      body: itemsData.items.isNotEmpty
          ? Stack(
              children: [
                Positioned.fill(
                  child: Consumer<CartProvider>(
                    builder: (context, value, child) {
                      var dataItem = value.items.values.toList();
                      return ListView.separated(
                        itemBuilder: ((context, index) {
                          return ListTile(
                            leading: Image(
                              image: NetworkImage(dataItem[index].image),
                              fit: BoxFit.fill,
                            ),
                            title: Text(
                              dataItem[index].name,
                              maxLines: 2,
                            ),
                            subtitle: Text(
                              intl.NumberFormat.simpleCurrency(
                                locale: 'vi',
                                decimalDigits: 0,
                              ).format(dataItem[index].price),
                            ),
                            trailing: SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .decrease(
                                              value.items.keys.toList()[index]);
                                    },
                                    child: const Icon(Icons.remove),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      '${dataItem[index].quantity}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .increase(
                                              value.items.keys.toList()[index]);
                                    },
                                    child: const Icon(Icons.add),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                        separatorBuilder: (((context, index) {
                          return const Divider();
                        })),
                        itemCount: value.items.length,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        List<CartItem> purchasedItems =
                            itemsData.items.values.toList();

                        // Kiểm tra số lượng sản phẩm trong giỏ hàng
                        List<Product> insufficientProducts =
                            await checkProductQuantity(purchasedItems);

                        if (insufficientProducts.isEmpty) {
                          // Số lượng sản phẩm đủ, tiến hành thanh toán
                          Navigator.of(context)
                              .pushNamed('/payment', arguments: purchasedItems);
                          itemsData.removeItems();
                        } else {
                          // Hiển thị thông báo về sản phẩm không đủ số lượng
                          String message = 'Số lượng sản phẩm sau không đủ:';
                          for (var product in insufficientProducts) {
                            message +=
                                '\n- ${product.name} (Số lượng còn lại: ${product.sl})';
                          }
                          showAlertDialog(context, 'Thông báo', message);
                        }
                      },
                      child: const Text('Xác nhận Thanh Toán'),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              child: Center(
                child: Text('Không có sản phẩm nào'),
              ),
            ),
    );
  }
}

void showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
