import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key, required this.auth, required this.userDocSnap, required this.productSnap})
      : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;
  final DocumentSnapshot productSnap;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    // Scaffold for the Product Screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: ProductDetails(
        productSnap: widget.productSnap,
        userDocSnap: widget.userDocSnap,
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  const ProductDetails({Key? key, required this.productSnap, required this.userDocSnap})
      : super(key: key);

  final DocumentSnapshot userDocSnap;
  final DocumentSnapshot productSnap;

  @override
  Widget build(BuildContext context) {
    // Container with product details
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product header
            Center(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: ProductHeader(productSnap: productSnap),
              ),
            ),
            // Product icon
            Center(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: ProductIcon(), // Use ProductIcon instead of ProductIcon
              ),
            ),
            const SizedBox(height: 20),
            // Product information
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ProductInfo(productSnap: productSnap),
            ),
            const SizedBox(height: 20),
            // Button to show reviews
            ElevatedButton(
              onPressed: () {
                // Show modal bottom sheet with product reviews
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext ctx) => ProductReviewsModal(productSnap: productSnap),
                );
              },
              child: const Text('Reviews'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductIcon extends StatelessWidget {
  const ProductIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Product icon using the image icon
    return Icon(
      Icons.image,
      size: 50,
      color: Colors.grey,
    );
  }
}

class ProductHeader extends StatelessWidget {
  const ProductHeader({Key? key, required this.productSnap}) : super(key: key);

  final DocumentSnapshot productSnap;

  @override
  Widget build(BuildContext context) {
    // Product name text
    return Text(
      productSnap['product-name'],
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }
}




class ProductInfo extends StatelessWidget {
  const ProductInfo({Key? key, required this.productSnap}) : super(key: key);

  final DocumentSnapshot productSnap;

  @override
  Widget build(BuildContext context) {
    // Container with product information
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with price and rating
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price: \$${productSnap['product-price']}'),
                // Row with rating stars
                Row(
                  children: [
                    Text('Rating: ${productSnap['product-rating']}'),
                    const SizedBox(width: 5),
                    RatingBar.builder(
                      initialRating: double.parse(productSnap['product-rating'].toString()),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 20,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        // ignore this part, rating won't be updated
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Product description
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text('Product Description: ${productSnap['product-description']}'),
          ),
        ],
      ),
    );
  }
}

class ProductReviewsModal extends StatelessWidget {
  const ProductReviewsModal({Key? key, required this.productSnap}) : super(key: key);

  final DocumentSnapshot productSnap;

  @override
  Widget build(BuildContext context) {
    // Container with product reviews modal
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title for product reviews
          Text('${productSnap['product-name']} Reviews', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // Button to add a review
          ElevatedButton(
            onPressed: () {
              // Open a bottom sheet for adding reviews
              _addReview(context);
            },
            child: const Text('Add Review'),
          ),
          // List of product reviews
          ProductReviewList(productSnap: productSnap),
        ],
      ),
    );
  }

  // Function to open the bottom sheet for adding reviews
  void _addReview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return _AddReviewForm(productSnap: productSnap);
      },
    );
  }
}

class _AddReviewForm extends StatefulWidget {
  const _AddReviewForm({Key? key, required this.productSnap}) : super(key: key);

  final DocumentSnapshot productSnap;

  @override
  State<_AddReviewForm> createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<_AddReviewForm> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Container with form to add a review
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title for the add review form
          Text('Add Review', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // TextField for the review text
          TextField(
            controller: _reviewController,
            decoration: const InputDecoration(labelText: 'Write your review'),
          ),
          const SizedBox(height: 10),
          // Button to submit the review
          ElevatedButton(
            onPressed: () {
              // Call a function to add the review to the Firestore collection
              _addUserReview(widget.productSnap.id, _reviewController.text);
              // Close the bottom sheet after adding the review
              Navigator.of(context).pop();
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  // Function to add the user review to the Firestore collection
  void _addUserReview(String productId, String review) {
    CollectionReference userReviews = FirebaseFirestore.instance.collection('review');
    userReviews.add({
      'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
      'user-review': review,
      'firstname': 'anonymous',
      'time': DateTime.now().millisecondsSinceEpoch,
      'product-id': productId,
    });
  }
}

class ProductReviewList extends StatelessWidget {
  const ProductReviewList({Key? key, required this.productSnap}) : super(key: key);

  final DocumentSnapshot productSnap;

  @override
  Widget build(BuildContext context) {
    // Firestore collection reference for user reviews
    CollectionReference userReviews = FirebaseFirestore.instance.collection('review');

    return Flexible(
      child: StreamBuilder(
        stream: userReviews.where('product-id', isEqualTo: productSnap.id).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            // List view of user reviews
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                // Card with user review details
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['user-review']),
                    subtitle: Text('${documentSnapshot['firstname']} - ${_formatTime(documentSnapshot['time'])}'),
                  ),
                );
              },
            );
          }
          // Loading indicator while data is being fetched
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  // Helper function to format the timestamp to a readable format
  String _formatTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MM/dd/yyyy HH:mm').format(dateTime);
  }
}
