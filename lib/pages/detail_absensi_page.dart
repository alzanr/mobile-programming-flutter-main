// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';

class DetailAbsensiPage extends StatefulWidget {
  final int idKrsDetail;
  final int pertemuan;
  final String namaMatkul;

  const DetailAbsensiPage({
    super.key,
    required this.idKrsDetail,
    required this.pertemuan,
    required this.namaMatkul,
  });

  @override
  State<DetailAbsensiPage> createState() => _DetailAbsensiPageState();
}

class _DetailAbsensiPageState extends State<DetailAbsensiPage> {
  bool isLoading = true;
  Map<String, dynamic>? data;
  String? mapViewType;

  // Warna konsisten
  final Color primaryColor = Color(0xFF003366); 
  final Color accentColor = Color(0xFFF7931E);

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    try {
      Dio dio = Dio();

      final url =
          "${ApiService.baseUrl}absensi/detail?id_krs_detail=${widget.idKrsDetail}&pertemuan=${widget.pertemuan}";

      final res = await dio.get(url);

      data = res.data["data"];

      if (data != null) {
        final lat = data!['latitude'];
        final lng = data!['longitude'];

        // unique id setiap map
        mapViewType = "maps-view-${DateTime.now().millisecondsSinceEpoch}";

        // register iframe MAP langsung DI SINI
        ui_web.platformViewRegistry.registerViewFactory(mapViewType!, (
          int viewId,
        ) {
          final iframe = html.IFrameElement()
            ..src = "https://www.google.com/maps?q=$lat,$lng&z=16&output=embed"
            ..style.border = "0"
            ..style.width = "100%"
            ..style.height = "100%";

          return iframe;
        });
        
        // Catatan: Inisiasi Peta di web dengan iframe sangat unik,
        // namun kodenya sudah benar diletakkan di dalam loadDetail()
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil data")));
    }
  }

  // Helper widget untuk baris detail
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              "$label :",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Absensi - ${widget.namaMatkul} (P.${widget.pertemuan})",
        ),
        // App Bar menggunakan tema global (primaryColor/Navy)
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : data == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Belum ada absensi untuk pertemuan ini. Silakan lakukan absensi terlebih dahulu.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FOTO BUKTI ABSENSI ---
                      Text(
                        "Foto Bukti Absensi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "${data!['foto']}",
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 240,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: CircularProgressIndicator(color: primaryColor),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 240,
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      const Divider(),
                      
                      // --- DETAIL DATA ---
                      Text(
                        "Data Absensi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 10),
                      
                      _buildDetailRow(
                        "Pertemuan",
                        "${data!['pertemuan']}",
                        Icons.meeting_room,
                      ),
                      _buildDetailRow(
                        "Waktu",
                        data!['created_at'] ?? '-',
                        Icons.access_time,
                      ),
                      _buildDetailRow(
                        "Latitude",
                        data!['latitude']?.toString() ?? '-',
                        Icons.location_on,
                      ),
                      _buildDetailRow(
                        "Longitude",
                        data!['longitude']?.toString() ?? '-',
                        Icons.location_on,
                      ),
                      
                      const Divider(),
                      const SizedBox(height: 20),

                      // --- PETA LOKASI ---
                      Text(
                        "Lokasi Absensi pada Peta",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 10),

                      if (mapViewType != null)
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: HtmlElementView(viewType: mapViewType!),
                          ),
                        ),
                        // Note: Peta di web sudah benar dirender menggunakan HtmlElementView dan platformViewRegistry.
                    ],
                  ),
                ),
    );
  }
}