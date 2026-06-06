import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/warga_model.dart';
import 'analisis_page.dart';

class InputDataWargaPage extends StatefulWidget {
  const InputDataWargaPage({super.key});

  @override
  State<InputDataWargaPage> createState() => _InputDataWargaPageState();
}

class _InputDataWargaPageState extends State<InputDataWargaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController       = TextEditingController();
  final _nikController        = TextEditingController();
  final _kecamatanController  = TextEditingController();
  final _pendapatanController = TextEditingController();
  final _tanggunganController = TextEditingController();
  final _pekerjaanController  = TextEditingController();

  // Kondisi Rumah & Aset
  String? _kondisiRumah;
  String  _statusLahan = 'Milik Sendiri';
  bool _punyaTernak             = false;
  bool _punyaTabunganEmas       = false;
  bool _punyaKendaraanLebihSatu = false;
  bool _isASNTNIPolri           = false;

  // Kondisi Khusus PKH
  bool _adaDisabilitas  = false;
  bool _adaLansia       = false;
  bool _adaIbuHamil     = false;
  bool _adaBalita       = false;
  bool _adaAnakSekolah  = false;

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color bgDark      = Color(0xFF0D1B2A);
  static const Color dangerRed   = Color(0xFFC62828);

  final List<String> _kondisiRumahList = [
    'Permanen',
    'Semi Permanen',
    'Tidak Permanen',
    'Gubuk / Sangat Tidak Layak',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _kecamatanController.dispose();
    _pendapatanController.dispose();
    _tanggunganController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  void _prosesAnalisis() {
    if (!_formKey.currentState!.validate()) return;
    if (_kondisiRumah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kondisi rumah terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final warga = WargaModel(
      namaLengkap: _namaController.text.trim(),
      nik: _nikController.text.trim(),
      kecamatan: _kecamatanController.text.trim(),
      pendapatanBulanan: double.tryParse(
  _pendapatanController.text
    .replaceAll('.', '')
    .replaceAll(' ', '')
    .trim(),
) ?? 0,
      jumlahTanggungan: int.tryParse(_tanggunganController.text) ?? 0,
      pekerjaanUtama: _pekerjaanController.text.trim(),
      isASNTNIPolri: _isASNTNIPolri,
      kondisiRumah: _kondisiRumah!,
      statusLahan: _statusLahan,
      punyaTernak: _punyaTernak,
      punyaTabunganEmas: _punyaTabunganEmas,
      punyaKendaraanLebihSatu: _punyaKendaraanLebihSatu,
      adaDisabilitas: _adaDisabilitas,
      adaLansia: _adaLansia,
      adaIbuHamil: _adaIbuHamil,
      adaBalita: _adaBalita,
      adaAnakSekolah: _adaAnakSekolah,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalisisPage(dataWarga: warga)),
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
          'Input Data Warga',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Identitas Dasar ──
                    _buildSectionCard(
                      icon: Icons.person_outline,
                      title: 'Identitas Dasar',
                      children: [
                        _buildTextField(
                          label: 'Nama Lengkap',
                          hint: 'Sesuai KTP',
                          controller: _namaController,
                          validator: (v) => v!.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'NIK',
                          hint: '16 digit nomor NIK',
                          controller: _nikController,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) => v!.length != 16 ? 'NIK harus 16 digit' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Kecamatan',
                          hint: 'Nama kecamatan',
                          controller: _kecamatanController,
                          validator: (v) => v!.trim().isEmpty ? 'Kecamatan tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Pekerjaan Utama',
                          hint: 'Contoh: Buruh Harian Lepas, Petani, dll',
                          controller: _pekerjaanController,
                          validator: (v) => v!.trim().isEmpty ? 'Pekerjaan tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 12),
                        // ASN/TNI/Polri toggle
                        _buildToggleRow(
                          label: 'ASN / TNI / Polri',
                          subtitle: 'Aktifkan jika kepala keluarga berstatus ASN, TNI, atau Polri',
                          value: _isASNTNIPolri,
                          onChanged: (v) => setState(() => _isASNTNIPolri = v),
                          isWarning: true,
                        ),
                        if (_isASNTNIPolri)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ASN/TNI/Polri tidak memenuhi syarat penerima bansos berdasarkan regulasi Kemensos.',
                                    style: TextStyle(fontSize: 11, color: Color(0xFFC62828)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Sosial Ekonomi ──
                    _buildSectionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Kondisi Sosial Ekonomi',
                      children: [
                        _buildCurrencyField(),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Jumlah Tanggungan Keluarga',
                          hint: 'Jumlah orang yang ditanggung',
                          controller: _tanggunganController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) => v!.trim().isEmpty ? 'Jumlah tanggungan tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '* Termasuk kepala keluarga, pasangan, anak, orang tua yang tinggal serumah',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Kondisi Rumah & Aset ──
                    _buildSectionCard(
                      icon: Icons.home_outlined,
                      title: 'Kondisi Rumah & Aset',
                      children: [
                        _buildDropdown(),
                        const SizedBox(height: 14),
                        const Text(
                          'Status Kepemilikan Lahan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusLahanToggle(),
                        const SizedBox(height: 14),
                        const Text(
                          'Kepemilikan Aset (pilih yang sesuai)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        _buildCheckbox(
                          label: 'Memiliki ternak (sapi, kambing, atau kerbau)',
                          value: _punyaTernak,
                          onChanged: (v) => setState(() => _punyaTernak = v ?? false),
                        ),
                        _buildCheckbox(
                          label: 'Memiliki tabungan atau emas',
                          value: _punyaTabunganEmas,
                          onChanged: (v) => setState(() => _punyaTabunganEmas = v ?? false),
                        ),
                        _buildCheckbox(
                          label: 'Memiliki kendaraan lebih dari 1 unit',
                          value: _punyaKendaraanLebihSatu,
                          onChanged: (v) => setState(() => _punyaKendaraanLebihSatu = v ?? false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Kondisi Khusus PKH ──
                    _buildSectionCard(
                      icon: Icons.family_restroom_outlined,
                      title: 'Kondisi Khusus (PKH)',
                      subtitle: 'Aktifkan jika ada anggota keluarga:',
                      children: [
                        _buildToggleRow(
                          label: 'Penyandang Disabilitas',
                          subtitle: 'Ada anggota keluarga penyandang disabilitas',
                          value: _adaDisabilitas,
                          onChanged: (v) => setState(() => _adaDisabilitas = v),
                        ),
                        const Divider(height: 16),
                        _buildToggleRow(
                          label: 'Lanjut Usia (≥ 60 tahun)',
                          subtitle: 'Ada anggota keluarga berusia 60 tahun atau lebih',
                          value: _adaLansia,
                          onChanged: (v) => setState(() => _adaLansia = v),
                        ),
                        const Divider(height: 16),
                        _buildToggleRow(
                          label: 'Ibu Hamil',
                          subtitle: 'Ada ibu hamil dalam keluarga (maks. 2 kehamilan)',
                          value: _adaIbuHamil,
                          onChanged: (v) => setState(() => _adaIbuHamil = v),
                        ),
                        const Divider(height: 16),
                        _buildToggleRow(
                          label: 'Anak Balita (0–6 tahun)',
                          subtitle: 'Ada anak usia 0 hingga 6 tahun',
                          value: _adaBalita,
                          onChanged: (v) => setState(() => _adaBalita = v),
                        ),
                        const Divider(height: 16),
                        _buildToggleRow(
                          label: 'Anak Usia Sekolah (SD–SMA)',
                          subtitle: 'Ada anak yang masih bersekolah SD hingga SMA',
                          value: _adaAnakSekolah,
                          onChanged: (v) => setState(() => _adaAnakSekolah = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInfoBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Container(
      color: bgDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(3, (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              height: 4,
              decoration: BoxDecoration(
                color: i == 0 ? Colors.white : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ))),
          const SizedBox(height: 6),
          const Text('Langkah 1 dari 3', style: TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCurrencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pendapatan Bulanan (rata-rata)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _pendapatanController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => v!.trim().isEmpty ? 'Pendapatan tidak boleh kosong' : null,
          onChanged: (val) {
            // Format angka dengan titik pemisah
            if (val.isEmpty) return;
            final clean = val.replaceAll('.', '');
            final formatted = _formatAngka(clean);
            _pendapatanController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
            prefixText: 'Rp  ',
            prefixStyle: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            suffixText: '/bulan',
            suffixStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 6),
        const Text(
          '* Rata-ratakan pendapatan beberapa bulan terakhir untuk pendapatan tidak tetap',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatAngka(String angka) {
    if (angka.isEmpty) return '';
    final buffer = StringBuffer();
    int counter = 0;
    for (int i = angka.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) buffer.write('.');
      buffer.write(angka[i]);
      counter++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kondisi Rumah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _kondisiRumah,
          hint: const Text('Pilih kondisi rumah', style: TextStyle(fontSize: 13, color: Colors.black38)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          items: _kondisiRumahList.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (val) => setState(() => _kondisiRumah = val),
        ),
      ],
    );
  }

  Widget _buildStatusLahanToggle() {
    final options = ['Milik Sendiri', 'Numpang / Tidak Ada'];
    return Row(
      children: options.map((opt) {
        final selected = _statusLahan == opt;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _statusLahan = opt),
            child: Container(
              margin: EdgeInsets.only(right: opt == options.first ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? primaryBlue : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                opt,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black54),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      activeColor: primaryBlue,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isWarning && value ? dangerRed : Colors.black87)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isWarning ? dangerRed : primaryBlue,
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.15)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primaryBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pastikan data yang diinput sesuai dengan dokumen asli (KTP, KK). Hasil verifikasi lapangan tetap menjadi pertimbangan utama. Data diperbarui minimal setiap 6 bulan.',
              style: TextStyle(fontSize: 12, color: Color(0xFF1A237E), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _prosesAnalisis,
          icon: const Icon(Icons.search, size: 20),
          label: const Text('Simpan dan Proses Analisis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}