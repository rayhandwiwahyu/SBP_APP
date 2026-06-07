import 'package:flutter/material.dart';
import '../models/warga_model.dart';
import '../services/cf_service.dart';
import 'dashboard_page.dart';

class DetailKeputusanPage extends StatelessWidget {
  final WargaModel dataWarga;
  final HasilAnalisis hasil;

  const DetailKeputusanPage({
    super.key,
    required this.dataWarga,
    required this.hasil,
  });

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color bgDark = Color(0xFF0D1B2A);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color dangerRed = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Detail Keputusan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVerdictCard(),
            const SizedBox(height: 14),
            _buildDataPenerima(),
            const SizedBox(height: 14),
            _buildDetailFaktorCard(),
            const SizedBox(height: 14),
            _buildRekomendasiCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  Widget _buildVerdictCard() {
  final persen = (hasil.cfGabungan * 100).toStringAsFixed(0);
  final cf     = hasil.cfGabungan.toStringAsFixed(2);

  // Warna berdasarkan jenis bansos
  final Map<JenisBansos, Color> warnaBansos = {
    JenisBansos.pkh:           const Color(0xFF1565C0),
    JenisBansos.bpnt:          const Color(0xFF2E7D32),
    JenisBansos.pip:           const Color(0xFF6A1B9A),
    JenisBansos.blt:           const Color(0xFFE65100),
    JenisBansos.bantuanDaerah: const Color(0xFF00695C),
    JenisBansos.tidakLayak:    const Color(0xFFC62828),
  };

  final Color warnaTerpilih = warnaBansos[hasil.rekomendasiUtama] ?? dangerRed;

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: warnaTerpilih,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            hasil.layak ? hasil.namaRekomendasi.toUpperCase() : 'TIDAK LAYAK MENERIMA BANSOS',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$persen%',
          style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const Text('KEYAKINAN SISTEM', style: TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text('Certainty Factor: $cf', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'NILAI CF PER JENIS BANSOS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
          ),
        ),
        const SizedBox(height: 10),
        _buildProbabilityBar('PKH', hasil.cfPKH, const Color(0xFF1565C0), hasil.rekomendasiUtama == JenisBansos.pkh),
        const SizedBox(height: 8),
        _buildProbabilityBar('BPNT / Sembako', hasil.cfBPNT, const Color(0xFF2E7D32), hasil.rekomendasiUtama == JenisBansos.bpnt),
        const SizedBox(height: 8),
        _buildProbabilityBar('PIP', hasil.cfPIP, const Color(0xFF6A1B9A), hasil.rekomendasiUtama == JenisBansos.pip),
        const SizedBox(height: 8),
        _buildProbabilityBar('BLT', hasil.cfBLT, const Color(0xFFE65100), hasil.rekomendasiUtama == JenisBansos.blt),
        const SizedBox(height: 8),
        _buildProbabilityBar('Bantuan Daerah', hasil.cfBantuanDaerah, const Color(0xFF00695C), hasil.rekomendasiUtama == JenisBansos.bantuanDaerah),
      ],
    ),
  );
}

  Widget _buildProbabilityBar(String label, double value, Color color, bool isSelected) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('✓', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          minHeight: isSelected ? 8 : 6,
          backgroundColor: const Color(0xFFE0E0E0),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ],
  );
}

  Widget _buildDataPenerima() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Data Penerima',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildDataRow('Nama Lengkap', dataWarga.namaLengkap),
          _buildDataRow('NIK', dataWarga.nik),
          _buildDataRow('Kecamatan', dataWarga.kecamatan),
          _buildDataRow('Pekerjaan', dataWarga.pekerjaanUtama),
          _buildDataRow('Pendapatan',
              'Rp ${dataWarga.pendapatanBulanan.toInt()}/bulan'),
          _buildDataRow('Tanggungan', '${dataWarga.jumlahTanggungan} orang'),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailFaktorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Analisa Sistem Pakar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          ...hasil.detailFaktor.map((f) => _buildFaktorRow(f)),
          if (hasil.alasanLayak.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Faktor Penentu:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            ...hasil.alasanLayak.map(
              (alasan) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alasan,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFaktorRow(DetailFaktor faktor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            faktor.terpenuhi ? Icons.check_circle : Icons.cancel,
            color: faktor.terpenuhi ? successGreen : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faktor.faktor,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  faktor.kondisi,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (faktor.cfNilai > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CF: ${faktor.cfNilai}',
                style: const TextStyle(
                  fontSize: 10,
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRekomendasiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
  colors: {
    JenisBansos.pkh:           [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
    JenisBansos.bpnt:          [const Color(0xFF2E7D32), const Color(0xFF43A047)],
    JenisBansos.pip:           [const Color(0xFF6A1B9A), const Color(0xFF9C27B0)],
    JenisBansos.blt:           [const Color(0xFFE65100), const Color(0xFFFF7043)],
    JenisBansos.bantuanDaerah: [const Color(0xFF004D40), const Color(0xFF00695C)],
    JenisBansos.tidakLayak:    [const Color(0xFF8B0000), const Color(0xFFC62828)],
  }[hasil.rekomendasiUtama] ?? [const Color(0xFF8B0000), const Color(0xFFC62828)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.recommend_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Rekomendasi Jenis Bantuan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              hasil.namaRekomendasi,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasil.layak
                ? 'Berdasarkan hasil analisis sistem pakar dengan metode Certainty Factor, warga ini direkomendasikan menerima ${hasil.namaRekomendasi} dengan tingkat keyakinan ${(hasil.cfGabungan * 100).toStringAsFixed(0)}%.'
                : 'Berdasarkan hasil analisis, warga ini belum memenuhi kriteria kelayakan penerima bantuan sosial. Tingkat keyakinan sistem: ${(hasil.cfGabungan * 100).toStringAsFixed(0)}%.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text(
                'Cetak PDF',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.dashboard_outlined, size: 18),
              label: const Text(
                'Ke Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: bgDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}