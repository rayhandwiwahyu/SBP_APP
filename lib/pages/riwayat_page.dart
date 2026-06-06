import 'package:flutter/material.dart';
import '../models/warga_model.dart';
import '../services/cf_service.dart';
import 'detail_keputusan_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color bgDark = Color(0xFF0D1B2A);

  String _filterWilayah = 'Semua Warga';
  String _filterStatus = 'Status';
  String _filterNIK = 'NIK Valid';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _riwayatList = [
    {
      'nama': 'Ahmad Subarjo',
      'nik': 'NIK: 3207161802980001',
      'tanggal': '26 Okt 2023',
      'status': 'Layak',
      'total': '378 Data',
    },
    {
      'nama': 'Siti Aminah',
      'nik': 'NIK: 3270604050850003',
      'tanggal': '24 Okt 2023',
      'status': 'Tidak Layak',
      'total': null,
    },
    {
      'nama': 'Budi Hartono',
      'nik': 'NIK: 3207080909880002',
      'tanggal': '20 Okt 2023',
      'status': 'Layak',
      'total': null,
    },
    {
      'nama': 'Ratna Sari',
      'nik': 'NIK: 3270604050860001',
      'tanggal': '18 Okt 2023',
      'status': 'Layak',
      'total': null,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: const Text('Riwayat Analisis', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hasil Analisis Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${_riwayatList.length} Data', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                ..._riwayatList.map((item) => _buildRiwayatCard(item)),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: primaryBlue.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari Nama Warga atau NIK...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue)),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(_filterWilayah, primaryBlue, true),
                const SizedBox(width: 8),
                _buildFilterChip(_filterStatus, Colors.grey.shade600, false),
                const SizedBox(width: 8),
                _buildFilterChip(_filterNIK, Colors.grey.shade600, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? primaryBlue : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    final isLayak = item['status'] == 'Layak';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item['nama'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    if (item['total'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item['total'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item['nik'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(item['tanggal'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLayak ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isLayak ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                // ✅ BARU
onTap: () {
  final dummyWarga = WargaModel(
    namaLengkap: item['nama'] as String,
    nik: (item['nik'] as String).replaceAll('NIK: ', ''),
    kecamatan: '-',
    pendapatanBulanan: 0,
    jumlahTanggungan: 0,
    pekerjaanUtama: '-',
    isASNTNIPolri: false,
    kondisiRumah: 'Tidak Permanen',
    statusLahan: 'Numpang / Tidak Ada',
    punyaTernak: false,
    punyaTabunganEmas: false,
    punyaKendaraanLebihSatu: false,
    adaDisabilitas: false,
    adaLansia: false,
    adaIbuHamil: false,
    adaBalita: false,
    adaAnakSekolah: false,
  );
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => DetailKeputusanPage(
      dataWarga: dummyWarga,
      hasil: CFService.analisis(dummyWarga),
    )),
  );
},
                child: const Text(
                  'Lihat Detail ›',
                  style: TextStyle(fontSize: 11, color: primaryBlue, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Analisis'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onTap: (_) {},
      ),
    );
  }
}