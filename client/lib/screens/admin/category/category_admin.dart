import 'package:client/providers/category_provider.dart';
import 'package:client/screens/admin/category/widget/add_category.dart';
import 'package:client/screens/admin/category/widget/edit_category.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class CategoryAdmin extends StatefulWidget {
  static const routerName = '/categoryadmin';
  const CategoryAdmin({Key? key});

  @override
  State<CategoryAdmin> createState() => _CategoryAdminState();
}

class _CategoryAdminState extends State<CategoryAdmin> {
  bool _isLoading = false;

  Future<void> deleteCategory(String categoryId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa danh mục này?'),
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
                final SharedPreferences prefs = await SharedPreferences.getInstance();
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
                  final Map<String, dynamic> payload = JwtDecoder.decode(savedToken);

                  if (payload['role'] == 'admin') {
                    final url = 'http://192.168.1.31:5000/category/$categoryId';

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
                      Navigator.of(context).pushReplacement('/categoryadmin' as Route<Object?>);
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
        title: Text('Danh Mục'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Provider.of<CategoryProvider>(context).getCategory(),
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
                        print('Selected category Id: ${data[index].id}');

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => EditCategory(
                            categoryId: data[index].id,
                            categoryName: data[index].name,
                            categoryImage: data[index].image,
                          ),
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                        ),
                        margin: EdgeInsets.all(2),
                        child: ListTile(
                          trailing: IconButton(
                            onPressed: () {
                              final categoryId = data[index].id;
                              deleteCategory(categoryId);
                            },
                            icon: Icon(Icons.delete),
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                            child: Image.network(
                              '${data[index].image}',
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            '${data[index].name}',
                            maxLines: 2,
                          ),
                        ),
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
                  child: Text('Empty Category'),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AddCategory(),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
