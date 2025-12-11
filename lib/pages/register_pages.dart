import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import '../api/api_service.dart';

class RegisterPages extends StatefulWidget {
  const RegisterPages({super.key});

  @override
  State<RegisterPages> createState() => _RegisterPagesState();
}

class _RegisterPagesState extends State<RegisterPages> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tglLahirController = TextEditingController();
  String? _jenisKelamin;
  final _alamat = TextEditingController();
  final _angkatan = TextEditingController();
  final _id_tahun = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscure = true;

  // Warna konsisten
  final Color primaryColor = Color(0xFF003366);
  final Color accentColor = Color(0xFFF7931E);
  
  // --- HELPER UNTUK TEXT FIELD DESIGN ---
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    );
  }


  void _registerAct() async {
    if (_formKey.currentState!.validate()) {
      final nama = _nameController.text;
      final tglLahir = _tglLahirController.text;
      final jenisKelamin = _jenisKelamin;
      final alamat = _alamat.text;
      final angkatan = _angkatan.text;
      final id_tahun = _id_tahun.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      
      // Mengunci form saat proses registrasi
      setState(() => _isObscure = true); 

      try {
        final dio = Dio();
        final response = await dio.post(
          '${ApiService.baseUrl}auth/register',
          data: {
            'nama': nama,
            'tgl_lahir': tglLahir,
            'jenis_kelamin': jenisKelamin,
            'alamat': alamat,
            'angkatan': angkatan,
            'id_tahun': id_tahun,
            'email': email,
            'password': password,
          },
        );
        if (response.data['status'] == 200) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil!',
            text: 'Registrasi Berhasil. Silakan Login menggunakan Email dan Password Anda.',
            confirmBtnColor: primaryColor,
            onConfirmBtnTap: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen (Login)
            },
          );
        } else {
             QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Gagal!',
              text: response.data['msg'] ?? 'Terjadi kesalahan saat registrasi.',
              confirmBtnColor: primaryColor,
            );
        }
      } on DioException catch (e) {
         QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Gagal Koneksi!',
            text: e.response?.data['message'] ?? 'Terjadi kesalahan koneksi atau server.',
            confirmBtnColor: primaryColor,
          );
      }
    }
  }

  Future<void> _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor, // Header color
            colorScheme: ColorScheme.light(primary: primaryColor), // Button color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tglLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrasi Akun Mahasiswa"),
        // App Bar sudah menggunakan tema global (primaryColor/Navy) dari main.dart
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lengkapi Data Diri Anda",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const Divider(height: 30),

              // 1. Form input nama
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Nama Lengkap", Icons.person_outline),
                validator: (value) =>
                    value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              
              // 2. Jenis Kelamin
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Jenis Kelamin", Icons.people_outline),
                value: _jenisKelamin,
                items: const [
                  DropdownMenuItem(value: "L", child: Text("Laki-laki")),
                  DropdownMenuItem(value: "P", child: Text("Perempuan")),
                ],
                onChanged: (value) => setState(() => _jenisKelamin = value),
                validator: (v) => v == null ? "Pilih jenis kelamin" : null,
              ),
              const SizedBox(height: 16),

              // 3. Form input tanggal lahir
              TextFormField(
                controller: _tglLahirController,
                readOnly: true,
                decoration: _inputDecoration("Tanggal Lahir (YYYY-MM-DD)", Icons.calendar_today).copyWith(
                   suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_month, color: accentColor),
                    onPressed: _pilihTanggal,
                  ),
                ),
                onTap: _pilihTanggal,
                validator: (v) =>
                    v!.isEmpty ? "Tanggal lahir wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // 4. Form Input Alamat
              TextFormField(
                controller: _alamat,
                decoration: _inputDecoration("Alamat Lengkap", Icons.location_on_outlined),
                maxLines: 2,
                validator: (value) =>
                    value!.isEmpty ? "Alamat tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              
              // 5. Form Inputan Angkatan
              TextFormField(
                controller: _angkatan,
                decoration: _inputDecoration("Angkatan (Contoh: 2021)", Icons.school_outlined),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Angkatan tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              
              // 6. Form Input Tahun Masuk (Sepertinya sama dengan Angkatan, pastikan di API)
              TextFormField(
                controller: _id_tahun,
                decoration: _inputDecoration("ID Tahun Masuk (Contoh: 1)", Icons.date_range),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "ID Tahun Masuk tidak boleh kosong" : null,
              ),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 10),
              
              Text(
                "Akun Login",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const Divider(height: 30),

              // 7. Form Input Email
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("Email Aktif", Icons.mail_outline),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return "Email tidak boleh kosong";
                  if (!value.contains('@')) return "Format email tidak valid";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 8. Form Input Password
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: _inputDecoration("Password", Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() => _isObscure = !_isObscure);
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Password tidak boleh kosong";
                  if (value.length < 6) return "Password minimal 6 karakter";
                  return null;
                }
              ),
              const SizedBox(height: 16),
              
              // 9. form confirmation password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isObscure,
                decoration: _inputDecoration("Konfirmasi Password", Icons.lock_outline).copyWith(
                   suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() => _isObscure = !_isObscure);
                    },
                  ),
                ),
                validator: (value) => value != _passwordController.text
                    ? "Konfirmasi password tidak sesuai"
                    : null,
              ),
              
              const SizedBox(height: 32),
              
              // Button Aksi untuk register
              ElevatedButton.icon(
                onPressed: _registerAct,
                icon: Icon(Icons.app_registration),
                label: Text(
                  "DAFTAR SEKARANG",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}