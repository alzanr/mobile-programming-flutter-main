import 'package:flutter/material.dart';

class KhsPage extends StatelessWidget {
  const KhsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF003366);
    final Color accent = const Color(0xFFF7931E);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kartu Hasil Studi"),
        centerTitle: true,
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================================================
            // ===============   INFO MAHASISWA   ====================
            // =======================================================
            Text(
              "Informasi Mahasiswa",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoItem("Nama", "Admin", primary),
                  _infoItem("NIM", "123456789", primary),
                  _infoItem("Semester", "5", primary),
                  _infoItem("IPK", "3.80", primary),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =======================================================
            // ===============   LIST MATKUL   ========================
            // =======================================================
            Text(
              "Daftar Nilai Mata Kuliah",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primary,
              ),
            ),

            const SizedBox(height: 15),

            _buildMatkulCard("Pemrograman Mobile", "A", 3, primary, accent),
            _buildMatkulCard("Basis Data", "B+", 3, primary, accent),
            _buildMatkulCard("Jaringan Komputer", "A-", 3, primary, accent),
            _buildMatkulCard("Bahasa Indonesia", "A", 2, primary, accent),
            _buildMatkulCard("Kalkulus", "B", 3, primary, accent),

            const SizedBox(height: 30),

            // =======================================================
            // ===============   RINGKASAN   ==========================
            // =======================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total SKS: 14",
                    style: TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "IPS: 3.78",
                    style: TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // =======================================================
  // ===============   COMPONENT: INFO ITEM   ===============
  // =======================================================
  Widget _infoItem(String label, String value, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // ===============   COMPONENT: MATKUL CARD   =============
  // =======================================================
  Widget _buildMatkulCard(
      String matkul, String nilai, int sks, Color primary, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.book_rounded, color: primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matkul,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text("SKS: $sks",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              nilai,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
