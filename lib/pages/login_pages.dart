import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:siakad/pages/dashboard_pages.dart';
import '../api/api_service.dart';
import 'register_pages.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  
  // Warna konsisten
  final Color primaryColor = Color(0xFF003366); 
  final Color accentColor = Color(0xFFF7931E);

  Future<void> doLogin() async {
    setState(() {
      isLoading = true;
    });
    final res = await ApiService.login(
      emailController.text,
      passwordController.text,
    );

    print('hasil dari response : ${res}');
    if (res['status'] == 200) {
      await ApiService.saveToken(res['data'], emailController.text);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Login Berhasil',
        onConfirmBtnTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPages()),
          );
        },
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Email / Password Salah!',
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0), // Padding lebih besar
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 1. HEADER BRANDING ---
                Icon(
                  Icons.school, 
                  size: 80,
                  color: primaryColor,
                ),
                const SizedBox(height: 10),
                Text(
                  "SIAKAD MOBILE",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryColor),
                ),
                Text(
                  "STIMIK WIDYA UTAMA",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // --- 2. INPUT FIELD MODERN ---
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email / NIM',
                    prefixIcon: Icon(Icons.person, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- 3. TOMBOL LOGIN BESAR ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      isLoading ? null : doLogin();
                    },
                    child: Text(
                      isLoading ? 'Memproses...' : 'LOGIN KE SISTEM',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Tombol Register
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPages()),
                    );
                  },
                  child: Text(
                    "Belum Punya Akun? Register",
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}