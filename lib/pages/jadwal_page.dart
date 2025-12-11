// File: lib/pages/jadwal_page.dart

import 'package:flutter/material.dart';
import '../jadwal_model.dart'; 
import 'absen_page.dart'; 

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final Color primaryColor = const Color(0xFF003366);
  final Color accentColor = const Color(0xFFF79931E);

  List<Jadwal> _jadwalList = []; 
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  // ====== FUNGSI: FETCH DATA JADWAL (MENGGUNAKAN DUMMY SEMENTARA) ======
  Future<void> fetchJadwal() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500)); 

    final List<Jadwal> dummyList = [
      Jadwal(
        idKrsDetail: 101, // ID KRS Detail penting untuk AbsenPage
        kodeMatkul: 'MK001',
        namaMatkul: 'Algoritma dan Struktur Data',
        dosen: 'Dr. Rina Wati, M.Kom.',
        hari: 'Senin',
        waktuMulai: '08:00',
        waktuSelesai: '09:40',
        ruangan: 'L-201',
      ),
      Jadwal(
        idKrsDetail: 102,
        kodeMatkul: 'MK002',
        namaMatkul: 'Dasar Pemrograman',
        dosen: 'Prof. Budi Santoso, Ph.D.',
        hari: 'Selasa',
        waktuMulai: '10:00',
        waktuSelesai: '11:40',
        ruangan: 'A-105',
      ),
      Jadwal(
        idKrsDetail: 103,
        kodeMatkul: 'MK003',
        namaMatkul: 'Sistem Basis Data',
        dosen: 'Sari Dewi, M.T.I.',
        hari: 'Rabu',
        waktuMulai: '13:00',
        waktuSelesai: '14:40',
        ruangan: 'B-303',
      ),
    ];
    
    setState(() {
      _jadwalList = dummyList;
      isLoading = false;
    });
  }
  // =======================================================


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Jadwal Mata Kuliah",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: _buildBody(), 
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }
    
    if (_jadwalList.isEmpty) {
      return const Center(child: Text("Tidak ada jadwal mata kuliah saat ini (Data Dummy Kosong)."));
    }

    return ListView.builder(
      itemCount: _jadwalList.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final jadwal = _jadwalList[index];
        return _buildJadwalCard(context, jadwal);
      },
    );
  }

  Widget _buildJadwalCard(BuildContext context, Jadwal jadwal) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jadwal.namaMatkul,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 5),
            
            Text(
              '${jadwal.kodeMatkul} | ${jadwal.dosen}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const Divider(height: 20, thickness: 1),

            _buildDetailRow(Icons.calendar_today, 'Hari', jadwal.hari),
            _buildDetailRow(Icons.schedule, 'Waktu', '${jadwal.waktuMulai} - ${jadwal.waktuSelesai}'),
            _buildDetailRow(Icons.location_on, 'Ruangan', jadwal.ruangan),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AbsenPage(
                        idKrsDetail: jadwal.idKrsDetail, 
                        namaMatkul: jadwal.namaMatkul, 
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  "LAKUKAN ABSENSI",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 70, 
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}