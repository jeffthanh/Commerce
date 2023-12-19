import 'package:client/providers/order_provider.dart';
import 'package:client/providers/user_provider.dart';
import 'package:client/screens/home/order/widget/orther_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOrder extends StatefulWidget {
  static const routerName = '/listOder';

  @override
  State<ListOrder> createState() => _ListOrderState();
}

class _ListOrderState extends State<ListOrder> {
  String userId = '';
  bool userIdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await Provider.of<UserProvider>(context).getUser();
      if (user != null) {
        userId = user['_id'];
        userIdLoaded = true;
        setState(() {});
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!userIdLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Danh sách đơn hàng'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return DefaultTabController(
        length: 4, // Số lượng tab
        child: Scaffold(
          appBar: AppBar(
            title: Text('Danh sách đơn hàng'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Chờ xử lý'),
                Tab(text: 'Đang giao hàng'),
                Tab(text: 'Thành công'),
                Tab(text: 'Đã hủy'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OrderListByStatus(status: 'Chờ xử lý', userId: userId),
              OrderListByStatus(status: 'Đang giao hàng', userId: userId),
              OrderListByStatus(status: 'Thành công', userId: userId),
              OrderListByStatus(status: 'Đã hủy', userId: userId),
            ],
          ),
        ),
      );
    }
  }
}

class OrderListByStatus extends StatelessWidget {
  final String status;
  final String userId;

  OrderListByStatus({required this.status, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Provider.of<OrderProvider>(context).getOrder(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Center(
            child: Text('Không có dữ liệu.'),
          );
        } else {
          final orders = snapshot.data!;
          final filteredOrders =
              orders.where((order) => order['status'] == status).toList();
          return ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              // Hiển thị thông tin đơn hàng theo trạng thái đã lọc
              return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderPage(order: order),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.network(
                  'https://res.cloudinary.com/dqbeplqtc/image/upload/v1697726914/thanhjs/pngtree-invioce-icon-design-vector-png-image_1588908_ow78nv.jpg'),
              title: Text('Mã đơn hàng: ${order['_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ngày đặt hàng: ${DateTime.parse(order['orderDate']).day}/${DateTime.parse(order['orderDate']).month}/${DateTime.parse(order['orderDate']).year}'),
                  Text('Trạng thái: ${order['status']}'),
                  // Hiển thị các thông tin khác về đơn hàng
                  // ...
                ],
              ),
            ),
          ),
        );
            },
          );
        }
      },
    );
  }
}
