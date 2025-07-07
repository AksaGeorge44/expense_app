import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSupplierCategoryScreen extends StatefulWidget {
  const AddSupplierCategoryScreen({super.key});

  @override
  State<AddSupplierCategoryScreen> createState() => _AddSupplierCategoryScreenState();
}

class _AddSupplierCategoryScreenState extends State<AddSupplierCategoryScreen> {
  final TextEditingController supplier = TextEditingController();
  final TextEditingController category = TextEditingController();

  Future<void> addSupplier() async {
    final name = supplier.text.trim();
    if (name.isNotEmpty) {
      await FirebaseFirestore.instance.collection('suppliers').add({'name': name});
      supplier.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Supplier Added")));
    }
  }

  Future<void> addCategory() async {
    final name = category.text.trim();
    if (name.isNotEmpty) {
      await FirebaseFirestore.instance.collection('categories').add({'name': name});
      category.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Category Added")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Supplier & Category")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Add Supplier", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: supplier, decoration: const InputDecoration(labelText: "Supplier Name")),
            ElevatedButton(onPressed: addSupplier, child: const Text("Add Supplier")),
            const SizedBox(height: 20),
            const Text("Add Category", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: category, decoration: const InputDecoration(labelText: "Category Name")),
            ElevatedButton(onPressed: addCategory, child: const Text("Add Category")),
          ],
        ),
      ),
    );
  }
}
