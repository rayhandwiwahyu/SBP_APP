import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'dashboard_page.dart';
import 'riwayat_page.dart';
import 'input_data_warga_page.dart';
import 'profile_page.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  static const Color primaryBlue   = Color(0xFF1565C0);
  static const Color bgDark        = Color(0xFF0D1B2A);
  static const Color successGreen  = Color(0xFF2E7D32);
  static const Color dangerRed     = Color(0xFFC62828);

  Map<String, dynamic>? _rekap;
  bool _isLoading = true;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _loadRekap();
  }

  Future<void> _loadRekap() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService.ambilDataRekap();
      setState(() {
        _rekap     = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cetakPDF() async {
    if (_rekap == null) return;
    setState(() => _isPrinting = true);
    try {
      await PdfService.cetakLaporanRekap(_rekap!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal cetak PDF: $e'), backgroundColor: dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Laporan Rekap', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadRekap),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : _rekap == null
              ? const Center(child: Text('Gagal memuat data'))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRingkasanCard(),
                      const SizedBox(height: 16),
                      _buildPerBansosCard(),
                      const SizedBox(height: 16),
                      _buildPerKecamatanCard(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isPrinting ? null : _cetakPDF,
        backgroundColor: bgDark,
        icon: _isPrinting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
        label: Text(
          _isPrinting ? 'Mencetak...' : 'Cetak PDF',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRingkasanCard() {
    final total      = _rekap!['total'] as int;
    final layak      = _rekap!['layak'] as int;
    final tidakLayak = _rekap!['tidakLayak'] as int;
    final persen     = total > 0 ? (layak / total * 100) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Warga', '$total', primaryBlue, Icons.people_outline)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('Layak', '$layak', successGreen, Icons.check_circle_outline)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard('Tidak Layak', '$tidakLayak', dangerRed, Icons.cancel_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('Tingkat Layak', '${persen.toStringAsFixed(0)}%', primaryBlue, Icons.insights_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPerBansosCard() {
    final perBansos = _rekap!['perBansos'] as Map<String, int>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_outlined, color: primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('Rekap per Jenis Bansos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          ...perBansos.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${e.value} orang',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPerKecamatanCard() {
    final perKecamatan = _rekap!['perKecamatan'] as Map<String, Map<String, int>>;

    if (perKecamatan.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(child: Text('Belum ada data', style: TextStyle(color: Colors.grey))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('Rekap per Kecamatan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          ...perKecamatan.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniStat('Total', e.value['total'] ?? 0, Colors.grey),
                    const SizedBox(width: 8),
                    _buildMiniStat('Layak', e.value['layak'] ?? 0, successGreen),
                    const SizedBox(width: 8),
                    _buildMiniStat('Tidak Layak', e.value['tidakLayak'] ?? 0, dangerRed),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Analisis'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
              (route) => false,
            );
            break;
          case 1:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RiwayatPage()));
            break;
          case 2:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InputDataWargaPage()));
            break;
          case 3:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
        }
      },
    );
  }
}