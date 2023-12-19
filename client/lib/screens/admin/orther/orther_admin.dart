import 'package:client/screens/admin/orther/widget/editstatus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderList extends StatefulWidget {
  static const routerName = '/ortheradmin';

  const OrderList({Key? key}) : super(key: key);

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> allOrders = []; // Danh sách tất cả đơn hàng
  List<Map<String, dynamic>> pendingOrders = []; // Danh sách đơn hàng chờ xử lý
  List<Map<String, dynamic>> shippingOrders =
      []; // Danh sách đơn hàng đang giao hàng
  List<Map<String, dynamic>> successOrders =
      []; // Danh sách đơn hàng thành công
  List<Map<String, dynamic>> canceledOrders = []; // Danh sách đơn hàng đã hủy

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final url = 'http://192.168.1.31:5000/order';
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('jwt');

      if (savedToken == null) {
        return Future.error('Token không tồn tại hoặc đã hết hạn');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $savedToken',
        },
      );

      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        allOrders = List<Map<String, dynamic>>.from(jsonData);
        // Xử lý và cập nhật danh sách đơn hàng dựa trên trạng thái
        pendingOrders =
            allOrders.where((order) => order['status'] == 'Chờ xử lý').toList();
        shippingOrders = allOrders
            .where((order) => order['status'] == 'Đang giao hàng')
            .toList();
        successOrders = allOrders
            .where((order) => order['status'] == 'Thành công')
            .toList();
        canceledOrders =
            allOrders.where((order) => order['status'] == 'Đã hủy').toList();
        setState(() {});
      } else {
        return Future.error('Dữ liệu không hợp lệ');
      }
    } catch (e) {
      return Future.error('Lỗi: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách đơn hàng'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Chờ xử lý'),
            Tab(text: 'Đang giao hàng'),
            Tab(text: 'Thành công'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrderStatusList(orders: pendingOrders),
          OrderStatusList(orders: shippingOrders),
          OrderStatusList(orders: successOrders),
          OrderStatusList(orders: canceledOrders),
        ],
      ),
    );
  }
}

class OrderStatusList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  OrderStatusList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => UpdateStatus(order: order),
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
                  Text('Ngày đặt hàng: ${order['orderDate']}'),
                  Text('Trạng thái: ${order['status']}'),
             
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
