import 'package:client/screens/home/profile/widget/editprofile.dart';
import 'package:flutter/material.dart';

import '../../../providers/user_provider.dart'; // Import your UserProvider class

class ProfilePage extends StatefulWidget {
  static const routerName = '/profile';

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {}; // Khởi tạo dữ liệu người dùng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop('/profile');
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          // Assuming you have a UserProvider instance named userProvider
          future: UserProvider().getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While data is being fetched, show a loading indicator.
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle the error if it occurs.
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              // Handle the case where no data is available.
              return Center(child: Text('No data available.'));
            } else {
              // Data has been successfully fetched, now you can display it.
              final currentData = snapshot.data!; // Extract the user data
              print('Current image: ${currentData['image']}');

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: currentData['image'] != null
                          ? NetworkImage(currentData['image'])
                          :
                          NetworkImage(
                              'https://res.cloudinary.com/dqbeplqtc/image/upload/v1696129643/thanhjs/logo_bqqqxl.jpg'),
                    ),
                    const SizedBox(height: 20),
                    itemProfile('FullName', currentData['fullname'] ?? 'N/A',
                        Icons.person),
                    const SizedBox(height: 10),
                    itemProfile(
                        'Phone', currentData['phone'] ?? 'N/A', Icons.phone),
                    const SizedBox(height: 10),
                    itemProfile('Address', currentData['address'] ?? 'N/A',
                        Icons.location_on),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/check-password');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text('Change Password'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Sử dụng Navigator.push để điều hướng đến trang chỉnh sửa
                        final updatedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );

                        if (updatedData != null) {
                          // Nếu dữ liệu đã được cập nhật, hãy cập nhật lại thông tin và gọi setState
                          setState(() {
                            userData = updatedData;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text('Edit Profile'),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 5),
            color: Colors.deepOrange.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }
}
