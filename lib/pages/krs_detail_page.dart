import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_service.dart';
import './absen_page.dart';

class KrsDetailPage extends StatefulWidget {
  final int idKrs;
  final String semester;
  final String tahunAjaran;

  const KrsDetailPage({
    super.key,
    required this.idKrs,
    required this.semester,
    required this.tahunAjaran,
  });

  @override
  State<KrsDetailPage> createState() => _KrsDetailPageState();
}

class _KrsDetailPageState extends State<KrsDetailPage> {
  // Warna konsisten
  final Color primaryColor = Color(0xFF003366);
  final Color accentColor = Color(0xFFF7931E);

  List<dynamic> daftarMatkul = [];
  bool isLoading = true;
  double totalSKS = 0;

  @override
  void initState() {
    super.initState();
    _getDetailKrs();
  }

  // ====================================================
  // BUKA LINK ZOOM
  // ====================================================
  Future<void> _openZoom(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Link Zoom tidak tersedia"),
          backgroundColor: accentColor,
        ),
      );
      return;
    }

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal membuka Zoom. Pastikan aplikasi Zoom terinstal."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ====================================================
  // HAPUS MATAKULIAH DARI KRS
  // ====================================================
  Future<void> _hapusMatakuliah(int idKrsDetail) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final response = await dio.delete(
        "${ApiService.baseUrl}krs/hapus-course-krs?id=${idKrsDetail}",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message'] ?? "Matakuliah berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );

      _getDetailKrs(); // Refresh list
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data['message'] ?? "Gagal menghapus matakuliah"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ====================================================
  // GET DETAIL KRS (LIST MATKUL)
  // ====================================================
  Future<void> _getDetailKrs() async {
    setState(() {
      isLoading = true;
      totalSKS = 0;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    final url = "${ApiService.baseUrl}krs/detail-krs?id_krs=${widget.idKrs}";

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200 && response.data['status'] == 200) {
        double tempSKS = 0;
        final list = response.data['data'] ?? [];
        for (var mk in list) {
          tempSKS += (mk['jumlah_sks'] as num?)?.toDouble() ?? 0;
        }

        setState(() {
          daftarMatkul = list;
          totalSKS = tempSKS;
        });
      }
    } on DioException catch (e) {
      debugPrint("Error get KRS: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data['message'] ?? "Gagal memuat detail KRS"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ====================================================
  // TAMBAH MATAKULIAH (BOTTOM SHEET)
  // ====================================================
  void _tambahMatkulModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return TambahMatkulSheet(
          idKrs: widget.idKrs,
          onSuccess: () => _getDetailKrs(),
        );
      },
    );
  }

  // ====================================================
  // UI UTAMA
  // ====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail KRS Semester ${widget.semester}"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahMatkulModal,
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_circle_outline),
        label: Text("Tambah Matkul"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tahun Ajaran: ${widget.tahunAjaran}",
                        style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Total SKS: ${totalSKS.toStringAsFixed(0)}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // List Matkul
                Expanded(
                  child: daftarMatkul.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada matakuliah yang dipilih.\nTekan tombol (+) untuk menambahkan.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: daftarMatkul.length,
                          itemBuilder: (context, index) {
                            final mk = daftarMatkul[index];
                            return _buildMatkulCard(mk);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // ====================================================
  // CARD MATA KULIAH
  // ====================================================
  Widget _buildMatkulCard(Map<String, dynamic> mk) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Matkul
            Text(
              mk['nama_matakuliah'] ?? '-',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            
            // Detail SKS dan Dosen
            Row(
              children: [
                Icon(Icons.class_outlined, size: 16, color: accentColor),
                const SizedBox(width: 5),
                Text("SKS: ${mk['jumlah_sks']?.toString() ?? '-'}"),
                const SizedBox(width: 15),
                Icon(Icons.person_outline, size: 16, color: accentColor),
                const SizedBox(width: 5),
                Expanded(child: Text("Dosen: ${mk['dosen'] ?? '-'}")),
              ],
            ),
            const SizedBox(height: 5),
            
            // Jadwal
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: accentColor),
                const SizedBox(width: 5),
                Text(
                  "Jadwal: ${mk['nama_hari'] ?? '-'}, ${mk['jam_mulai'] ?? '-'} - ${mk['jam_selesai'] ?? '-'}",
                ),
              ],
            ),
            const Divider(height: 25),

            // BUTTONS: Zoom, Absen, Hapus
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // BUTTON ZOOM
                Tooltip(
                  message: "Buka Link Zoom",
                  child: OutlinedButton.icon(
                    onPressed: () => _openZoom(mk['zoom_link']),
                    icon: Icon(Icons.video_camera_front, size: 20),
                    label: Text("Zoom"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // BUTTON ABSEN
                Tooltip(
                  message: "Masuk Absen",
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AbsenPage(
                            idKrsDetail: mk['id'],
                            namaMatkul: mk['nama_matakuliah'],
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.check_circle_outline, size: 20),
                    label: Text("Absen"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // BUTTON HAPUS
                Tooltip(
                  message: "Hapus Matakuliah dari KRS",
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 24),
                    onPressed: () => _hapusMatakuliah(mk['id']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// SHEET TAMBAH MATKUL - KODE SIAP TEMPEL YANG DIPERBAIKI
// ====================================================================

class TambahMatkulSheet extends StatefulWidget {
  final int idKrs;
  final VoidCallback onSuccess;

  const TambahMatkulSheet({
    super.key,
    required this.idKrs,
    required this.onSuccess,
  });

  @override
  State<TambahMatkulSheet> createState() => _TambahMatkulSheetState();
}

class _TambahMatkulSheetState extends State<TambahMatkulSheet> {
  // Warna konsisten
  final Color primaryColor = Color(0xFF003366);
  final Color accentColor = Color(0xFFF7931E);
  
  List<dynamic> daftarMatkulTersedia = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMatkul();
  }

  Future<void> loadMatkul() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final res = await dio.get("${ApiService.baseUrl}jadwal/daftar-jadwal");

      // PERBAIKAN: Mengganti kunci (key) ekstrak data dari 'jadwals' menjadi 'data' 
      // (asumsi API Anda menggunakan 'data' sebagai kunci umum)
      // Jika masih gagal, ganti lagi menjadi 'jadwals' atau kunci yang benar
      setState(() {
        // Coba periksa apakah API mengembalikan data dalam kunci 'data' atau 'jadwals'
        if (res.data['data'] != null) {
          daftarMatkulTersedia = res.data['data'] ?? [];
        } else {
          // Jika 'data' tidak ada, kembali ke kunci 'jadwals' yang ada di kode Anda sebelumnya
          daftarMatkulTersedia = res.data['jadwals'] ?? [];
        }
      });
      
      // Tambahkan debug print untuk memverifikasi data yang diterima
      debugPrint("API Response Status: ${res.data['status']}");
      debugPrint("Jumlah Matkul Diterima: ${daftarMatkulTersedia.length}");

    } on DioException catch (e) {
      debugPrint("ERROR LOAD MATKUL: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.response?.data['message'] ?? "Gagal memuat matakuliah")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> tambahMatkul(int idJadwal) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final res = await dio.post(
        "${ApiService.baseUrl}krs/tambah-course-krs",
        data: {"id_krs": widget.idKrs, "id_jadwal": idJadwal},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.data['message']),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSuccess();
      Navigator.pop(context); // Tutup modal setelah berhasil
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data['message'] ?? "Gagal menambahkan matakuliah"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 15),
          ),
          Text(
            "Pilih Matakuliah Tersedia",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : daftarMatkulTersedia.isEmpty
                    ? const Center(child: Text("Tidak ada matakuliah tersedia saat ini."))
                    : ListView.builder(
                        itemCount: daftarMatkulTersedia.length,
                        itemBuilder: (context, index) {
                          final mk = daftarMatkulTersedia[index];

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: Icon(Icons.school, color: accentColor),
                              title: Text(
                                mk['nama_matakuliah'] ?? '-',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "SKS: ${mk['jumlah_sks'] ?? '-'} | ${mk['nama_hari'] ?? '-'}, ${mk['jam_mulai'] ?? '-'} - ${mk['jam_selesai'] ?? '-'}",
                                style: TextStyle(fontSize: 12),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => tambahMatkul(mk['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                child: Text("Tambah"),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}