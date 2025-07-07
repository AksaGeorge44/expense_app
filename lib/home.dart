import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/add.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formkey = GlobalKey<FormState>();

  final TextEditingController amtpaid = TextEditingController();
  final TextEditingController itemname = TextEditingController();
  final TextEditingController unitprice = TextEditingController();
  final TextEditingController qty = TextEditingController();
  final TextEditingController itemdescription = TextEditingController();
  final TextEditingController expno = TextEditingController();

  String? selSupplier;
  String? selCategory;

  List<String> supplierList = [];
  List<String> categoryList = [];

  List<Map<String, dynamic>> itemlist = [];

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
    fetchCategories();
  }

  Future<void> fetchSuppliers() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('suppliers').get();
    setState(() {
      supplierList =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  Future<void> fetchCategories() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categoryList =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  void save() async {
      final expensedata = {
        'expenseno': expno.text,
        'date': DateTime.now(),
        'supplier': selSupplier,
        'category': selCategory,
        'items': itemlist
      };
      await FirebaseFirestore.instance
          .collection('expenses')
          .add(expensedata);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Data saved")));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          TextButton(
            child: const Text("Add Supplier & Category"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddSupplierCategoryScreen()),
              ).then((_) {
                fetchSuppliers();
                fetchCategories();
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: expno,
                decoration: const InputDecoration(
                  labelText: "Expense No",
                  hintText: "Enter expense number",
                ),
                validator: (value) =>
                value!.isEmpty ? "Please enter expense number" : null,
              ),
              const SizedBox(height: 20),
              Text("Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Select Supplier"),
                value: selSupplier,
                items: supplierList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selSupplier = value),
                validator: (value) =>
                value == null ? "Please select a supplier" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration:
                const InputDecoration(labelText: "Select Category"),
                value: selCategory,
                items: categoryList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selCategory = value),
                validator: (value) =>
                value == null ? "Please select a category" : null,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add Items",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    TextFormField(
                      controller: itemname,
                      decoration: const InputDecoration(labelText: "Item Name"),
                      validator: (value) =>
                      value!.isEmpty ? "Enter item name" : null,
                    ),
                    TextFormField(
                      controller: unitprice,
                      decoration:
                      const InputDecoration(labelText: "Unit Price"),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                      value!.isEmpty ? "Enter unit price" : null,
                    ),
                    TextFormField(
                      controller: qty,
                      decoration:
                      const InputDecoration(labelText: "Quantity"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty ? "Enter quantity" : null,
                    ),
                    TextFormField(
                      controller: itemdescription,
                      decoration:
                      const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (itemname.text.isEmpty ||
                            unitprice.text.isEmpty ||
                            qty.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Fill item details first")),
                          );
                          return;
                        }

                        final item = {
                          'itemname': itemname.text,
                          "unitprice": double.parse(unitprice.text),
                          "quantity": int.parse(qty.text),
                          "description": itemdescription.text,
                          "amount": double.parse(unitprice.text) *
                              int.parse(qty.text)
                        };

                        setState(() {
                          itemlist.add(item);
                          itemname.clear();
                          unitprice.clear();
                          qty.clear();
                          itemdescription.clear();
                        });
                      },
                      child: const Text("Add Item"),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: itemlist.length,
                      itemBuilder: (context, index) {
                        final item = itemlist[index];
                        return Card(
                          child: ListTile(
                            title: Text('Item: ${item['itemname']}'),
                            subtitle: Text(
                              "Unit Price: ₹${item['unitprice']}\n"
                                  "Qty: ${item['quantity']} | Amount: ₹${item['amount']}\n"
                                  "Description: ${item['description']}",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: save,
                  child: const Text("Save Expense"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
