import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text('Order #${1000 + i}'),
            subtitle: const Text('Placed on 2025-05-01 · 3 items'),
            trailing: const Text('\$42.50'),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: 8,
      ),
    );
  }
}
