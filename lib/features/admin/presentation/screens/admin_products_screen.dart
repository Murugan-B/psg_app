import 'package:flutter/material.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Products')),
      body: const Center(child: Text('Admin Products')),
    );
  }
}
