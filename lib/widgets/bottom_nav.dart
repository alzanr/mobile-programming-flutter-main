import 'package:flutter/material.dart';
import '../pages/profile_pages.dart';
import '../pages/dashboard_pages.dart';
// Jika Anda punya halaman lain, import di sini:
// import '../pages/search_pages.dart'; 
// import '../pages/favorite_pages.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Variabel warna di dalam State harus 'final'
  final Color primaryColor = const Color(0xFF003366); // Navy Blue
  final Color accentColor = const Color(0xFFF7931E);  // Orange

  int _currentIndex = 0;

  // DAFTAR HALAMAN
  final List<Widget> _pages = const [
    DashboardPages(),
    Center(child: Text("Halaman Pencarian (Coming Soon)")), 
    Center(child: Text("Halaman Favorit (Coming Soon)")), 
    ProfilePages(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body menampung semua halaman
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            // Hapus 'const' karena menggunakan primaryColor (final)
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        // Hapus 'const'
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          
          // Warna dan Tema Bottom Nav Bar
          backgroundColor: primaryColor,
          selectedItemColor: accentColor, 
          unselectedItemColor: Colors.white70, 
          // Hapus 'const' pada TextStyle yang menggunakan variabel warna
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: accentColor),
          unselectedLabelStyle: const TextStyle(fontSize: 10, color: Colors.white70), // Boleh const
          
          currentIndex: _currentIndex,
          onTap: _onItemTapped, 

          // items boleh 'const'
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 24),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 24),
              label: "Pencarian",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 24),
              label: "Favorite",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}