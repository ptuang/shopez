import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:projecttwo/screens/loginscreen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEZ',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.lightBlue), //Colors.green
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ShopEZ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //RegisterEmailSection(auth: _auth),
            Image.asset(
              'assets/images/splash_shop_ez.png',
              scale: 2.0,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          scrollable: true,
                          title: const Text('Login'),
                          content:
                              Stack(clipBehavior: Clip.none, children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: EmailPasswordForm(auth: _auth)),
                          ]));
                    });
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        scrollable: true,
                        title: const Text('Sign Up'),
                        content:
                            Stack(clipBehavior: Clip.none, children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RegisterEmailSection(auth: _auth)),
                        ]),
                      );
                    });
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
