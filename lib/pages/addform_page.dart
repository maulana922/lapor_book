import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/components/vars.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../components/input_widget.dart';
import '../components/validators.dart';

class AddFormPage extends StatefulWidget {
  const AddFormPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddFormState();
}

class _AddFormState extends State<AddFormPage> {
  bool _isLoading = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String? judul;
  String? instansi;
  String? deskripsi;

  ImagePicker picker = ImagePicker();
  XFile? file;

  Image imagePreview() {
    if (file == null) {
      return Image.asset('assets/picture.png', width: 180, height: 180);
    } else {
      return Image.file(File(file!.path), width: 180, height: 180);
    }
  }

  Future<dynamic> uploadDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext) {
        return AlertDialog(
          title: Text('Pilih sumber: '),
          actions: [
            TextButton(
                onPressed: () async {
                  XFile? upload =
                      await picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    file = upload;
                  });
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.camera_alt)),
            TextButton(
              onPressed: () async {
                XFile? upload =
                    await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  file = upload;
                });
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.browse_gallery),
            ),
          ],
        );
      },
    );
  }

  Future<String> uploadImage() async {
    if (file == null) return '';

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      Reference dirUpload =
          _storage.ref().child('upload/${_auth.currentUser!.uid}');
      Reference storeDir = dirUpload.child(uniqueFilename);
      await storeDir.putFile(File(file!.path));

      return await storeDir.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  Future<Position> getCurrentLocation() async {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isServiceEnabled) {
      return Future.error('Location service is not enabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permission is denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission is permanently denied, unable to request permission');
    }

    return await Geolocator.getCurrentPosition();
  }

  void addTransaksi(Akun akun) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference laporanCollection = _firestore.collection('laporan');

      // Convert DateTime to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      String url = await uploadImage();

      String currentLocation = await getCurrentLocation().then((value) {
        return '${value.latitude},${value.longitude}';
      });

      String maps = 'https://www.google.com/maps/place/$currentLocation';
      final id = laporanCollection.doc().id;

      await laporanCollection.doc(id).set({
        'uid': _auth.currentUser!.uid,
        'docId': id,
        'judul': judul,
        'instansi': instansi,
        'deskripsi': deskripsi,
        'gambar': url,
        'nama': akun.nama,
        'status': 'Posted', // posted, process, done
        'tanggal': timestamp,
        'maps': maps,
      }).catchError((e) {
        throw e;
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Tambah Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Form(
                  child: Container(
                    margin: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        InputLayout(
                          "Judul Laporan",
                          TextFormField(
                              onChanged: (String value) => {
                                    setState(() {
                                      judul = value;
                                    })
                                  },
                              validator: notEmptyValidator,
                              decoration:
                                  customInputDecoration("Judul Laporan")),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: imagePreview(),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              uploadDialog(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_camera),
                                Text('Foto Pendukung',
                                    style: headerStyle(level: 3)),
                              ],
                            ),
                          ),
                        ),
                        InputLayout(
                            'Instansi',
                            DropdownButtonFormField<String>(
                                decoration: customInputDecoration('Instansi'),
                                items: dataInstansi.map((e) {
                                  return DropdownMenuItem<String>(
                                      child: Text(e), value: e);
                                }).toList(),
                                onChanged: (selected) {
                                  setState(() {
                                    instansi = selected;
                                  });
                                })),
                        InputLayout(
                          "Deskripsi Laporan",
                          TextFormField(
                            onChanged: (String value) => {
                              setState(() {
                                deskripsi = value;
                              })
                            },
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 5,
                            decoration: customInputDecoration(
                                'Berikan deskripsi laporan secara menyeluruh'),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          child: FilledButton(
                            style: buttonStyle,
                            onPressed: () {
                              addTransaksi(akun);
                            },
                            child: Text(
                              'Kirim Laporan',
                              style: headerStyle(level: 3, dark: false),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
