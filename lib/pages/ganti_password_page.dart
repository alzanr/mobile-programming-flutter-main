import 'package:flutter/material.dart';

class GantiPasswordPage extends StatefulWidget {
  const GantiPasswordPage({super.key});

  @override
  State<GantiPasswordPage> createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPass = TextEditingController();
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password berhasil diganti!"),
          backgroundColor: Colors.green.shade600,
        ),
      );
      Navigator.pop(context); // kembali ke Pengaturan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ganti Password"),
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              const SizedBox(height: 10),

              // OLD PASSWORD
              const Text(
                "Password Lama",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: oldPass,
                obscureText: !showOld,
                decoration: InputDecoration(
                  hintText: "Masukkan password lama",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(showOld ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => showOld = !showOld),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Password lama tidak boleh kosong";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // NEW PASSWORD
              const Text(
                "Password Baru",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: newPass,
                obscureText: !showNew,
                decoration: InputDecoration(
                  hintText: "Masukkan password baru",
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(showNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => showNew = !showNew),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Password baru tidak boleh kosong";
                  if (value.length < 6) return "Minimal 6 karakter";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // CONFIRM PASSWORD
              const Text(
                "Konfirmasi Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: confirmPass,
                obscureText: !showConfirm,
                decoration: InputDecoration(
                  hintText: "Konfirmasi password baru",
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(showConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => showConfirm = !showConfirm),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Konfirmasi password tidak boleh kosong";
                  if (value != newPass.text) return "Password tidak sama";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // BUTTON SIMPAN
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    "Simpan Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
