import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/status_dialog.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  DetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _firestore = FirebaseFirestore.instance;
  bool isShow = true;
  bool _isLoading = false;

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('tidak dapat memanggil: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    // laporan.like?.forEach((element) {
    //   if (element.email == akun.email) {
    //     print(element.email);
    //     setState(() {
    //       isShow = false;
    //     });
    //   }
    // });

    void likePost() async {
      CollectionReference laporanCollection = _firestore.collection('laporan');
      try {
        await laporanCollection.doc(laporan.docId).update({
          'likes': FieldValue.arrayUnion([
            {
              'email': akun.email,
              'docId': akun.nama,
              'timestamp': DateTime.now(),
            }
          ])
        });
      } catch (e) {
        final snackbar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      } finally {
        setState(() {
          isShow = !isShow;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      floatingActionButton: isShow
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                likePost();
              },
              child: Icon(Icons.favorite))
          : null,
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
