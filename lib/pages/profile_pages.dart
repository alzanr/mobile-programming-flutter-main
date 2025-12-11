import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';

class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  State<ProfilePages> createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
  Map<String, dynamic>? user;
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  // Warna konsisten
  final Color primaryColor = Color(0xFF003366);
  final Color accentColor = Color(0xFFF7931E);

  // Controller biodata
  final namaC = TextEditingController();
  final jkC = TextEditingController();
  final tglC = TextEditingController();
  final alamatC = TextEditingController();
  final statusC = TextEditingController();

  // Gambar (support Web & Mobile)
  Uint8List? webImage;
  XFile? pickedFile;

  @override
  void initState() {
    super.initState();
    _getMahasiswaData();
  }
  
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

  Future<void> _getMahasiswaData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final email = prefs.getString('auth_email');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final response = await dio.post(
        "${ApiService.baseUrl}mahasiswa/detail-mahasiswa",
        data: {"email": email},
      );

      setState(() {
        user = response.data['data'];
        namaC.text = user?['nama'] ?? '';
        jkC.text = user?['jenis_kelamin'] ?? '';
        tglC.text = user?['tanggal_lahir'] ?? '';
        alamatC.text = user?['alamat'] ?? '';
        statusC.text = user?['status'] ?? '';
      });
    } catch (e) {
      // Handle error fetching data if necessary
      debugPrint("Error fetching profile data: $e");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          webImage = bytes;
          pickedFile = image;
        });
        _uploadFotoWeb(bytes, image.name);
      } else {
        setState(() {
          pickedFile = image;
        });
        _uploadFotoMobile(image);
      }
    }
  }

  Future<void> _uploadFotoMobile(XFile image) async {
    setState(() => isLoading = true);
    // Logika upload foto Mobile (sudah benar, tidak diubah)
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final nim = user?['nim'];

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'nim': nim,
        'foto': await MultipartFile.fromFile(image.path),
      });

      final response = await dio.post(
        "${ApiService.baseUrl}mahasiswa/upload-foto-mahasiswa",
        data: formData,
      );

      if (response.data['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diperbarui!")),
        );
        _getMahasiswaData();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload foto: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadFotoWeb(Uint8List bytes, String filename) async {
    setState(() => isLoading = true);
    // Logika upload foto Web (sudah benar, tidak diubah)
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final nim = user?['nim'];

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'nim': nim,
        'foto': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await dio.post(
        "${ApiService.baseUrl}mahasiswa/upload-foto-mahasiswa",
        data: formData,
      );

      if (response.data['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diperbarui!")),
        );
        _getMahasiswaData();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload foto: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateBiodata() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    // Logika update biodata (sudah benar, tidak diubah)
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final nim = user?['nim'];

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.put(
        "${ApiService.baseUrl}mahasiswa/update-mahasiswa",
        data: {
          "nim": nim,
          "nama": namaC.text,
          "jenis_kelamin": jkC.text,
          "tanggal_lahir": tglC.text,
          "alamat": alamatC.text,
          "status": statusC.text,
        },
      );

      if (response.data['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biodata berhasil diperbarui!")),
        );
        _getMahasiswaData();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal update biodata: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoUrl = user?["foto"];
    final hasFoto = (fotoUrl != null && fotoUrl != "");

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Mahasiswa"),
        // App Bar menggunakan tema global (primaryColor/Navy) dari main.dart
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // --- FOTO PROFIL ---
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: primaryColor.withOpacity(0.2), // Border/ring
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: kIsWeb && webImage != null
                                  ? MemoryImage(webImage!)
                                  : hasFoto
                                      ? NetworkImage(fotoUrl!)
                                      : const AssetImage("assets/images/default_user.png")
                                          as ImageProvider,
                              child: !hasFoto && webImage == null
                                  ? Icon(Icons.person, size: 50, color: primaryColor)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: accentColor, // Warna kamera Orange Aksen
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- BIODATA FORM ---
                    TextFormField(
                      controller: namaC,
                      decoration: _inputDecoration("Nama Lengkap", Icons.person_outline),
                      validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: jkC,
                      decoration: _inputDecoration("Jenis Kelamin", Icons.people_outline),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: tglC,
                      decoration: _inputDecoration("Tanggal Lahir (YYYY-MM-DD)", Icons.calendar_today),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: alamatC,
                      decoration: _inputDecoration("Alamat", Icons.location_on_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: statusC,
                      decoration: _inputDecoration("Status", Icons.info_outline),
                    ),
                    const SizedBox(height: 30),

                    // --- TOMBOL SIMPAN ---
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _updateBiodata,
                      icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.save),
                      label: Text(
                        isLoading ? "Menyimpan Data..." : "SIMPAN PERUBAHAN",
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