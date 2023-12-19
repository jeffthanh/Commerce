import 'dart:convert';
import 'dart:io';
import 'package:client/models/category_model.dart';
import 'package:client/providers/category_provider.dart';
import 'package:client/screens/admin/product/product_admin.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProduct extends StatefulWidget {
  static const routerName = '/editproduct';

  final String productName; // Tham số để truyền tên danh mục
  final List<String?> productImage; // Tham số để truyền hình ảnh danh mục
  final String productId; // Tham số để truyền hình ảnh danh mục
  final String description;
  final int productprice;
  final int productsl;

  final int productpercent;
  final bool? isSpecial; // Thêm tham số isSpecial
  EditProduct(
      {required this.productName,
      required this.productImage,
      required this.productId,
      required this.description,
      required this.productprice,
      required this.productsl,
      required this.productpercent,
      this.isSpecial,
      Key? key})
      : super(key: key);

  @override
  State<EditProduct> createState() => _EditproductState();
}

class _EditproductState extends State<EditProduct> {
  late TextEditingController _nameController;
  late TextEditingController _imageController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _slController;
  late TextEditingController _percentController;
  bool? isSpecial; // Mặc định sản phẩm
  Category? selectedCategory; // Thêm biến này để theo dõi danh mục đã chọn
  List<XFile>? selectedImages; // Danh sách hình ảnh đã chọn
  bool imageSelected = false;
  bool isImagePickerActive = false;
  bool _isLoading = false; // Thêm biến _isLoading

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productName);
    _imageController = TextEditingController(
        text: widget.productImage.isNotEmpty ? widget.productImage[0] : '');
    _descriptionController = TextEditingController(text: widget.description);
    _priceController =
        TextEditingController(text: widget.productprice.toString());
    _slController =
        TextEditingController(text: widget.productsl.toString());
    _percentController =
        TextEditingController(text: widget.productpercent.toString());
    isSpecial = widget.isSpecial;
  }

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
    return _nameController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _percentController.text.isNotEmpty ;
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });
    if (!imageSelected) {
      setState(() {
        _isLoading = false;
      });
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

    final productName = _nameController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);
    final sl = int.tryParse(_slController.text);
    final percent = int.tryParse(_percentController.text);
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
        // Nếu người dùng có quyền admin, tải hình ảnh lên Cloudinary.
        final cloudinaryImageUrls = await uploadImagesToCloudinary(
          selectedImages!.map((image) => image.path).toList(),
        );

        if (cloudinaryImageUrls != null) {
          setState(() {
            _isLoading = false;
          });
          print(productName);
          print(cloudinaryImageUrls);
          print(price);
          print(sl);
          print(percent);
          print(description);
          print(selectedCategory);
          print(isSpecial);
          print(savedToken);

          final success = await saveDataToApi(
            productName,
            cloudinaryImageUrls, // Chuyển danh sách URL hình ảnh
            price!,
            sl!,
            percent!,
            description,
            selectedCategory!.id, // Chuyển ID của danh mục
            isSpecial!,
            savedToken,
          );
          print('object');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Lưu thành công'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Điều hướng trở lại trang product
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductAdmin(), // Đảm bảo rằng bạn đã cung cấp một builder để tạo ra màn hình mới
                        ),
                      );
                    },
                    child: Text('Đóng'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
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
                  },
                  child: Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
    final url = 'http://192.168.1.31:5000/product/${widget.productId}';

    final Map<String, dynamic> requestData = {
      'name': productName,
      'images': imageUrl, // Danh sách URL hình ảnh
      'price': price,
      'sl' : sl,
      'special': special,
      'description': description,
      'category': category,
      'percent': percent
    };

    final String requestBody = jsonEncode(requestData);

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print(requestBody);

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
        title: Text('Chỉnh sửa danh mục'),
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
            var data = snapshot.data! as List<Category>;

            return snapshot.hasData
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration:
                                InputDecoration(labelText: 'Tên sản phẩm'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: _descriptionController,
                            decoration: InputDecoration(labelText: 'Nội dung'),
                            maxLines: null, // Cho phép nhiều dòng
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: _priceController,
                            decoration: InputDecoration(labelText: 'Giá'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: _slController,
                            decoration: InputDecoration(labelText: 'Số lượng'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: _percentController,
                            decoration: InputDecoration(labelText: 'Giảm'),
                          ),
                          SizedBox(
                            height: 5,
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
                                  value: selectedCategory?.id ??
                                      data.first
                                          .id, // Sử dụng id của danh mục đầu tiên làm giá trị mặc định
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
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue, // Màu đường viền
                                width: 2.0, // Độ dày đường viền
                              ),
                            ),
                            child: imageSelected
                                ? Container(
                                    height:
                                        150, // Đặt chiều cao của Container cho phù hợp
                                    child: ListView.builder(
                                      scrollDirection: Axis
                                          .horizontal, // Để hình ảnh nằm ngang
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
                                  )
                                : SizedBox(
                                    height: 150,
                                    child: ListView.builder(
                                      scrollDirection: Axis
                                          .horizontal, // Để hình ảnh nằm ngang
                                      itemCount: widget.productImage.length,
                                      itemBuilder: (context, index) {
                                        final imageUrl =
                                            widget.productImage[index];
                                        return imageUrl != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: 150,
                                                  height: 150,
                                                ),
                                              )
                                            : Container();
                                      },
                                    ),
                                  ),
                          ),
                          ElevatedButton(
                            onPressed: _selectImages,
                            child: Text('Thay đổi hình ảnh'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _pickImage();
                            },
                            child: _isLoading
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .green, // Đặt màu nền thành màu xanh
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors
                                                .white), // Đặt màu cho vòng tiến trình là màu trắng
                                      ),
                                    ),
                                  )
                                : Text('Lưu'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text('Empty Product'),
                  );
          }),
    );
  }
}
