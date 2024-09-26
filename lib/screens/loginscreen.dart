import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:projecttwo/screens/homescreen.dart';
import '../firebase_options.dart';

class EmailPasswordForm extends StatefulWidget {
  const EmailPasswordForm({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;
  @override
  _EmailPasswordFormState createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final CollectionReference _userss = FirebaseFirestore.instance.collection('users');

  bool _success = false;
  bool _initialState = true;
  String _userEmail = '';
  void _signInWithEmailAndPassword() async {
    try {
      await widget.auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _success = true;
        _userEmail = _emailController.text;
        _initialState = false;
        if(_success){
          print('uid');
          print(widget.auth.currentUser!.uid);
          _userss.where("uid", isEqualTo: widget.auth.currentUser!.uid).get().then(
                (querySnapshot) {
              print("Successfully completed");
              for (var docSnapshot in querySnapshot.docs) {
                print('${docSnapshot.id} => ${docSnapshot.data()}');
              }
              DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen(auth: widget.auth, userDocSnap: documentSnapshot),
                ),
              );
            },
            onError: (e) => print("Error completing: $e"),
          );
        }
      });
    } catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text('Please sign in with email and password'),
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signInWithEmailAndPassword();

                }
              },
              child: const Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _initialState
                  ? 'Please sign in'
                  : _success
                  ? 'Successfully signed in $_userEmail'
                  : 'Sign in failed',
              style: TextStyle(color: _success ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

///REGISTRATION FORM


class RegisterEmailSection extends StatefulWidget {
  RegisterEmailSection({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;
  @override
  _RegisterEmailSectionState createState() => _RegisterEmailSectionState();
}

class _RegisterEmailSectionState extends State<RegisterEmailSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final CollectionReference _userss = FirebaseFirestore.instance.collection('users');

  bool _success = false;
  bool _initialState = true;
  String? _userEmail;
  void _register() async {
    try {
      await widget.auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _success = true;
        _userEmail = _emailController.text;
        _initialState = false;
        _create();
      }
      );
    } catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
    }
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async { //orUpdate
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _firstNameController.text = documentSnapshot['firstname'];
      _lastNameController.text = documentSnapshot['lastname'];
      _addressController.text = documentSnapshot['address'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery
                    .of(ctx)
                    .viewInsets
                    .bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Additional Registration Information:'),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(//keyboardType://const TextInputType.numberWithOptions(decimal: true),
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(//keyboardType://const TextInputType.numberWithOptions(decimal: true),
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String firstname = _firstNameController.text;
                    final String lastname = _lastNameController.text;
                    final String address = _addressController.text;
                    //final String email = _emailController.text; "email": email,
                    //double.tryParse(_contentController.text);
                    if (firstname != null && lastname != null && address != null) {
                      if (action == 'create') {
                        // Persist a new user to Firestore
                        var user = widget.auth.currentUser;
                        if(user != null){
                          await _userss.add({"uid" : user.uid, "firstname": firstname, "lastname": lastname, "address" : address, "registration_time" : Timestamp.fromDate(DateTime.now())});
                        }

                      }
                      if (action == 'update') {
// Update the task
                        await _userss
                            .doc(documentSnapshot!.id)
                            .update({"firstname": firstname, "lastname": lastname, "address" : address});
                      }
                      _firstNameController.text = '';
                      _lastNameController.text = '';
                      _addressController.text = '';
                      //Navigator.of(context).pop();
                      if(_success){
                        _userss.where("uid", isEqualTo: widget.auth.currentUser!.uid).get().then(
                              (querySnapshot) {
                            print("Successfully completed");
                            for (var docSnapshot in querySnapshot.docs) {
                              print('${docSnapshot.id} => ${docSnapshot.data()}');
                            }
                            DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => HomeScreen(auth: widget.auth, userDocSnap: documentSnapshot),
                              ),
                            );
                          },
                          onError: (e) => print("Error completing: $e"),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _register();
                }
              },
              child: Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              _initialState
                  ? 'Please Register'
                  : _success
                  ? 'Successfully registered $_userEmail'
                  : 'Registration failed',
              style: TextStyle(color: _success ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
