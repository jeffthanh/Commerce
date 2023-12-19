import 'dart:convert';
import 'dart:io';
import 'package:client/screens/admin/category/category_admin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AddCategory extends StatefulWidget {
  static const routerName = '/addcategory';

  const AddCategory({Key? key}) : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController categoryNameController = TextEditingController();
  String? selectedImagePath;
  bool imageSelected = false;
  bool _isLoading = false; // Thêm biến _isLoading

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImagePath = pickedFile.path;
        imageSelected = true;
      });
    }
  }

 bool _validateInput() {
    return categoryNameController.text.isNotEmpty;
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

    final categoryName = categoryNameController.text;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('jwt');
    print(savedToken);
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
        // Nếu người dùng có quyền admin, tải hình ảnh lên Cloudinary.
        final cloudinaryImageUrl =
            await uploadImageToCloudinary(selectedImagePath!);

        if (cloudinaryImageUrl != null) {
          setState(() {
            _isLoading = false;
          });
          // Sau khi tải lên thành công, bạn có thể gửi dữ liệu lên API với thông tin danh mục và URL hình ảnh từ Cloudinary.
          final success =
              await saveDataToApi(categoryName, cloudinaryImageUrl, savedToken);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Lưu thành công'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Điều hướng trở lại trang Category
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => CategoryAdmin(),
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
                  },
                  child: Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(savedToken);
      // Xử lý khi có lỗi xảy ra trong quá trình giải mã token
      print('Lỗi giải mã token: $e');
      // Có thể đăng xuất người dùng ở đây nếu cần.
    }
  }

  Future<String?> uploadImageToCloudinary(String imagePath) async {
    final cloudName = 'dqbeplqtc'; // Thay thế bằng tên Cloudinary của bạn
    final apiKey = '375441668363381'; // Thay thế bằng API Key của bạn
    final apiSecret =
        'curghrze'; // Thay thế bằng API Secret của bạn

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final file = File(imagePath);

    if (!file.existsSync()) {
      // Xử lý nếu tệp không tồn tại
      return null;
    }

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imagePath,
      contentType: MediaType.parse(
          lookupMimeType(imagePath) ?? 'image/jpg'), // Loại hình ảnh
    ));

    request.fields['upload_preset'] = 'curghrze';

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';
    request.headers['authorization'] = basicAuth;

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseJson = await response.stream.bytesToString();
      final data = jsonDecode(responseJson);
      return data['secure_url'];
    } else {
      return null;
    }
  }

  Future<bool> saveDataToApi(
      String categoryName, String imageUrl, String token) async {
    final url = 'http://192.168.1.31:5000/category';

    final Map<String, dynamic> requestData = {
      'name': categoryName,
      'image': imageUrl,
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
        title: Text('Thêm Danh Mục'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: categoryNameController,
                decoration: InputDecoration(labelText: 'Tên danh mục'),
              ),
              SizedBox(height: 16),
              imageSelected
                  ? Image.file(
                      File(selectedImagePath!),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey,
                    ),
              ElevatedButton(
                onPressed: _selectImage,
                child: Text('Chọn Hình Ảnh'),
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
                          color: Colors.green, // Đặt màu nền thành màu xanh
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors
                                .white), // Đặt màu cho vòng tiến trình là màu trắng
                          ),
                        ),
                      )
                    : Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
