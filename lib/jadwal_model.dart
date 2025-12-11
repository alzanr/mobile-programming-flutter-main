// File: lib/jadwal_model.dart

// File: lib/models/jadwal_model.dart (Pastikan ini ada di folder /lib/models)

class Jadwal {
  final int idKrsDetail;
  final String kodeMatkul;
  final String namaMatkul;
  final String dosen;
  final String hari;
  final String waktuMulai;
  final String waktuSelesai;
  final String ruangan;

  Jadwal({
    required this.idKrsDetail,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.dosen,
    required this.hari,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.ruangan,
  });

  // Factory constructor untuk membuat objek Jadwal dari JSON
  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      idKrsDetail: json['id_krs_detail'] as int,
      kodeMatkul: json['kode_matkul'] as String,
      namaMatkul: json['nama_matkul'] as String,
      dosen: json['dosen'] as String,
      hari: json['hari'] as String,
      waktuMulai: json['waktu_mulai'] as String,
      waktuSelesai: json['waktu_selesai'] as String,
      ruangan: json['ruangan'] as String,
    );
  }
}