import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/input_widget.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/components/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? nama;
  String? email;
  String? noHP;

  final TextEditingController _password = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference akunCollection = _db.collection('akun');

      final password = _password.text;
      await _auth.createUserWithEmailAndPassword(
          email: email!, password: password);

      final docId = akunCollection.doc().id;
      await akunCollection.doc(docId).set({
        'uid': _auth.currentUser!.uid,
        'nama': nama,
        'email': email,
        'noHP': noHP,
        'docId': docId,
        'role': 'user',
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 80),
                    Text("Register", style: headerStyle(level: 1)),
                    Container(
                      child: const Text(
                        'Create your profile and start your journey',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //input komponen
                              InputLayout(
                                  'Nama',
                                  TextFormField(
                                      onChanged: (String value) => setState(() {
                                            nama = value;
                                          }),
                                      validator: notEmptyValidator,
                                      decoration: customInputDecoration(
                                          "Nama Lengkap"))),
                              InputLayout(
                                  'Email',
                                  TextFormField(
                                      onChanged: (String value) => setState(() {
                                            email = value;
                                          }),
                                      validator: notEmptyValidator,
                                      decoration: customInputDecoration(
                                          "example@mail.com"))),
                              InputLayout(
                                  'No. Handphone',
                                  TextFormField(
                                      onChanged: (String value) => setState(() {
                                            noHP = value;
                                          }),
                                      validator: notEmptyValidator,
                                      decoration: customInputDecoration(
                                          '+62 123456789'))),
                              InputLayout(
                                  'Password',
                                  TextFormField(
                                      controller: _password,
                                      validator: notEmptyValidator,
                                      obscureText: true,
                                      decoration: customInputDecoration(''))),
                              InputLayout(
                                  'Konfirmasi Password',
                                  TextFormField(
                                      validator: (value) =>
                                          passConfirmationValidator(
                                              value, _password),
                                      obscureText: true,
                                      decoration: customInputDecoration(''))),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                width: double.infinity,
                                child: FilledButton(
                                    style: buttonStyle,
                                    child: Text("Register",
                                        style: headerStyle(level: 2)),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        register();
                                        //registrasi
                                      }
                                    }),
                              )
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        const Text('Sudah punya akun ?'),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(' Login di sini',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
