import 'dart:convert';
import 'dart:io';
import 'package:client/models/category_model.dart';
import 'package:client/providers/category_provider.dart';
import 'package:client/screens/admin/category/category_admin.dart';
import 'package:client/screens/admin/product/product_admin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AddProduct extends StatefulWidget {
  static const routerName = '/addProduct';

  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productdescriptionController = TextEditingController();
  TextEditingController productpercentController = TextEditingController();
  TextEditingController productslController = TextEditingController();

  bool? isSpecial; // Mặc định sản phẩm
  Category? selectedCategory; // Thêm biến này để theo dõi danh mục đã chọn

  List<XFile>? selectedImages; // Danh sách hình ảnh đã chọn
  bool _isLoading = false; // Thêm biến _isLoading
  bool imageSelected = false;

  Future<void> _selectImages() async {
    final imagePicker = ImagePicker();
    List<XFile>? pickedFiles = await imagePicker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final imagePaths = pickedFiles
          .map((image) => image.path)
          .toList(); // Chuyển đổi XFile thành đường dẫn tệp

      setState(() {
        selectedImages = pickedFiles;
        imageSelected = true;
      });
    }
  }

  bool _validateInput() {
    return productNameController.text.isNotEmpty &&
        productPriceController.text.isNotEmpty &&
        productpercentController.text.isNotEmpty &&
        selectedCategory != null &&
        imageSelected;
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });
    if (!imageSelected) {
      _isLoading = false;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi: Vui lòng chọn hình ảnh'),
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
    if (!_validateInput()) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi: Vui lòng nhập đầy đủ thông tin'),
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

    final productName = productNameController.text;
    final productprice = int.tryParse(productPriceController.text);
    final precent = int.tryParse(productpercentController.text);
    final sl = int.tryParse(productslController.text);
    final description = productdescriptionController.text;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('jwt');

    if (savedToken == null) {
      // Token không tồn tại hoặc đã hết hạn, xử lý tùy theo logic của bạn.
      // Ví dụ: Đăng xuất người dùng.
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
        // Tải lên các hình ảnh
        final cloudinaryImageUrls = await uploadImagesToCloudinary(
          selectedImages!.map((image) => image.path).toList(),
        );
        print(cloudinaryImageUrls);
        if (cloudinaryImageUrls.isNotEmpty) {
          setState(() {
            _isLoading = false;
          });
          final success = await saveDataToApi(
            productName,
            cloudinaryImageUrls, // Chuyển danh sách URL hình ảnh
            productprice!,
            sl!,
            precent!,
            description,
            selectedCategory!.id, // Chuyển ID của danh mục
            isSpecial!,
            savedToken,
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Lưu thành công'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ProductAdmin(),
                      ));
                    },
                    child: Text('Đóng'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Xử lý khi người dùng không có quyền admin
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Không có quyền admin'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => ProductAdmin(),
                    ));
                  },
                  child: Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Xử lý khi có lỗi xảy ra trong quá trình giải mã token
      print('Lỗi giải mã token: $e');
      // Có thể đăng xuất người dùng ở đây nếu cần.
    }
  }

  Future<List<String>> uploadImagesToCloudinary(List<String> imagePaths) async {
    final cloudName = 'dqbeplqtc'; // Thay thế bằng tên Cloudinary của bạn
    final apiKey = '375441668363381'; // Thay thế bằng API Key của bạn
    final apiSecret =
        '63FpgwhEEoT3qogAWO_IYq8w0eQ'; // Thay thế bằng API Secret của bạn

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
    final List<String> cloudinaryImageUrls = [];
    print(imagePaths);

    for (final imagePath in imagePaths) {
      final file = File(imagePath);

      if (!file.existsSync()) {
        // Xử lý nếu tệp không tồn tại
        continue; // Bỏ qua tệp không tồn tại và tiếp tục với tệp tiếp theo (nếu có).
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType.parse(lookupMimeType(imagePath) ?? 'image/jpg'),
      ));

      request.fields['upload_preset'] = 'curghrze';

      final basicAuth =
          'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';
      request.headers['authorization'] = basicAuth;

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseJson = await response.stream.bytesToString();
        final data = jsonDecode(responseJson);
        final imageUrl = data['secure_url'];
        print(imageUrl);
        cloudinaryImageUrls.add(imageUrl);
      }
    }

    return cloudinaryImageUrls; // Trả về danh sách đường dẫn sau khi đã cập nhật
  }

  Future<bool> saveDataToApi(
      String productName,
      List<String> imageUrl, // Danh sách URL hình ảnh
      int price,
      int sl,
      int percent,
      String description,
      String category,
      bool special,
      String token) async {
    final url = 'http://192.168.1.31:5000/product';

    final Map<String, dynamic> requestData = {
      'name': productName,
      'images': imageUrl, // Danh sách URL hình ảnh
      'price': price,
      'sl' :sl,
      'special': special,
      'description': description,
      'category': category,
      'percent': percent
    };

    final String requestBody = jsonEncode(requestData);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(requestBody);
      print('Phản hồi từ API: ${response.body}');
      print('Mã trạng thái của phản hồi: ${response.statusCode}');

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Sản Phẩm'),
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
          var data = snapshot.data! as List<Category>;

          return snapshot.hasData
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: productNameController,
                          decoration:
                              InputDecoration(labelText: 'Tên sản phẩm'),
                        ),
                        TextField(
                          controller: productPriceController,
                          decoration:
                              InputDecoration(labelText: 'Giá sản phẩm'),
                        ),
                        TextField(
                          controller: productdescriptionController,
                          decoration:
                              InputDecoration(labelText: 'Nội dung sản phẩm'),
                          maxLines: null, // Cho phép nhiều dòng
                        ),
                        TextField(
                          controller: productslController,
                          decoration:
                              InputDecoration(labelText: 'Số lượng'),
                        ),
                        TextField(
                          controller: productpercentController,
                          decoration:
                              InputDecoration(labelText: 'Phần Trăm giảm giá'),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Text(
                                'Đặc biệt:',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              DropdownButton<bool>(
                                value: isSpecial,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isSpecial = value;
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('Đặc biệt'),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('Không đặc biệt'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Text(
                                'Danh mục:',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              DropdownButton<String>(
                                value: selectedCategory
                                    ?.id, // Sử dụng id của danh mục làm giá trị
                                onChanged: (String? value) {
                                  // Tìm danh mục tương ứng với giá trị đã chọn
                                  final selected = data.firstWhere(
                                      (category) => category.id == value);
                                  setState(() {
                                    selectedCategory = selected;
                                  });
                                },
                                items: data.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category
                                        .id, // Sử dụng id của danh mục làm giá trị
                                    child: Text(category.name),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _selectImages,
                          child: Text('Chọn Hình Ảnh'),
                        ),
// Hiển thị các hình ảnh đã chọn
                        if (selectedImages != null &&
                            selectedImages!.isNotEmpty)
                          Container(
                            height:
                                150, // Đặt chiều cao của Container cho phù hợp
                            child: ListView.builder(
                              scrollDirection:
                                  Axis.horizontal, // Để hình ảnh nằm ngang
                              itemCount: selectedImages!.length,
                              itemBuilder: (context, index) {
                                final image = selectedImages![index];
                                return Image.file(
                                  File(image.path),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),

                        ElevatedButton(
                          onPressed: _pickImage,
                          child: _isLoading
                              ? Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                )
                              : Text('Lưu'),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Text('Empty Product'),
                );
        },
      ),
    );
  }
}
