import 'package:client/providers/product_provider.dart';
import 'package:intl/intl.dart';

import 'package:client/screens/admin/product/widget/add_product.dart';
import 'package:client/screens/admin/product/widget/edit_product.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProductAdmin extends StatefulWidget {
  static const routerName = '/productadmin';
  const ProductAdmin({Key? key});

  @override
  State<ProductAdmin> createState() => _ProductAdminState();
}

class _ProductAdminState extends State<ProductAdmin> {
  bool _isLoading = false;

  String formatPrice(int price) {
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(price);
  }

  Future<void> deleteProduct(String productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                // Tiến hành xóa danh mục ở đây
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final savedToken = prefs.getString('jwt');

                if (savedToken == null) {
                  setState(() {
                    _isLoading = false;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Lỗi: Token không tồn tại hoặc đã hết hạn'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Đóng'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                try {
                  // Giải mã JWT token.
                  final Map<String, dynamic> payload =
                      JwtDecoder.decode(savedToken);

                  if (payload['role'] == 'admin') {
                    final url = 'http://192.168.1.31:5000/product/$productId';

                    final response = await http.delete(
                      Uri.parse(url),
                      headers: {
                        'Authorization': 'Bearer $savedToken',
                        'Content-Type': 'application/json',
                      },
                    );

                    if (response.statusCode == 200) {
                      // Xóa thành công
                      print('Danh mục đã được xóa.');
                      Navigator.of(context)
                          .pushReplacement('/productadmin' as Route<Object?>);
                    } else {
                      // Xử lý lỗi khi xóa danh mục
                      print('Lỗi xóa danh mục: ${response.statusCode}');
                    }
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  // Xử lý khi có lỗi xảy ra trong quá trình giải mã token
                  print('Lỗi giải mã token: $e');
                  // Có thể đăng xuất người dùng ở đây nếu cần.
                }

                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản Phẩm'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Provider.of<ProductProvider>(context).getProduct(),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var data = snapshot.data! as List;

          return snapshot.hasData
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: ((context, index) {
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => EditProduct(
                              productId: data[index].id,
                              productName: data[index].name,
                              productImage: data[index].images,
                              description: data[index].description,
                              productprice: data[index].price,
                              productsl: data[index].sl,
                              productpercent: data[index].percent,
                              isSpecial: data[index].special,
                            ),
                          ));
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                '${data[index].images[0]}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${data[index].name}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Giá: ${formatPrice(data[index].price)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),

                                    // Add more product information here
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final productId = data[index].id;
                                deleteProduct(productId);
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )
              : Center(
                  child: Text('Empty Product'),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AddProduct(),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
