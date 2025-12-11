import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import './webcam_helper.dart';
import '../api/api_service.dart';

class AbsenSubmitPage extends StatefulWidget {
  final int idKrsDetail;
  final int pertemuan;
  final String namaMatkul;

  const AbsenSubmitPage({
    super.key,
    required this.idKrsDetail,
    required this.pertemuan,
    required this.namaMatkul,
  });

  @override
  State<AbsenSubmitPage> createState() => _AbsenSubmitPageState();
}

class _AbsenSubmitPageState extends State<AbsenSubmitPage> {
  final WebCamera cam = WebCamera();

  Uint8List? imageBytes;
  Position? position;

  bool isCameraReady = false;
  bool isSubmitting = false;

  // Warna konsisten
  final Color primaryColor = Color(0xFF003366); 
  final Color accentColor = Color(0xFFF7931E);

  @override
  void initState() {
    super.initState();

    /// TIDAK BOLEH init kamera di sini (DOM belum ada)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCameraAfterRender();
    });
  }

  Future<void> _initializeCameraAfterRender() async {
    try {
      // Pastikan DOM webcam sudah muncul
      await Future.delayed(const Duration(milliseconds: 300));

      await cam.initialize();
      setState(() => isCameraReady = true);
    } catch (e) {
      debugPrint("Error init camera: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal akses kamera: $e")));
    }
  }

  @override
  void dispose() {
    cam.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final data = await cam.capture();
      setState(() => imageBytes = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil foto")));
    }
  }

  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi tidak aktif")));
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Izin lokasi ditolak")));
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() => position = pos);
  }

  // FUNGSI INI SUDAH DIMODIFIKASI DENGAN LOGIKA GEO-FENCING
  Future<void> _submitAbsen() async {
    // --- 1. VALIDASI FOTO DAN LOKASI ---
    if (imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Foto belum diambil")));
      return;
    }
    if (position == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi belum diambil")));
      return;
    }

    // --- 2. LOGIKA GEO-FENCING ---
    // Koordinat Kampus (Titik Pusat Geo-Fence)
    const double campusLat = -7.439289057458994; // LATITUDE KAMPUS
    const double campusLng = 109.26620032849641; // LONGITUDE KAMPUS
    const double maxDistance = 100; // Maksimal 100 meter

    // Menghitung jarak (menggunakan library geolocator)
    double distanceInMeters = Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      campusLat,
      campusLng,
    );

    debugPrint("Jarak dari kampus: $distanceInMeters meter");

    // Geo-Fencing Check
    if (distanceInMeters > maxDistance) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text("GAGAL! Absensi hanya bisa dilakukan dalam radius 100 meter dari kampus."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Menghentikan proses submit
    }
    // --- AKHIR LOGIKA GEO-FENCING ---

    // Jika lolos Geo-Fencing:
    setState(() => isSubmitting = true);

    try {
      Dio dio = Dio();

      final form = FormData.fromMap({
        "id_krs_detail": widget.idKrsDetail,
        "pertemuan": widget.pertemuan,
        "latitude": position!.latitude,
        "longitude": position!.longitude,
        "foto": MultipartFile.fromBytes(
          imageBytes!,
          filename: "absen_${DateTime.now().millisecondsSinceEpoch}.png",
        ),
      });

      final res = await dio.post(
        "${ApiService.baseUrl}absensi/submit",
        data: form,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.data["message"] ?? "Absen berhasil")),
      );

      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal submit absen")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Absen - ${widget.namaMatkul} (Pertemuan ${widget.pertemuan})",
        ),
        // App Bar sudah menggunakan tema global (primaryColor/Navy) dari main.dart
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kamera:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const HtmlElementView(viewType: 'webcam-view'),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: isCameraReady ? _capturePhoto : null,
                icon: Icon(Icons.camera_alt),
                label: Text("Capture Foto", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            if (imageBytes != null) ...[
              const SizedBox(height: 20),
              Text("Hasil Foto:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(imageBytes!, height: 200, fit: BoxFit.cover),
                ),
              ),
            ],

            const Divider(height: 32),
            Text("Status Lokasi:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Koordinat Anda:",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    position == null
                        ? "Lokasi belum diambil"
                        : "Lat: ${position!.latitude.toStringAsFixed(6)}, Lng: ${position!.longitude.toStringAsFixed(6)}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _getLocation,
                      icon: Icon(Icons.my_location),
                      label: Text("Ambil Lokasi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitAbsen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSubmitting ? Colors.grey : accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("SUBMIT ABSENSI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}