import 'package:flutter/material.dart';

class DetailBeritaPages extends StatelessWidget {
  final Map<String, dynamic> berita;

  const DetailBeritaPages({super.key, required this.berita});
  
  // Warna konsisten
  static final Color primaryColor = Color(0xFF003366); 
  static final Color accentColor = Color(0xFFF7931E);

  @override
  Widget build(BuildContext context) {
    // Ambil tanggal dan format (membuang bagian waktu jika ada)
    final String tanggal = berita["createdAt"]?.split('T').first ?? "-";
    
    return Scaffold(
      // AppBar sudah menggunakan tema global (primaryColor/Navy) dari main.dart
      appBar: AppBar(
        title: Text("Detail Berita"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- JUDUL BERITA ---
            Text(
              berita["judul"] ?? "Judul Kosong",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: primaryColor
              ),
            ),
            const SizedBox(height: 8),
            
            // --- META (TANGGAL) ---
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: accentColor),
                const SizedBox(width: 5),
                Text(
                  "Diterbitkan: $tanggal",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            
            const Divider(height: 30),
            
            // --- GAMBAR/COVER (Jika ada) ---
            if (berita["image"] != null) 
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    berita["image"], // Ganti dengan key image yang sesuai dari API Anda
                    width: double.infinity,
                    fit: BoxFit.cover,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder jika gambar gagal dimuat
                      return Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            // --- ISI BERITA ---
            Text(
              berita["isi"] ?? "Tidak ada isi berita yang tersedia.",
              style: TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}