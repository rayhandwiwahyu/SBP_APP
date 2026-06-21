import 'package:flutter/material.dart';
import '../models/warga_model.dart';
import '../services/cf_service.dart';
import '../services/database_service.dart';
import 'detail_keputusan_page.dart';
import 'dashboard_page.dart';
import 'input_data_warga_page.dart';
import 'profile_page.dart';
import 'hasil_analisis_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color bgDark      = Color(0xFF0D1B2A);

  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService.ambilSemuaWarga();
      final tigaTerbaru = data.take(3).toList();
      setState(() {
        _data      = tigaTerbaru;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Riwayat Analisis',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : _data.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: primaryBlue,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            ..._data.map((item) => _buildRiwayatCard(item)),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'Belum ada data analisis',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Data akan muncul setelah analisis pertama',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '3 Analisis Terbaru',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HasilAnalisisPage()),
              );
            },
            icon: const Icon(Icons.list_alt, size: 16, color: primaryBlue),
            label: const Text(
              'Lihat Semua',
              style: TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    final isLayak     = item['layak'] == true;
    final nama        = item['namaLengkap'] as String? ?? '-';
    final nik         = item['nik'] as String? ?? '-';
    final tanggal     = item['tanggalAnalisis'] as String? ?? '-';
    final rekomendasi = item['hasilRekomendasi'] as String? ?? '-';
    final cf          = (item['cfGabungan'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIK: $nik',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      tanggal,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLayak
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLayak ? 'Layak' : 'Tidak Layak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLayak
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CF: ${(cf * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          if (isLayak) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                rekomendasi,
                style: const TextStyle(
                  fontSize: 11,
                  color: primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _bukaDetail(item),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontSize: 11,
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _bukaDetail(Map<String, dynamic> item) {
    final warga = WargaModel(
      namaLengkap:             item['namaLengkap'] as String? ?? '-',
      nik:                     item['nik'] as String? ?? '-',
      kecamatan:               item['kecamatan'] as String? ?? '-',
      pendapatanBulanan:       (item['pendapatanBulanan'] as num?)?.toDouble() ?? 0,
      jumlahTanggungan:        (item['jumlahTanggungan'] as num?)?.toInt() ?? 0,
      pekerjaanUtama:          item['pekerjaanUtama'] as String? ?? '-',
      isASNTNIPolri:           item['isASNTNIPolri'] as bool? ?? false,
      kondisiRumah:            item['kondisiRumah'] as String? ?? 'Permanen',
      statusLahan:             item['statusLahan'] as String? ?? 'Milik Sendiri',
      punyaTernak:             item['punyaTernak'] as bool? ?? false,
      punyaTabunganEmas:       item['punyaTabunganEmas'] as bool? ?? false,
      punyaKendaraanLebihSatu: item['punyaKendaraanLebihSatu'] as bool? ?? false,
      adaDisabilitas:          item['adaDisabilitas'] as bool? ?? false,
      adaLansia:               item['adaLansia'] as bool? ?? false,
      adaIbuHamil:             item['adaIbuHamil'] as bool? ?? false,
      adaBalita:               item['adaBalita'] as bool? ?? false,
      adaAnakSekolah:          item['adaAnakSekolah'] as bool? ?? false,
    );

    final hasil = CFService.analisis(warga);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailKeputusanPage(
          dataWarga: warga,
          hasil: hasil,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analisis'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const InputDataWargaPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
}