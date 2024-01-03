import 'package:flutter/material.dart';

class MyLaporan extends StatefulWidget {
  const MyLaporan({super.key});

  @override
  State<MyLaporan> createState() => _MyLaporanState();
}

class _MyLaporanState extends State<MyLaporan> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Laporan Saya'));
  }
}
