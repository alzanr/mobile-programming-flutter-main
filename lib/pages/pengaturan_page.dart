import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_pages.dart';
import 'ganti_password_page.dart';
import 'login_pages.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ========================= AKUN =========================
          const Text(
            "Akun",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profil"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePages()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Ganti Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GantiPasswordPage()),
              );
            },
          ),

          const SizedBox(height: 25),

          // ========================= LAINNYA =========================
          const Text(
            "Lainnya",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Tentang Aplikasi"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (!mounted) return;

              // LOGOUT FIX: tidak pakai named route
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPages()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
