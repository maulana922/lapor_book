import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/status_dialog.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool isLike = false;
  List<Like> listLike = [];

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('tidak dapat memanggil: $uri');
    }
  }

  void likePost(Akun akun, String docId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference likeCollection =
          _firestore.collection('laporan').doc(docId).collection('like');

      final liked = likeCollection.id;
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      await likeCollection.doc(liked).set({
        'uid': _auth.currentUser!.uid,
        'docId': docId,
        'nama': akun.nama,
        'timestamp': timestamp,
      });
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void likeStatus(Akun akun, String docId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('laporan')
          .doc(docId)
          .collection('like')
          .where('uid', isEqualTo: akun.uid)
          .get();

      setState(() {
        listLike.clear();
        for (var documents in querySnapshot.docs) {
          if (documents != null) {
            listLike.add(
              Like(
                uid: documents.data()['uid'],
                docId: documents.data()['docId'],
                nama: documents.data()['nama'],
                timestamp: documents.data()['timestamp'].toDate(),
              ),
            );
          }
        }
        if (listLike.isEmpty) {
          setState(() {
            isLike = false;
          });
        } else {
          setState(() {
            isLike = true;
          });
        }
      });
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 30,
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 20),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/picture.png'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          laporan.status == 'Posted'
                              ? textStatus(
                                  'Posted', Colors.yellow, Colors.black)
                              : laporan.status == 'Process'
                                  ? textStatus(
                                      'Process', Colors.green, Colors.white)
                                  : textStatus(
                                      'Done', Colors.blue, Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(child: Text(laporan.nama)),
                        trailing: SizedBox(width: 40),
                      ),
                      ListTile(
                        leading: Icon(Icons.calendar_month),
                        title: Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                            child: Text(DateFormat('dd MMMM yyyy')
                                .format(laporan.tanggal))),
                        trailing: IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed: () {
                              launch(laporan.maps);
                            }),
                      ),
                      ListTile(
                        leading: IconButton(
                          icon: Icon(
                            isLike ? Icons.favorite : Icons.favorite_border,
                            color: isLike ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              if (!isLike) {
                                likePost(akun, laporan.docId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Anda sudah menyukai postingan ini'),
                                  ),
                                );
                              }
                            });
                          },
                        ),
                        title: const Center(child: Text('Like')),
                        subtitle: Center(child: Text("Like this post")),
                        trailing: SizedBox(width: 40),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          laporan.deskripsi ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 30),
                      if (akun.role == 'admin')
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatusDialog(
                                      laporan: laporan,
                                    );
                                  });
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: Text('Ubah Status'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Container textStatus(String text, var bgColor, var textColor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
