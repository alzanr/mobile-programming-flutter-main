import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siakad/widgets/bottom_nav.dart'; 
// FIX 1: Perbaiki import ke 'login_pages.dart' (dengan 's')
import 'package:siakad/pages/login_pages.dart'; 
import 'package:siakad/pages/dashboard_pages.dart';
import 'package:siakad/api/api_service.dart';

// FIX 2: HAPUS SEMUA kode iframe/webcam/html/ui yang ada di luar main() atau MyApp

// Deklarasikan Warna Global sebagai konstanta di main.dart
const Color primaryColor = Color(0xFF003366); // Navy Blue (dari seed)
const Color accentColor = Color(0xFFF7931E); // Orange

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIAKAD',
      theme: ThemeData(
        // FIX 3: Gunakan warna konstan yang sudah dideklarasikan di luar
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        primaryColor: primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor, 
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 20
          ),
        ),
        useMaterial3: true,
      ),
      
      // Halaman utama
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // FIX: Hapus const
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final prefs = snapshot.data;
          final String? token = prefs?.getString('auth_token');

          if (token != null) {
            // FIX: Gunakan const jika MainWrapper adalah Stateless/Final
            return const MainWrapper(); 
          } else {
            // FIX: Gunakan const jika LoginPages adalah Stateless/Final
            return const LoginPages(); 
          }
        },
      ),
    );
  }
}

// Hapus bagian 'Widget build(BuildContext context)' di Baris 47-54 jika ada duplikasi. 
// Bagian tersebut tampak seperti sisa kode pengujian web.