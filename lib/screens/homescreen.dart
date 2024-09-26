import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projecttwo/screens/productscreen.dart';
import 'package:projecttwo/screens/sellersdashboard.dart';
import 'package:projecttwo/screens/settings.dart';
import 'package:projecttwo/screens/shoppingcart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.auth, required this.userDocSnap})
      : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// text fields' controllers

  final TextEditingController searchTextController = TextEditingController();

  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');

  Future<void> _addProductToCart(DocumentSnapshot productSnap) async {
    String productId = productSnap.id;
    final CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocSnap.id)
        .collection('current_cart');
    DocumentSnapshot temp = await currentCart.doc('products_$productId').get();
    if (temp.exists) {
      currentCart.doc('products_$productId').delete();
    } else {
      currentCart.doc('products_$productId').set({
        "count": 1,
        'name': productSnap['product-name'],
        'price': productSnap['product-price']
      }).onError((e, _) => print("Error writing document: $e"));
      ;
    }
  }

  //Future<void> addToCart
  Widget productList = Container(
    child: const Text('No matching products'),
  );
  void rebuildProductList(String str) {
    setState(() {
      productList = buildProductListNew(str);
    });
  }

  @override
  Widget build(BuildContext context) {
    productList = buildProductListNew(searchTextController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop EZ'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ShoppingCartScreen(
                      auth: widget.auth,
                      userDocSnap: widget.userDocSnap), //change to docref
                ),
              );
            },
            child: const Icon(Icons.shopping_cart),
          ),
          ElevatedButton(
            onPressed: () {
              //_signOut(); add to settings page instead
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SettingsScreen(
                      auth: widget.auth, userDocSnap: widget.userDocSnap),
                ),
              );
            },
            child: const Icon(Icons.settings),
          ),
          ElevatedButton(
            onPressed: () {
              //_signOut(); add to settings page instead
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SellerDashboard(auth: widget.auth),
                ),
              );
            },
            child: const Icon(Icons.money),
          )
        ],
      ),
      backgroundColor: Colors.black12,
// Using StreamBuilder to display all tasks from Firestore in real-time
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 60,
                child: Flexible(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: searchTextController,
                          decoration:
                              const InputDecoration(hintText: 'Enter Search'),
                          onSubmitted: (String str) {
                            setState(() {
                              productList =
                                  buildProductListNew(searchTextController.text);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          rebuildProductList(searchTextController.text);
                          //searchTextController.text = '';
                        },
                        child: const Text('Load Product List'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            productList,
          ],
        ),
      ),
    );
  }

  Future<void> _productScreen(DocumentSnapshot prodSnap) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return ProductScreen(
              auth: widget.auth,
              userDocSnap: widget.userDocSnap,
              productSnap: prodSnap);
        });
  }

  Widget buildProductListNew(String searchText) {
    return Flexible(
      child: StreamBuilder(
        stream: searchText == ''
            ? _productss.snapshots()
            : _productss
            .where('product-name', isEqualTo: searchText)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                print("Failing here");
                print("failing here 2");

                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];

                Object? data = documentSnapshot.data();
                print(data.toString());

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: (data != null &&
                      data.toString().contains("product-img-url") &&
                      data.toString().contains("product-name"))
                      ? ListTile(
                    tileColor: Color(0xFFe2f3f7),
                    leading: Image.network(
                      documentSnapshot['product-img-url'],
                      height: 25,
                      width: 25,
                    ),
                    title: Text(
                        (documentSnapshot.get("product-name") != null)
                            ? documentSnapshot['product-name']
                            : ""),
                    trailing: SizedBox(
                      width: 175,
                      child: Row(
                        children: [
                          /*IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.black,
                              ),
                              onPressed: () =>
                                  _decreaseProduct(documentSnapshot.id)),
                          countText(documentSnapshot
                              .id), //i am having issues accessing user current cart doc.
                          IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                              onPressed: () =>
                                  _increaseProduct(documentSnapshot.id)),*/
                          IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.lightBlueAccent,
                              ),
                              onPressed: () {
                                _addProductToCart(documentSnapshot);
                              }),
                          IconButton(
                              onPressed: () {
                                _productScreen(
                                    documentSnapshot); //- call this when product screen function is done
                              },
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.lightBlueAccent))
                        ],
                      ),
                    ),
                  )
                      : const ListTile(
                    tileColor: Color(0xFFFF0000),
                    title: Text("No product image"),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget buildProductList(String searchText) {
    return Flexible(
      child: StreamBuilder(
        stream: searchText == ''
            ? _productss.snapshots()
            : _productss
                .where('product-name', isEqualTo: searchText)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                bool temp = true;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    tileColor: Colors.grey,
                    leading: const Icon(Icons.image),
                    /*Image.network(
                      documentSnapshot['product-img-url'].toString(),
                      height: 25,
                      width: 25,
                    ),*/
                    title: Text(documentSnapshot['product-name']),
                    trailing: SizedBox(
                      width: 125,
                      child: Row(
                        children: [
                          /*IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white70,
                              ),
                              onPressed: () =>
                                  _decreaseProduct(documentSnapshot.id)),
                          countText(documentSnapshot.id), //i am having issues accessing user current cart doc.
                          */
                          IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                temp = !temp;
                                _addProductToCart(documentSnapshot);
                              }),
                          IconButton(
                              onPressed: () {
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => ShoppingCartScreen(
                                        auth: widget.auth,
                                        userDocSnap: widget.userDocSnap), //change to docref
                                  ),
                                );*/
                                _productScreen(
                                    documentSnapshot); //- call this when product screen function is done
                              },
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.white70))
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

}
