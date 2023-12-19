import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import 'package:client/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  static const routerName = '/edit-profile';

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  String? selectedImagePath;
  bool imageSelected = false;
  bool isImagePickerActive = false;
  Map<String, dynamic>? userData;
  String? phoneError;
  String? fullNameError;
  String? addressError;
  String? imageError;
  String? cloudinaryImageUrl; // Declare the variable

   Future<void> _selectImage() async {
    if (!isImagePickerActive) {
      isImagePickerActive =
          true; // Đánh dấu là một lần chọn ảnh đang được thực hiện
      final imagePicker = ImagePicker();
      final XFile? pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imagePath = pickedFile.path;
        final uploadedImageUrl = await uploadImageToCloudinary(imagePath);

        if (uploadedImageUrl != null) {
          // Cập nhật đường dẫn hình ảnh từ Cloudinary
          setState(() {
            cloudinaryImageUrl = uploadedImageUrl;
            imageSelected = true;
            selectedImagePath = imagePath;
          });
        } else {
          // Xử lý lỗi nếu không thể tải lên hình ảnh
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to upload the image.'),
                actions: [
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
      }

      isImagePickerActive =
          false; // Đảm bảo thiết lập lại trạng thái sau khi hoàn thành
    }
  }
  Future<String?> uploadImageToCloudinary(String imagePath) async {
    final cloudName = 'dqbeplqtc'; // Thay thế bằng tên Cloudinary của bạn
    final apiKey = '375441668363381'; // Thay thế bằng API Key của bạn
    final apiSecret =
        '63FpgwhEEoT3qogAWO_IYq8w0eQ'; // Thay thế bằng API Secret của bạn

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

  @override
  void initState() {
    super.initState();
    UserProvider().getUser().then((data) {
      setState(() {
        userData = data;
        _fullNameController.text = userData?['fullname'] ?? '';
        _phoneController.text = userData?['phone'] ?? '';
        _addressController.text = userData?['address'] ?? '';
        _imageController.text = userData?['image'] ?? '';
      });
    });
  }

  bool isPhoneNumberValid(String phone) {
    return phone.length == 10 && int.tryParse(phone) != null;
  }

  bool isFieldNotEmpty(String value) {
    return value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                onChanged: (value) {
                  setState(() {
                    fullNameError = isFieldNotEmpty(value)
                        ? null
                        : 'Full Name  không được để trống';
                  });
                },
              ),
              if (fullNameError != null)
                Text(fullNameError!, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                onChanged: (value) {
                  if (isPhoneNumberValid(value)) {
                    setState(() {
                      phoneError = null;
                    });
                  } else {
                    setState(() {
                      phoneError = 'Phone must be 10 digits';
                    });
                  }
                },
              ),
              if (phoneError != null)
                Text(phoneError!, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  setState(() {
                    addressError = isFieldNotEmpty(value)
                        ? null
                        : 'Address không được để trống';
                  });
                },
              ),
              if (addressError != null)
                Text(addressError!, style: TextStyle(color: Colors.red)),
               Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue, // Màu đường viền
                      width: 2.0, // Độ dày đường viền
                    ),
                  ),
                  child: imageSelected
                      ? Image.file(
                          File(selectedImagePath!),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : _imageController.text.isNotEmpty
                          ? Image.network(
                              _imageController
                                  .text, // Sử dụng URL hình ảnh từ controller
                              fit: BoxFit.cover,
                              width: 150, // Kích thước 150x150
                              height: 150,
                            )
                          : Icon(Icons.add_a_photo,
                              size: 100, color: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: Text('Thay đổi hình ảnh'),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (userData != null) {
                      final fullName = _fullNameController.text;
                      final phone = _phoneController.text;
                      final address = _addressController.text;
                      final image = cloudinaryImageUrl;
                      if (isFieldNotEmpty(fullName) &&
                          isPhoneNumberValid(phone) &&
                          isFieldNotEmpty(address) 
                          ) {
                        final updatedUserData = {
                          'fullname': fullName,
                          'phone': phone,
                          'address': address,
                          'image':image,
                        };
                        UserProvider().updateUser(updatedUserData);
      
                        Navigator.pop(context, updatedUserData);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content:
                                  Text('Please enter valid data in all fields.'),
                              actions: [
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
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  
                  child: Text('Save Profile'),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
