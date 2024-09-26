// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projecttwo/screens/homescreen.dart';
import 'package:projecttwo/screens/productscreen.dart';
import 'package:projecttwo/screens/sellersdashboard.dart';
import 'package:projecttwo/screens/settings.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen(
      {Key? key, required this.auth, required this.userDocSnap})
      : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreen();
}

class _ShoppingCartScreen extends State<ShoppingCartScreen> {
  double totalCost = 0.0;
// text fields' controllers //textediting?

  final CollectionReference _productss =
  FirebaseFirestore.instance.collection('products');

  final CollectionReference _userss =
  FirebaseFirestore.instance.collection('users');

  Map<String, ValueNotifier<int>> productCountNotifiers = {};

  Future<void> _increaseProduct(String productId) async {
    final CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocSnap.id)
        .collection('current_cart');
    DocumentReference docRef = currentCart.doc('products_$productId');
    DocumentSnapshot docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.update({'count': FieldValue.increment(1)});
    } else {
      await currentCart.doc('products_$productId').set({'count': 1});
    }
    int newCount = (productCountNotifiers[productId]?.value ?? 0) + 1;
    productCountNotifiers[productId]?.value = newCount;
  }

  Future<void> _decreaseProduct(String productId) async {
    final CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocSnap.id)
        .collection('current_cart');
    DocumentReference docRef = currentCart.doc('products_$productId');
    DocumentSnapshot docSnap = await docRef.get();
    bool isZero = false;
    if (docSnap.exists) {
      if (docSnap['count'] == 1) {
        await currentCart.doc(docSnap.id).delete();
      } else {
        await docRef.update({'count': FieldValue.increment(-1)});
      }
    } else {
      isZero = true;
    }
    int newCount = (productCountNotifiers[productId]?.value ?? 0) - 1;
    if (isZero) {
      newCount = 0;
    }
    productCountNotifiers[productId]?.value = newCount;
  }

  Future<double> calcTotalCost() async {
    double totalCost = 0;

    try {
      QuerySnapshot productsSnapshot = await _productss.get();

      for (QueryDocumentSnapshot productDoc in productsSnapshot.docs) {
        String productId = productDoc.id;
        print(productId);
        int count = await getCountInt(productId);

        if (count > 0) {
          int productPrice = productDoc["product-price"];
          totalCost += productPrice * count;
        }
      }
    } catch (e) {
      print("Error calculating total cost: $e");
      // You can handle errors as needed
    }
    return totalCost;
  }

  Widget checkoutFooter = Container();

  Widget productList = Container(
    child: const Text('No products in cart.'),
  );

  void rebuildProductList() {
    setState(() {
      productList = buildProductList();
      Future.delayed(const Duration(seconds: 1));
    });
  }

  void rebuildFooter(){
    setState(() {
      checkoutFooter = ShoppingCartFooter(
          totalCostFuture: calcTotalCost(),
          auth: widget.auth,
          userDocSnap: widget.userDocSnap
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    checkoutFooter = ShoppingCartFooter(
        totalCostFuture: calcTotalCost(),
        auth: widget.auth,
        userDocSnap: widget.userDocSnap
    );
    productList = buildProductList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Checkout page'),
        actions: <Widget>[
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
      //backgroundColor: Colors.black12,
// Using StreamBuilder to display all tasks from Firestore in real-time
      body: SafeArea(
        child: Column(
          children: [
            productList,
            checkoutFooter,
          ],
        ),
      ),
    );
  }

  Widget buildProductList() {
    return Flexible(
      child: StreamBuilder(
        stream: _productss.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                print("Failing here");

                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return FutureBuilder<int>(
                  future: getCountInt(documentSnapshot.id),
                  builder: (context, AsyncSnapshot<int> countSnapshot) {
                    if (countSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (countSnapshot.hasError) {
                      return Text('Error: ${countSnapshot.error}');
                    } else {
                      int count = countSnapshot.data!;
                      if (streamSnapshot.data!.docs.isNotEmpty && count > 0) {
                        totalCost += documentSnapshot["product-price"] * count;
                      }
                      // Use count to build your UI here
                      return (streamSnapshot.data!.docs.isNotEmpty && count > 0)
                          ? Card(
                        margin: const EdgeInsets.all(10),
                        child: (documentSnapshot.get('product-img-url') !=
                            null &&
                            documentSnapshot.get('product-img-url') !=
                                null)
                            ? ListTile(
                          tileColor: const Color(0xFFe2f3f7),
                          leading: Image.network(
                            documentSnapshot['product-img-url'],
                            height: 25,
                            width: 25,
                          ),
                          title: Text(
                            (documentSnapshot.get("product-name") != null) ? documentSnapshot['product-name'] : "",
                          ),
                          trailing: SizedBox(
                            width: 200,
                            child: Row(children: [
                              IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _decreaseProduct(documentSnapshot.id);
                                    rebuildProductList();
                                    Future.delayed(const Duration(seconds: 1));
                                    rebuildFooter();
                                  }
                              ),
                              countText(documentSnapshot.id), //i am having issues accessing user current cart doc.
                              IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _increaseProduct(documentSnapshot.id);
                                    rebuildProductList();
                                    rebuildFooter();
                                  }
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text("Quantity: "),
                                      countText(documentSnapshot.id),
                                    ],
                                  ),
                                  countPriceText(documentSnapshot.id, documentSnapshot["product-price"]),
                                ],
                              )
                            ]),
                          ),
                        )
                            : const ListTile(
                          tileColor: Color(0xFFFF0000),
                          title: Text("No product image"),
                        ),
                      )
                          : const SizedBox
                          .shrink(); // Returning an empty widget when count is not greater than 0
                    }
                  },
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

  Future<int> getCountInt(String productId) async {
    final CollectionReference currentCart =
    _userss.doc(widget.userDocSnap.id).collection('current_cart');

    try {
      DocumentSnapshot snapshot =
      await currentCart.doc('products_$productId').get();

      if (!snapshot.exists) {
        return 0;
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data['count'] ?? 0;
    } catch (e) {
      print("Error: $e");
      return 0; // You can handle errors as needed
    }
  }

  Widget countText(String productId) {
    final CollectionReference currentCart =
    _userss.doc(widget.userDocSnap.id).collection('current_cart');

    // Initialize ValueNotifier for each product if not already done
    if (!productCountNotifiers.containsKey(productId)) {
      productCountNotifiers[productId] = ValueNotifier<int>(0);
    }

    // Use a FutureBuilder to handle the asynchronous call
    return FutureBuilder<int>(
      future: getCountText(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator if the data is still loading
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error state
          return Text('Error: ${snapshot.error}');
        } else {
          // Update the ValueNotifier with the fetched count
          productCountNotifiers[productId]?.value = snapshot.data ?? 0;

          // Use ValueListenableBuilder to listen for changes
          return ValueListenableBuilder<int>(
            valueListenable: productCountNotifiers[productId]!,
            builder: (context, count, child) {
              return Text(count.toString());
            },
          );
        }
      },
    );
  }

  Future<int> getCountText(String productId) async {
    final CollectionReference currentCart =
    _userss.doc(widget.userDocSnap.id).collection('current_cart');

    try {
      DocumentSnapshot snapshot =
      await currentCart.doc('products_$productId').get();

      if (!snapshot.exists) {
        return 0;
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data['count'] ?? 0;
    } catch (e) {
      print("Error: $e");
      return 0; // You can handle errors as needed
    }
  }

  Widget countPriceText(String productId, int price) {
    final CollectionReference currentCart =
    _userss.doc(widget.userDocSnap.id).collection('current_cart');

    // Initialize ValueNotifier for each product if not already done
    if (!productCountNotifiers.containsKey(productId)) {
      productCountNotifiers[productId] = ValueNotifier<int>(0);
    }

    // Use a FutureBuilder to handle the asynchronous call
    return FutureBuilder<int>(
      future: getCountText(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator if the data is still loading
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error state
          return Text('Error: ${snapshot.error}', style: const TextStyle(fontWeight: FontWeight.bold),);
        } else {
          // Update the ValueNotifier with the fetched count
          productCountNotifiers[productId]?.value = snapshot.data ?? 0;

          // Use ValueListenableBuilder to listen for changes
          return ValueListenableBuilder<int>(
            valueListenable: productCountNotifiers[productId]!,
            builder: (context, count, child) {
              return Text((count * price).toString(), style: const TextStyle(fontWeight: FontWeight.bold),);
            },
          );
        }
      },
    );
  }

}

class ShoppingCartFooter extends StatefulWidget {
  final Future<double> totalCostFuture;

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  const ShoppingCartFooter(
      {Key? key,
        required this.totalCostFuture,
        required this.auth,
        required this.userDocSnap})
      : super(key: key);

  @override
  _ShoppingCartFooterState createState() => _ShoppingCartFooterState();
}

class _ShoppingCartFooterState extends State<ShoppingCartFooter> {

  final CollectionReference _orderss =
  FirebaseFirestore.instance.collection('orders');

  Future<void> _addOrder() async {
    try {
      await _orderss.add({
        'shipping_address': widget.userDocSnap['address'],
        'total': widget.totalCostFuture,
        'uid': widget.auth.currentUser?.uid,
        'order-time' : Timestamp.fromDate(DateTime.now())
      });

      // You can add any additional logic or show a success message here if needed.
    } catch (e) {
      // Handle errors, e.g., show an error message.
      print('Error adding product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: widget.totalCostFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  "Total Cost: \$Loading...",
                  style: TextStyle(color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to the Post Processing page
                    await _orderss.add({
                      'shipping_address': widget.userDocSnap['address'],
                      'total': widget.totalCostFuture,
                      'uid': widget.auth.currentUser?.uid,
                      'order-time' : Timestamp.fromDate(DateTime.now())
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            auth: widget.auth,
                            userDocSnap: widget.userDocSnap,
                          )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe2f3f7)),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue,
            child: const Text(
              "Error loading total cost",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        double totalCost = snapshot.data ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Total Cost: \$${totalCost.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  emptyUserCart(widget.userDocSnap, () {
                    // setState to trigger a rebuild after the cart is emptied
                    setState(() {}
                  );

                    // Navigate to the Post Processing page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          auth: widget.auth,
                          userDocSnap: widget.userDocSnap,
                        ),
                      ),
                    );
                  });
                },
                child: const Text('Checkout'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CheckoutPage extends StatelessWidget {
  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  const CheckoutPage({super.key, required this.auth, required this.userDocSnap});

  Future<String> getUserName() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocSnap.id)
          .get();

      if (userSnapshot.exists) {
        String firstName = userSnapshot.get('firstname') ?? '';
        String lastName = userSnapshot.get('lastname') ?? '';

        return '$firstName $lastName';
      }
    } catch (e) {
      print("Error getting user's name: $e");
    }

    return ''; // Return an empty string if there's an error
  }

  Future<String> getUserAddress() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocSnap.id)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.get('address') ?? '';
      }
    } catch (e) {
      print("Error getting user's address: $e");
    }

    return 'INVALID ADDRESS'; // Return an empty string if there's an error
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserName(),
      builder: (context, nameSnapshot) {
        if (nameSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Post Processing Page'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (nameSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Post Processing Page'),
            ),
            body: Center(
              child: Container(
                margin: const EdgeInsets.all(16), // Small margin
                child: const Text(
                  "Error loading user's name",
                  style: TextStyle(fontSize: 20), // Larger text size
                  textAlign: TextAlign.center, // Center text
                ),
              ),
            ),
          );
        }

        String userName = nameSnapshot.data ?? '';

        return FutureBuilder<String>(
          future: getUserAddress(),
          builder: (context, addressSnapshot) {
            if (addressSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Post Processing Page'),
                ),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (addressSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Post Processing Page'),
                ),
                body: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16), // Small margin
                    child: const Text(
                      "Error loading user's address",
                      style: TextStyle(fontSize: 20), // Larger text size
                      textAlign: TextAlign.center, // Center text
                    ),
                  ),
                ),
              );
            }

            String userAddress = addressSnapshot.data ?? '';

            return Scaffold(
              appBar: AppBar(
                title: const Text('Post Processing Page'),
              ),
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16), // Small margin
                        child: Text(
                          'Thank you, $userName, for shopping with us!',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight:
                              FontWeight.bold), // Larger text size and bold
                          textAlign: TextAlign.center, // Center text
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.all(16), // Small margin
                        child: const Text(
                          'Items will be shipped to the following address:',
                          style: TextStyle(fontSize: 20), // Larger text size
                          textAlign: TextAlign.center, // Center text
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16), // Small margin
                        child: Text(
                          userAddress,
                          style: const TextStyle(fontSize: 18), // Larger text size
                          textAlign: TextAlign.center, // Center text
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: (){

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => HomeScreen(
                                    auth: auth, userDocSnap: userDocSnap),
                              ),
                            );
                          },
                          child: const Text('Back Home'))
                      // Add any additional content or features for the Post Processing Page
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> emptyUserCart(
    DocumentSnapshot userDocSnap, VoidCallback onCartEmptied) async {
  try {
    CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(userDocSnap.id)
        .collection('current_cart');

    // Get all documents in the 'current_cart' collection
    QuerySnapshot cartSnapshot = await currentCart.get();

    // Delete each document in the 'current_cart' collection
    for (QueryDocumentSnapshot cartDocSnap in cartSnapshot.docs) {
      await currentCart.doc(cartDocSnap.id).delete();
    }

    print('User cart emptied successfully');

    // Call the callback to notify that the cart is emptied
    onCartEmptied();
  } catch (e) {
    print('Error emptying user cart: $e');
  }
}

