import 'package:flutter/material.dart';

class Laporan {
  final String uid;
  final String docId;
  final String email;
  final String judul;
  final String instansi;
  String? deskripsi;
  String? gambar;
  final String nama;
  final String status;
  final DateTime tanggal;
  final String maps;
  List komentar;
  List like;

  Laporan({
    required this.uid,
    required this.docId,
    required this.email,
    required this.judul,
    required this.instansi,
    this.deskripsi,
    this.gambar,
    required this.nama,
    required this.status,
    required this.tanggal,
    required this.maps,
    required this.komentar,
    required this.like,
  });
}

class Komentar {
  final String nama;
  final String isi;
  final String time;

  Komentar({
    required this.nama,
    required this.isi,
    required this.time,
  });
}

class Like {
  final String email;
  final String nama;
  final DateTime Timestamp;

  Like({
    required this.email,
    required this.nama,
    required this.Timestamp,
  });
}
