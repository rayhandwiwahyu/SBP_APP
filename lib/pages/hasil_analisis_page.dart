import 'package:flutter/material.dart';
import '../models/warga_model.dart';
import '../services/cf_service.dart';
import '../services/database_service.dart';
import 'detail_keputusan_page.dart';
import 'dashboard_page.dart';
import 'riwayat_page.dart';
import 'profile_page.dart';

enum ModePencarian { nama, kecamatan }

class HasilAnalisisPage extends StatefulWidget {
  const HasilAnalisisPage({super.key});

  @override
  State<HasilAnalisisPage> createState() => _HasilAnalisisPageState();
}

class _HasilAnalisisPageState extends State<HasilAnalisisPage> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color bgDark      = Color(0xFF0D1B2A);

  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _semuaData    = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;
  ModePencarian _mode = ModePencarian.nama;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService.ambilSemuaWarga();
      setState(() {
        _semuaData    = data;
        _filteredData = data;
        _isLoading    = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _semuaData.where((item) {
        final field = _mode == ModePencarian.nama
            ? (item['namaLengkap'] as String? ?? '')
            : (item['kecamatan'] as String? ?? '');
        final matchQuery  = field.toLowerCase().contains(query.toLowerCase());
        final matchStatus = _filterStatus == 'Semua'
            ? true
            : _filterStatus == 'Layak'
                ? item['layak'] == true
                : item['layak'] == false;
        return matchQuery && matchStatus;
      }).toList();
    });
  }

  void _gantiMode(ModePencarian mode) {
    setState(() {
      _mode = mode;
      _searchController.clear();
    });
    _filterData('');
  }

  void _setFilterStatus(String status) {
    setState(() => _filterStatus = status);
    _filterData(_searchController.text);
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
        builder: (_) => DetailKeputusanPage(dataWarga: warga, hasil: hasil),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Hasil Analisis',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : _filteredData.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: primaryBlue,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Semua Hasil Analisis',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  '${_filteredData.length} Data',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._filteredData.map((item) => _buildAnalisisCard(item)),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('Belum ada hasil analisis', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Tab toggle mode pencarian
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Nama Warga', ModePencarian.nama)),
                Expanded(child: _buildTabButton('Kecamatan', ModePencarian.kecamatan)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: _filterData,
            decoration: InputDecoration(
              hintText: _mode == ModePencarian.nama
                  ? 'Cari nama warga...'
                  : 'Cari nama kecamatan...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryBlue),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', _filterStatus == 'Semua'),
                const SizedBox(width: 8),
                _buildFilterChip('Layak', _filterStatus == 'Layak'),
                const SizedBox(width: 8),
                _buildFilterChip('Tidak Layak', _filterStatus == 'Tidak Layak'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, ModePencarian mode) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => _gantiMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return GestureDetector(
      onTap: () => _setFilterStatus(label),
      child: Container(
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
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalisisCard(Map<String, dynamic> item) {
    final isLayak     = item['layak'] == true;
    final nama        = item['namaLengkap'] as String? ?? '-';
    final nik         = item['nik'] as String? ?? '-';
    final kecamatan   = item['kecamatan'] as String? ?? '-';
    final tanggal     = item['tanggalAnalisis'] as String? ?? '-';
    final rekomendasi = item['hasilRekomendasi'] as String? ?? '-';
    final cf          = (item['cfGabungan'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                    Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('NIK: $nik', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(kecamatan, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(width: 8),
                        Text(tanggal, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
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
                      color: isLayak ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLayak ? 'Layak' : 'Tidak Layak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLayak ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('CF: ${(cf * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                style: const TextStyle(fontSize: 11, color: primaryBlue, fontWeight: FontWeight.w500),
              ),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _bukaDetail(item),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Lihat Detail', style: TextStyle(fontSize: 11, color: primaryBlue, fontWeight: FontWeight.w600)),
                Icon(Icons.chevron_right, size: 16, color: primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analisis'),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatPage()),
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