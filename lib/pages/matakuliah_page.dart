import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import 'absen_page.dart'; // Pastikan import AbsenPage sudah ada

class DaftarMatakuliahPage extends StatefulWidget {
  const DaftarMatakuliahPage({super.key});

  @override
  State<DaftarMatakuliahPage> createState() => _DaftarMatakuliahPageState();
}

class _DaftarMatakuliahPageState extends State<DaftarMatakuliahPage> {
  List<dynamic> daftarMatakuliah = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Warna konsisten
  final Color primaryColor = Color(0xFF003366); 
  final Color accentColor = Color(0xFFF7931E);

  @override
  void initState() {
    super.initState();
    fetchMatakuliah();
  }

  Future<void> fetchMatakuliah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.get(
        '${ApiService.baseUrl}matakuliah/daftar-matakuliah',
      );

      if (response.statusCode == 200 && response.data["status"] == 200) {
        setState(() {
          // Asumsi: data['id'] adalah idKrsDetail yang diperlukan AbsenPage
          daftarMatakuliah = response.data["data"]; 
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.data["msg"] ?? 'Gagal memuat data';
          isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        errorMessage =
            e.response?.data["message"] ?? 'Terjadi kesalahan koneksi';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sudah menggunakan tema global (primaryColor/Navy) dari main.dart
      appBar: AppBar(
        title: Text('Daftar Mata Kuliah'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: daftarMatakuliah.length,
                  itemBuilder: (context, index) {
                    final mk = daftarMatakuliah[index];
                    
                    // Cek ketersediaan data kunci
                    final namaMatkul = mk['nama_matakuliah'] ?? 'Mata Kuliah Tanpa Nama';
                    final idKrsDetail = mk['id'] as int? ?? 0; // Asumsi 'id' adalah idKrsDetail

                    return Card(
                      elevation: 5, // Lebih tegas
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              mk['jumlah_sks']?.toString() ?? '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          namaMatkul,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Kode: ${mk['kode'] ?? '-'}'),
                            Text('Semester: ${mk['semester'] ?? '-'}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: accentColor),
                        onTap: () {
                          // Navigasi ke AbsenPage yang sudah kita perbaiki
                          if (idKrsDetail > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AbsenPage(
                                  idKrsDetail: idKrsDetail,
                                  namaMatkul: namaMatkul,
                                ),
                              ),
                            );
                          } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ID Mata Kuliah tidak valid untuk Absensi.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}