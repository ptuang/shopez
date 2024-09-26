import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerDashboard extends StatefulWidget {
  final FirebaseAuth auth;

  SellerDashboard({Key? key, required this.auth}) : super(key: key);

  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productImageController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  Future<void> _addProduct() async {
    try {
      await _products.add({
        'product-description': _productDescriptionController.text,
        'product-img-url': _productImageController.text,
        'product-name': _productNameController.text,
        'product-price': double.parse(_productPriceController.text),
        'seller-id': widget.auth.currentUser?.uid,
      });

      // Clear input fields
      _productNameController.clear();
      _productDescriptionController.clear();
      _productImageController.clear();
      _productPriceController.clear();

      // You can add any additional logic or show a success message here if needed.
    } catch (e) {
      // Handle errors, e.g., show an error message.
      print('Error adding product: $e');
    }
  }

  void myproducts() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Products'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _products
              .where('seller-id', isEqualTo: widget.auth.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.data?.docs.isEmpty ?? true) {
              return Text('No products added yet.');
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var product =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(product['product-name']),
                  subtitle: Text('Price: \$${product['product-price']}'),
                  // You can add more details or actions here
                );
              },
            );
          },
        ),
      ),
    ));
  }

  bool _showAddProductFields = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop EZ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[],
      ),
      backgroundColor: Colors.black12,
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Add Product',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAddProductFields = true;
                    });
                  },
                  child: Text('Add Product'),
                ),
                if (_showAddProductFields) ...[
                  // Display text fields only when _showAddProductFields is true
                  TextField(
                    controller: _productNameController,
                    decoration: InputDecoration(labelText: 'Product Name'),
                  ),
                  TextField(
                    controller: _productDescriptionController,
                    decoration:
                        InputDecoration(labelText: 'Product Description'),
                  ),
                  TextField(
                    controller: _productImageController,
                    decoration: InputDecoration(labelText: 'Product Image URL'),
                  ),
                  TextField(
                    controller: _productPriceController,
                    decoration: InputDecoration(labelText: 'Product Price'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _addProduct();
                      setState(() {
                        _showAddProductFields = false;
                      });
                    },
                    child: Text('Submit'),
                  ),
                ],
                SizedBox(height: 20),
                Text(
                  'Manage Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    myproducts();
                  },
                  child: Text('View Products'),
                ),
              ],
            ),
          )),
    );
  }
}
