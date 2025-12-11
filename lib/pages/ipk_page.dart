import 'package:flutter/material.dart';

class IpkPage extends StatelessWidget {
  const IpkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF003366);
    final Color accent = const Color(0xFFF7931E);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Indeks Prestasi Kumulatif"),
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
                  _infoItem("Total SKS", "110", primary),
                  _infoItem("IPK Terakhir", "3.80", primary),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =======================================================
            // ===============   RINGKASAN IPK   =====================
            // =======================================================
            Text(
              "Ringkasan IPK",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primary,
              ),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryItem("Total Mata Kuliah", "38", primary),
                  _summaryItem("Total Bobot Nilai", "418.0", primary),
                  _summaryItem("Rata-Rata IPS", "3.72", primary),
                  _summaryItem("Predikat", "Sangat Baik", primary),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =======================================================
            // ===============   LIST IPS PER SEMESTER  ===============
            // =======================================================
            Text(
              "Perkembangan IPS per Semester",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primary,
              ),
            ),
            const SizedBox(height: 15),

            _buildSemesterCard("Semester 1", "3.50", 20, primary, accent),
            _buildSemesterCard("Semester 2", "3.70", 20, primary, accent),
            _buildSemesterCard("Semester 3", "3.85", 18, primary, accent),
            _buildSemesterCard("Semester 4", "3.78", 18, primary, accent),
            _buildSemesterCard("Semester 5", "3.92", 17, primary, accent),
            _buildSemesterCard("Semester 6", "3.88", 17, primary, accent),

            const SizedBox(height: 30),
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
            width: 120,
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
  // ===============   COMPONENT: SUMMARY ITEM   ===========
  // =======================================================
  Widget _summaryItem(String label, String value, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: primary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )),
          Text(
            value,
            style: TextStyle(
              color: primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  // =======================================================
  // ===============   COMPONENT: SEMESTER CARD  ===========
  // =======================================================
  Widget _buildSemesterCard(
      String semester, String ips, int sks, Color primary, Color accent) {
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
          Icon(Icons.bar_chart_rounded, color: primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  semester,
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
              ips,
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
