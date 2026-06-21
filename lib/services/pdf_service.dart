import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/warga_model.dart';
import '../services/cf_service.dart';

class PdfService {
  static Future<void> cetakHasilAnalisis({
    required WargaModel warga,
    required HasilAnalisis hasil,
  }) async {
    final pdf = pw.Document();

    // Warna
    final primaryBlue  = PdfColor.fromHex('#1565C0');
    final darkBg       = PdfColor.fromHex('#0D1B2A');
    final successGreen = PdfColor.fromHex('#2E7D32');
    final dangerRed    = PdfColor.fromHex('#C62828');
    final lightGrey    = PdfColor.fromHex('#F5F6FA');
    final medGrey      = PdfColor.fromHex('#ECEFF1');

    // Warna per jenis bansos
    PdfColor warnaRekomendasi;
    switch (hasil.rekomendasiUtama) {
      case JenisBansos.pkh:
        warnaRekomendasi = primaryBlue;
        break;
      case JenisBansos.bpnt:
        warnaRekomendasi = PdfColor.fromHex('#2E7D32');
        break;
      case JenisBansos.pip:
        warnaRekomendasi = PdfColor.fromHex('#6A1B9A');
        break;
      case JenisBansos.blt:
        warnaRekomendasi = PdfColor.fromHex('#E65100');
        break;
      case JenisBansos.bantuanDaerah:
        warnaRekomendasi = PdfColor.fromHex('#004D40');
        break;
      default:
        warnaRekomendasi = dangerRed;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [

          // ── HEADER ──────────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: darkBg,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SISTEM PAKAR KELAYAKAN BANSOS',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Laporan Hasil Analisis Certainty Factor',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Tanggal: ${_formatTanggal(DateTime.now())}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── HASIL KEPUTUSAN ──────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: warnaRekomendasi,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  hasil.layak
                      ? hasil.namaRekomendasi.toUpperCase()
                      : 'TIDAK LAYAK MENERIMA BANSOS',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${(hasil.cfGabungan * 100).toStringAsFixed(0)}%',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 36,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'KEYAKINAN SISTEM (CF: ${hasil.cfGabungan.toStringAsFixed(2)})',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── DATA PENERIMA ────────────────────────────────────────
          _buildSection(
            title: 'DATA PENERIMA',
            titleColor: primaryBlue,
            content: pw.Column(
              children: [
                _buildDataRow('Nama Lengkap', warga.namaLengkap),
                _buildDataRow('NIK', warga.nik),
                _buildDataRow('Kecamatan', warga.kecamatan),
                _buildDataRow('Pekerjaan', warga.pekerjaanUtama),
                _buildDataRow('Pendapatan', 'Rp ${_rp(warga.pendapatanBulanan)}/bulan'),
                _buildDataRow('Tanggungan', '${warga.jumlahTanggungan} orang'),
                _buildDataRow('Kondisi Rumah', warga.kondisiRumah),
                _buildDataRow('Status Lahan', warga.statusLahan),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // ── NILAI CF PER JENIS BANSOS ────────────────────────────
          _buildSection(
            title: 'NILAI CF PER JENIS BANSOS',
            titleColor: primaryBlue,
            content: pw.Column(
              children: [
                _buildCFBar('PKH', hasil.cfPKH, PdfColor.fromHex('#1565C0'),
                    hasil.rekomendasiUtama == JenisBansos.pkh),
                pw.SizedBox(height: 6),
                _buildCFBar('BPNT / Sembako', hasil.cfBPNT, PdfColor.fromHex('#2E7D32'),
                    hasil.rekomendasiUtama == JenisBansos.bpnt),
                pw.SizedBox(height: 6),
                _buildCFBar('PIP', hasil.cfPIP, PdfColor.fromHex('#6A1B9A'),
                    hasil.rekomendasiUtama == JenisBansos.pip),
                pw.SizedBox(height: 6),
                _buildCFBar('BLT', hasil.cfBLT, PdfColor.fromHex('#E65100'),
                    hasil.rekomendasiUtama == JenisBansos.blt),
                pw.SizedBox(height: 6),
                _buildCFBar('Bantuan Daerah', hasil.cfBantuanDaerah,
                    PdfColor.fromHex('#004D40'),
                    hasil.rekomendasiUtama == JenisBansos.bantuanDaerah),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // ── DETAIL FAKTOR ────────────────────────────────────────
          _buildSection(
            title: 'ANALISA SISTEM PAKAR',
            titleColor: primaryBlue,
            content: pw.Column(
              children: hasil.detailFaktor.map((f) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 14,
                      height: 14,
                      decoration: pw.BoxDecoration(
                        color: f.terpenuhi ? successGreen : medGrey,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          f.terpenuhi ? '✓' : '✗',
                          style: pw.TextStyle(
                            color: f.terpenuhi ? PdfColors.white : PdfColors.grey,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            f.faktor,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            f.kondisi,
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (f.cfNilai != 0)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3,
                        ),
                        decoration: pw.BoxDecoration(
                          color: f.cfNilai > 0
                              ? PdfColor.fromHex('#E3F2FD')
                              : PdfColor.fromHex('#FFEBEE'),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'CF: ${f.cfNilai.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: f.cfNilai > 0 ? primaryBlue : dangerRed,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              )).toList(),
            ),
          ),
          pw.SizedBox(height: 12),

          // ── REKOMENDASI ──────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: lightGrey,
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: warnaRekomendasi, width: 1.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REKOMENDASI BANTUAN SOSIAL',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: warnaRekomendasi,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  hasil.namaRekomendasi,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: warnaRekomendasi,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  hasil.layak
                      ? 'Berdasarkan hasil analisis sistem pakar dengan metode Certainty Factor, warga ini direkomendasikan menerima ${hasil.namaRekomendasi} dengan tingkat keyakinan ${(hasil.cfGabungan * 100).toStringAsFixed(0)}%.'
                      : 'Berdasarkan hasil analisis, warga ini belum memenuhi kriteria kelayakan penerima bantuan sosial dengan tingkat keyakinan ${(hasil.cfGabungan * 100).toStringAsFixed(0)}%.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (hasil.alasanLayak.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Faktor Penentu:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  ...hasil.alasanLayak.map((a) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                        pw.Expanded(
                          child: pw.Text(a, style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── FOOTER ───────────────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Kementerian Sosial Republik Indonesia',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
              pw.Text(
                'Dicetak: ${_formatTanggal(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ],
          ),
          pw.Text(
            'Dokumen ini digenerate otomatis oleh Sistem Pakar Kelayakan Bansos v2.4',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );

    // Print / Share PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Hasil_Analisis_${warga.nik}_${_formatTanggalFile(DateTime.now())}.pdf',
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────

  static pw.Widget _buildSection({
    required String title,
    required PdfColor titleColor,
    required pw.Widget content,
  }) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: titleColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: content,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCFBar(
    String label,
    double value,
    PdfColor color,
    bool isSelected,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                if (isSelected)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(right: 4),
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      '✓',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
              ],
            ),
            pw.Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Stack(
          children: [
            pw.Container(
              height: isSelected ? 8 : 6,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
            pw.Container(
              height: isSelected ? 8 : 6,
              width: value * 500,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatTanggal(DateTime dt) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  static String _formatTanggalFile(DateTime dt) {
    return '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
  }

  static String _rp(double angka) {
    final str = angka.toInt().toString();
    final buffer = StringBuffer();
    int counter = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      counter++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  static Future<void> cetakLaporanRekap(Map<String, dynamic> rekap) async {
  final pdf = pw.Document();

  final primaryBlue = PdfColor.fromHex('#1565C0');
  final darkBg       = PdfColor.fromHex('#0D1B2A');
  final successGreen = PdfColor.fromHex('#2E7D32');
  final dangerRed    = PdfColor.fromHex('#C62828');
  final lightGrey    = PdfColor.fromHex('#F5F6FA');

  final total      = rekap['total'] as int;
  final layak      = rekap['layak'] as int;
  final tidakLayak = rekap['tidakLayak'] as int;
  final perBansos  = rekap['perBansos'] as Map<String, int>;
  final perKecamatan = rekap['perKecamatan'] as Map<String, Map<String, int>>;

  final persenLayak = total > 0 ? (layak / total * 100) : 0.0;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [

        // ── HEADER ──────────────────────────────────────────────
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: darkBg,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LAPORAN REKAPITULASI BANSOS',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold, letterSpacing: 1),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Sistem Pakar Kelayakan Penerima Bantuan Sosial',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Tanggal Cetak: ${_formatTanggal(DateTime.now())}',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // ── RINGKASAN UMUM ───────────────────────────────────────
        pw.Row(
          children: [
            pw.Expanded(child: _buildStatBox('Total Warga', '$total', primaryBlue)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildStatBox('Layak', '$layak', successGreen)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildStatBox('Tidak Layak', '$tidakLayak', dangerRed)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: lightGrey,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            'Tingkat Kelayakan: ${persenLayak.toStringAsFixed(1)}% dari total warga yang dianalisis',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryBlue),
          ),
        ),
        pw.SizedBox(height: 16),

        // ── BREAKDOWN PER JENIS BANSOS ───────────────────────────
        _buildSection(
          title: 'REKAP PER JENIS BANTUAN SOSIAL',
          titleColor: primaryBlue,
          content: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: primaryBlue),
                children: [
                  _buildTableCell('Jenis Bantuan', isHeader: true),
                  _buildTableCell('Jumlah Penerima', isHeader: true),
                ],
              ),
              ...perBansos.entries.map((e) => pw.TableRow(
                children: [
                  _buildTableCell(e.key),
                  _buildTableCell('${e.value}', align: pw.TextAlign.center),
                ],
              )),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // ── BREAKDOWN PER KECAMATAN ──────────────────────────────
        _buildSection(
          title: 'REKAP PER KECAMATAN',
          titleColor: primaryBlue,
          content: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: primaryBlue),
                children: [
                  _buildTableCell('Kecamatan', isHeader: true),
                  _buildTableCell('Total', isHeader: true),
                  _buildTableCell('Layak', isHeader: true),
                  _buildTableCell('Tidak Layak', isHeader: true),
                ],
              ),
              ...perKecamatan.entries.map((e) => pw.TableRow(
                children: [
                  _buildTableCell(e.key),
                  _buildTableCell('${e.value['total']}', align: pw.TextAlign.center),
                  _buildTableCell('${e.value['layak']}', align: pw.TextAlign.center),
                  _buildTableCell('${e.value['tidakLayak']}', align: pw.TextAlign.center),
                ],
              )),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // ── FOOTER ───────────────────────────────────────────────
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Kementerian Sosial Republik Indonesia', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            pw.Text('Dicetak: ${_formatTanggal(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          ],
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
    name: 'Laporan_Rekap_Bansos_${_formatTanggalFile(DateTime.now())}.pdf',
  );
}

static pw.Widget _buildStatBox(String label, String value, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: color,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: isHeader ? 10 : 9,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: isHeader ? PdfColors.white : PdfColors.black,
      ),
    ),
  );
}
}