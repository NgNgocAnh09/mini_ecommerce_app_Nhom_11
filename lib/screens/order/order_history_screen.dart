import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 Tab theo yêu cầu
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: const TabBar(
            isScrollable: true, // Cho phép vuốt ngang thanh tab
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(context, 'Chờ xác nhận'),
            _buildOrderList(context, 'Đang giao'),
            _buildOrderList(context, 'Đã giao'),
            _buildOrderList(context, 'Đã hủy'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, String status) {
    final allOrders = context.watch<CartProvider>().orders;
    final filteredOrders = allOrders.where((o) => o['status'] == status).toList();

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('Chưa có đơn hàng nào'));
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('Đơn hàng: ${order['id'].substring(0, 8)}'),
            subtitle: Text('Tổng tiền: ${order['total']} VND'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),
        );
      },
    );
  }
}