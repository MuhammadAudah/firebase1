import 'dart:io';

import 'package:application_firebase/check_sms_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.setSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controllerFirstName = TextEditingController();
  TextEditingController _controllerSurname = TextEditingController();
  TextEditingController _controllerEmailAddress = TextEditingController();
  TextEditingController _controllerPhoneNumber = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  final _keyForm = GlobalKey<FormState>();

  _handleAddNewDocument() async {
    if (_keyForm.currentState!.validate()) {
      CollectionReference users =
          FirebaseFirestore.instance.collection("users");

      DocumentReference insertedDocument = await users.add({
        "firstName": _controllerFirstName.text,
        "surname": _controllerSurname.text,
        "emailAddress": _controllerEmailAddress.text,
        "phoneNumber": _controllerPhoneNumber.text,
        "password": _controllerPassword.text,
        "platform": Platform.isAndroid ? "android" : "ios",
        "createdAt": DateTime.now()
      });
      if (insertedDocument != null) {
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: '+962' + _controllerPhoneNumber.text,
            verificationCompleted: (PhoneAuthCredential credetial) {},
            verificationFailed: (FirebaseAuthException e) {},
            codeSent: (String verificationId, int? resendToken) async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CheckSmsPage(verificationId: verificationId)));
            },
            codeAutoRetrievalTimeout: (String verificationId) {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register a New Account"),
      ),
      body: Container(
        padding: const EdgeInsets.all(17.0),
        child: Form(
          key: _keyForm,
          child: Column(
            children: [
              TextFormField(
                controller: _controllerFirstName,
                keyboardType: TextInputType.name,
                validator: (text) {
                  if (text == null || text.length <= 2) {
                    return "Please Check The First Name";
                  }
                },
                decoration: const InputDecoration(
                    label: Text("First Name"),
                    prefixIcon: Icon(Icons.person),
                    hintText: "First Name"),
              ),
              TextFormField(
                controller: _controllerSurname,
                keyboardType: TextInputType.name,
                validator: (text) {
                  if (text == null || text.length <= 2) {
                    return "Please Check The Surname";
                  }
                },
                decoration: const InputDecoration(
                    label: Text("Surname"),
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    hintText: "Surname"),
              ),
              TextFormField(
                controller: _controllerEmailAddress,
                keyboardType: TextInputType.emailAddress,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return "Please Type a Correct E-mail Address";
                  }
                },
                decoration: const InputDecoration(
                    label: Text("E-mail Address"),
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: "E-mail Address"),
              ),
              TextFormField(
                controller: _controllerPhoneNumber,
                keyboardType: TextInputType.phone,
                validator: (text) {
                  if (text == null || text.length != 9) {
                    return "Please Check Your Phone Number";
                  }
                },
                decoration: const InputDecoration(
                    label: Text("Phone Number"),
                    prefixIcon: Icon(Icons.phone_android_outlined),
                    hintText: "Phone Number"),
              ),
              TextFormField(
                controller: _controllerPassword,
                keyboardType: TextInputType.visiblePassword,
                validator: (text) {
                  if (text == null || text.length < 6) {
                    return "Make Sure You Have Typed The Correct Password!";
                  }
                },
                decoration: const InputDecoration(
                    label: Text("Password"),
                    suffixIcon: Icon(Icons.remove_red_eye_rounded),
                    prefixIcon: Icon(Icons.password_outlined),
                    hintText: "Password"),
              ),
              const SizedBox(height: 45),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _handleAddNewDocument,
                    child: const Text("Register"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
