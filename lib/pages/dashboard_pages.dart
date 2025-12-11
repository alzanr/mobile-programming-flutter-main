import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import './detail_berita_pages.dart';
import './jadwal_page.dart';
import './profile_pages.dart';
import './input_krs_page.dart';
import './khs_page.dart';

class DashboardPages extends StatefulWidget {
  const DashboardPages({super.key});

  @override
  State<DashboardPages> createState() => _DashboardPagesState();
}

class _DashboardPagesState extends State<DashboardPages> {
  Map<String, dynamic>? user;
  List<dynamic> beritaAkademik = [];
  
  // Warna konsisten
  final Color primaryColor = const Color(0xFF003366); 
  final Color accentColor = const Color(0xFFF7931E);

  final List<Map<String, dynamic>> menuItems = const [
    {"icon": Icons.school, "label": "KRS"},
    {"icon": Icons.grade, "label": "KHS"},
    {"icon": Icons.calendar_month, "label": "Matakuliah"}, // Menu ini navigasi ke JadwalPage
    {"icon": Icons.person, "label": "Profil"},
    {"icon": Icons.bar_chart, "label": "IPK"},
    {"icon": Icons.help, "label": "Bantuan"},
    {"icon": Icons.settings, "label": "Pengaturan"},
  ];

  @override
  void initState() {
    super.initState();
    _getMahasiswaData();
    _getBeritaAkademik();
  }

  // ===== GET DATA MAHASISWA =====
  Future<void> _getMahasiswaData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      final email = prefs.getString("auth_email");

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-type'] = 'application/json';

      final response = await dio.post(
        "${ApiService.baseUrl}mahasiswa/detail-mahasiswa",
        data: {"email": email},
      );
      setState(() {
        user = response.data["data"];
      });
    } catch (e) {
      debugPrint("Error getMahasiswa: $e");
    }
  }

  // ===== GET BERITA AKADEMIK =====
  Future<void> _getBeritaAkademik() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-type'] = 'application/json';

      final response = await dio.get("${ApiService.baseUrl}info/berita");
      setState(() {
        beritaAkademik = response.data["data"] ?? [];
      });
    } catch (e) {
      debugPrint("Error getBerita: $e");
    }
  }

  // ====== HANDLE MENU CLICK ======
 void _onMenuTap(String label) {
  if (label == "Matakuliah") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JadwalPage()),
    );
  } else if (label == "Profil") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePages()),
    );
  } else if (label == "KRS") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InputKrsPage()),
    );
  } else if (label == "KHS") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KhsPage()),
    );
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu "$label" belum tersedia')));
  }
}


  @override
  Widget build(BuildContext context) {
    final hasFoto =
        (user?["foto"] != null &&
            (user?["foto"]?.toString().isNotEmpty ?? false));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Mahasiswa"),
        centerTitle: true,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16), 
              child: Column(
                children: [
                  // ===== PROFILE CARD =====
                  Container(
                    padding: const EdgeInsets.all(18), 
                    decoration: BoxDecoration(
                      color: primaryColor, 
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage: hasFoto
                              ? NetworkImage(user!["foto"])
                              : null,
                          child: !hasFoto
                              ? Icon(Icons.person_rounded, color: primaryColor, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selamat Datang,",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                user?["nama"] ?? "-",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?["nim"] ?? "-",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${user?["program_studi"]?["nama_prodi"] ?? '-'} - ${user?["angkatan"] ?? '-'}",
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== MENU GRID =====
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: menuItems
                        .map(
                          (item) => GestureDetector(
                            onTap: () => _onMenuTap(item["label"] as String),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
                                  ),
                                  child: Icon(
                                    item["icon"] as IconData,
                                    color: primaryColor, 
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item["label"] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 30),

                  // ===== BERITA AKADEMIK LIST =====
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Berita & Informasi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  beritaAkademik.isEmpty
                      ? const Text("Belum Ada berita Akademik")
                      : ListView.builder(
                          itemCount: beritaAkademik.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final berita = beritaAkademik[index];
                            final judul = berita["judul"] ?? "Tanpa Judul";
                            final tanggal = berita["createdAt"] ?? "";

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.article_rounded,
                                    color: accentColor, 
                                  ),
                                ),
                                title: Text(
                                  judul,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Tanggal: ${tanggal.split('T').first}", 
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailBeritaPages(berita: berita),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}