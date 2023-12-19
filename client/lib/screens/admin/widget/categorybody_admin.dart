import 'package:flutter/material.dart';

class CategoryAdminPage extends StatelessWidget {
  const CategoryAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        // Phần tử 1
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2), // Đường viền
            borderRadius: BorderRadius.circular(15), // Bo tròn góc
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100, // Điều chỉnh kích thước hình ảnh
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Để làm tròn hình ảnh
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://res.cloudinary.com/dqbeplqtc/image/upload/v1697186760/thanhjs/DSC08477-scaled_rcc2eg.jpg',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/productadmin');
                  },
                  child: Text(
                    "Sản Phẩm",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ) // Đổi màu cho văn bản),

                  ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2), // Đường viền
            borderRadius: BorderRadius.circular(15), // Bo tròn góc
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100, // Điều chỉnh kích thước hình ảnh
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Để làm tròn hình ảnh
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://res.cloudinary.com/dqbeplqtc/image/upload/v1697190538/thanhjs/yen-sao-khanh-hoa_nec77s.jpg',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/categoryadmin');
                  },
                  child: Text(
                    "Danh Mục",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ) // Đổi màu cho văn bản),

                  ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2), // Đường viền
            borderRadius: BorderRadius.circular(15), // Bo tròn góc
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100, // Điều chỉnh kích thước hình ảnh
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Để làm tròn hình ảnh
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://res.cloudinary.com/dqbeplqtc/image/upload/v1697190681/thanhjs/giao-hang_dfufvo.png',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/ortheradmin');

                  },
                  child: Text(
                    "Đơn Đặt Hàng",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ) // Đổi màu cho văn bản),

                  ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2), // Đường viền
            borderRadius: BorderRadius.circular(15), // Bo tròn góc
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100, // Điều chỉnh kích thước hình ảnh
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Để làm tròn hình ảnh
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://res.cloudinary.com/dqbeplqtc/image/upload/v1697191210/thanhjs/78-786207_user-avatar-png-user-avatar-icon-png-transparent_hpm97m.png',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: () {
                   
                    Navigator.of(context).pushNamed('/useradmin');
               
                  },
                  child: Text(
                    "Người dùng",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ) // Đổi màu cho văn bản),

                  ),
            ],
          ),
        ),
      ],
    );
  }
}
