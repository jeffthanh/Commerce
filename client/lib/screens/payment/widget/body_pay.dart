import 'package:client/providers/cart_provider.dart';
import 'package:client/providers/user_provider.dart';
import 'package:client/screens/home/profile/widget/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class BodyPayment extends StatefulWidget {
  final List<CartItem> purchasedItems;

  const BodyPayment({Key? key, required this.purchasedItems}) : super(key: key);

  @override
  _BodyPaymentState createState() => _BodyPaymentState();
}

class _BodyPaymentState extends State<BodyPayment> {
  Map<String, dynamic> userData = {};

  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Tính tổng số tiền từ danh sách sản phẩm đã mua
    widget.purchasedItems.forEach((item) {
      totalAmount += (item.price * item.quantity);
    });

    return SingleChildScrollView(
      child: FutureBuilder<Map<String, dynamic>>(
        // Assuming you have a UserProvider instance named userProvider
        future: UserProvider().getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available.'));
          } else {
            final currentData = snapshot.data!;
            return Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Thông Tin Nhận Hàng',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      TextButton(
                        onPressed: () async {
                          final updatedData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(),
                            ),
                          );

                          if (updatedData != null) {
                            setState(() {
                              userData = updatedData;
                            });
                          }
                        },
                        child: Text('Chỉnh sửa'),
                      )
                    ],
                  ),
                ),
                ProfileItem('FullName:', currentData['fullname'] ?? 'N/A'),
                ProfileItem('Phone:', currentData['phone'] ?? 'N/A'),
                ProfileItem('Address:', currentData['address'] ?? 'N/A'),
                Container(
                  height: 18,
                  child: Text('Sản phẩm',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.purchasedItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CartItem item = widget.purchasedItems[index];
                    return ListTile(
                      leading: Image.network(
                        item.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                          '${intl.NumberFormat.currency(locale: 'vi', symbol: 'VND', decimalDigits: 0).format(item.price)}  - Số Lượng: ${item.quantity}'),
                    );
                  },
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phương thức vận chuyển',
                        style: TextStyle(color: Colors.green, fontSize: 15),
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Giao hàng nhanh'),
                              Text('nhận hàng trong 3-4 ngày')
                            ],
                          ),
                          Text('0đ')
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.amber[50]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Phương thức thanh toán:'),
                      TextButton(
                        onPressed: () {
                          bool isPaymentUpdated = false;

                          if (isPaymentUpdated) {
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Thông báo"),
                                  content: Text(
                                      "Phương thức thanh toán mới chưa có."),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text('Thanh toán khi nhận hàng >'),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: [
                    Row(
                      children: [
                        Icon(Icons.payment),
                        Text('Chi tiết thanh toán'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng tiền sản phẩm:'),
                        Text(
                          '${intl.NumberFormat.currency(locale: 'vi', symbol: 'VND', decimalDigits: 0).format(totalAmount)}',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phí vận chuyển:'),
                        Text(
                          '0',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng thanh toán',style: TextStyle(fontWeight: FontWeight.bold)),
                           Text(
                          '${intl.NumberFormat.currency(locale: 'vi', symbol: 'VND', decimalDigits: 0).format(totalAmount)}',
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String title;
  final String subtitle;

  ProfileItem(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 5),
            color: Colors.deepOrange.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
