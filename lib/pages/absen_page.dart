// File: lib/pages/absen_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // Digunakan untuk mendapatkan token
import '../api/api_service.dart'; // Digunakan untuk memanggil API Absensi

class AbsenPage extends StatefulWidget {
  final int idKrsDetail;
  final String namaMatkul;

  const AbsenPage({
    super.key,
    required this.idKrsDetail,
    required this.namaMatkul,
  });

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  final Color primaryColor = const Color(0xFF003366);
  final Color accentColor = const Color(0xFFF79931E);

  // Status Lokasi
  Position? _currentPosition;
  bool _isLocationServiceEnabled = false;
  
  // Status Absensi Dummy (Waktu Kuliah) - HARUS DIGANTI DENGAN LOGIKA WAKTU NYATA
  bool _isAbsenTime = true; 
  
  // Koordinat Kampus (HARUS DIGANTI dengan koordinat kampus Anda)
// File: lib/pages/absen_page.dart

// ... sekitar baris 40

// Koordinat Kampus (DIUBAH SEMENTARA UNTUK PENGUJIAN)
static const double _targetLatitude = -7.435895655096047; // <--- GANTI DI SINI
static const double _targetLongitude = 109.26229870593076; // <--- GANTI DI SINI
static const double _maxDistanceMeters = 50.0; // Toleransi jarak (50 meter)

// ...
  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  // ====== FUNGSI GEOLOCATOR (DAPATKAN LOKASI) ======
  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLocationServiceEnabled = false;
      });
      return;
    }
    setState(() {
      _isLocationServiceEnabled = true;
    });

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _getLiveLocation();
  }

  void _getLiveLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, 
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  // Hitung Jarak
  bool _isWithinRange() {
    if (_currentPosition == null) return false;
    
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _targetLatitude,
      _targetLongitude,
    );
    
    return distance <= _maxDistanceMeters;
  }
  // ===================================================

  // ====== FUNGSI ABSENSI (Aksi Tombol: Panggil API) ======
  void _submitAbsen() async { 
    if (_currentPosition == null || !_isAbsenTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda tidak berada dalam waktu atau lokasi absensi yang valid.')),
      );
      return;
    }

    if (!_isWithinRange()) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda berada di luar radius kampus yang diizinkan (50 meter).')),
      );
      return;
    }

    // 1. Ambil Token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi pengguna berakhir. Silakan login kembali.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengirim data absensi...')),
    );

    // 2. Panggil API Service
    final result = await ApiService.submitAbsen(
      idKrsDetail: widget.idKrsDetail,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      token: token,
    );

    // 3. Tangani Hasil
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
    
    if (result.containsKey('error') && result['error'] == true) {
      // GAGAL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal Absen: ${result['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // SUKSES
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Absensi berhasil untuk ${widget.namaMatkul}!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
  // ===========================================

  @override
  Widget build(BuildContext context) {
    bool canAbsen = _currentPosition != null && _isWithinRange() && _isAbsenTime;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Absensi"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Mata Kuliah
            _buildInfoCard(
              title: widget.namaMatkul,
              subtitle: 'ID KRS Detail: ${widget.idKrsDetail}',
              icon: Icons.school,
            ),
            
            const SizedBox(height: 20),

            // Status Lokasi (Pengecekan Geolocation)
            _buildStatusCard(),

            const SizedBox(height: 20),

            // Posisi Saat Ini
            _buildCurrentPositionCard(),

            const SizedBox(height: 30),

            // Tombol Utama Absensi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canAbsen ? _submitAbsen : null, 
                icon: const Icon(Icons.check_circle),
                label: Text(
                  canAbsen ? "ABSEN SEKARANG" : "Tidak Dapat Absen (Cek Status di Atas)",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            
            if (!canAbsen)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "* Pastikan waktu kuliah sedang berlangsung, GPS aktif, dan Anda berada dalam radius kampus.",
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor = _isLocationServiceEnabled 
        ? (_currentPosition != null && _isWithinRange() ? Colors.green : Colors.orange)
        : Colors.red;
    
    IconData statusIcon = _isLocationServiceEnabled 
        ? (_currentPosition != null && _isWithinRange() ? Icons.check_circle : Icons.warning)
        : Icons.error;
    
    String rangeText = _currentPosition != null 
        ? (_isWithinRange() ? "Anda berada di area yang diizinkan." : "Anda berada di luar batas area kampus.")
        : "Menunggu posisi...";
    
    return Card(
      elevation: 4,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: statusColor)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 10),
                Text(
                  "Status Lokasi Absensi",
                  style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow(Icons.gps_fixed, "GPS", _isLocationServiceEnabled ? "Aktif" : "Nonaktif", _isLocationServiceEnabled ? Colors.green : Colors.red),
            _buildDetailRow(Icons.location_on, "Radius Kampus", rangeText, _isWithinRange() ? Colors.green : Colors.red),
            _buildDetailRow(Icons.timer, "Waktu Absen", _isAbsenTime ? "MASA KULIAH BERLANGSUNG" : "Di Luar Waktu Kuliah", _isAbsenTime ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPositionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Data Geolocation (Debugging)", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const Divider(),
            _buildDetailRow(Icons.my_location, "Latitude", _currentPosition?.latitude.toStringAsFixed(6) ?? "N/A", Colors.black),
            _buildDetailRow(Icons.my_location, "Longitude", _currentPosition?.longitude.toStringAsFixed(6) ?? "N/A", Colors.black),
            _buildDetailRow(Icons.location_searching, "Akurasi", _currentPosition?.accuracy.toStringAsFixed(2) ?? "N/A", Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 120, 
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}