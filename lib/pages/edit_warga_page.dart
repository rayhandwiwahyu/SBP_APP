import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';

class EditWargaPage extends StatefulWidget {
  final Map<String, dynamic> dataWarga;

  const EditWargaPage({super.key, required this.dataWarga});

  @override
  State<EditWargaPage> createState() => _EditWargaPageState();
}

class _EditWargaPageState extends State<EditWargaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _kecamatanController;
  late TextEditingController _pendapatanController;
  late TextEditingController _tanggunganController;
  late TextEditingController _pekerjaanController;

  String? _kondisiRumah;
  late String _statusLahan;
  late bool _punyaTernak;
  late bool _punyaTabunganEmas;
  late bool _punyaKendaraanLebihSatu;
  late bool _isASNTNIPolri;
  late bool _adaDisabilitas;
  late bool _adaLansia;
  late bool _adaIbuHamil;
  late bool _adaBalita;
  late bool _adaAnakSekolah;

  bool _isLoading = false;

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
  void initState() {
    super.initState();
    final d = widget.dataWarga;

    _kecamatanController  = TextEditingController(text: d['kecamatan'] as String? ?? '');
    _pendapatanController = TextEditingController(
      text: _formatAngka((d['pendapatanBulanan'] as num? ?? 0).toInt().toString()),
    );
    _tanggunganController = TextEditingController(text: '${d['jumlahTanggungan'] ?? 0}');
    _pekerjaanController  = TextEditingController(text: d['pekerjaanUtama'] as String? ?? '');

    _kondisiRumah             = d['kondisiRumah'] as String? ?? 'Permanen';
    _statusLahan              = d['statusLahan'] as String? ?? 'Milik Sendiri';
    _punyaTernak              = d['punyaTernak'] as bool? ?? false;
    _punyaTabunganEmas        = d['punyaTabunganEmas'] as bool? ?? false;
    _punyaKendaraanLebihSatu  = d['punyaKendaraanLebihSatu'] as bool? ?? false;
    _isASNTNIPolri            = d['isASNTNIPolri'] as bool? ?? false;
    _adaDisabilitas           = d['adaDisabilitas'] as bool? ?? false;
    _adaLansia                = d['adaLansia'] as bool? ?? false;
    _adaIbuHamil              = d['adaIbuHamil'] as bool? ?? false;
    _adaBalita                = d['adaBalita'] as bool? ?? false;
    _adaAnakSekolah           = d['adaAnakSekolah'] as bool? ?? false;
  }

  @override
  void dispose() {
    _kecamatanController.dispose();
    _pendapatanController.dispose();
    _tanggunganController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
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

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseService.updateWarga(
        nik: widget.dataWarga['nik'] as String,
        dataBaru: {
          'kecamatan':               _kecamatanController.text.trim(),
          'pendapatanBulanan':       double.tryParse(_pendapatanController.text.replaceAll('.', '')) ?? 0,
          'jumlahTanggungan':        int.tryParse(_tanggunganController.text) ?? 0,
          'pekerjaanUtama':          _pekerjaanController.text.trim(),
          'kondisiRumah':            _kondisiRumah,
          'statusLahan':             _statusLahan,
          'isASNTNIPolri':           _isASNTNIPolri,
          'punyaTernak':             _punyaTernak,
          'punyaTabunganEmas':       _punyaTabunganEmas,
          'punyaKendaraanLebihSatu': _punyaKendaraanLebihSatu,
          'adaDisabilitas':          _adaDisabilitas,
          'adaLansia':               _adaLansia,
          'adaIbuHamil':             _adaIbuHamil,
          'adaBalita':               _adaBalita,
          'adaAnakSekolah':          _adaAnakSekolah,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: dangerRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nama = widget.dataWarga['namaLengkap'] as String? ?? '-';
    final nik  = widget.dataWarga['nik'] as String? ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Edit Data Warga',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Identitas (Read-only) ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Identitas (Tidak Dapat Diubah)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildReadOnlyField('Nama Lengkap', nama),
                    const SizedBox(height: 10),
                    _buildReadOnlyField('NIK', nik),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Sosial Ekonomi ──
              _buildSectionCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Kondisi Sosial Ekonomi',
                children: [
                  _buildTextField(
                    label: 'Kecamatan',
                    controller: _kecamatanController,
                    validator: (v) => v!.trim().isEmpty ? 'Tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildCurrencyField(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Jumlah Tanggungan',
                    controller: _tanggunganController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.trim().isEmpty ? 'Tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Pekerjaan Utama',
                    controller: _pekerjaanController,
                    validator: (v) => v!.trim().isEmpty ? 'Tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleRow(
                    label: 'ASN / TNI / Polri',
                    subtitle: 'Aktifkan jika berstatus ASN, TNI, atau Polri',
                    value: _isASNTNIPolri,
                    onChanged: (v) => setState(() => _isASNTNIPolri = v),
                    isWarning: true,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Rumah & Aset ──
              _buildSectionCard(
                icon: Icons.home_outlined,
                title: 'Kondisi Rumah & Aset',
                children: [
                  _buildDropdown(),
                  const SizedBox(height: 14),
                  const Text('Status Lahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildStatusLahanToggle(),
                  const SizedBox(height: 14),
                  const Text('Kepemilikan Aset', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  _buildCheckbox('Memiliki ternak (sapi/kambing/kerbau)', _punyaTernak,
                      (v) => setState(() => _punyaTernak = v ?? false)),
                  _buildCheckbox('Memiliki tabungan atau emas', _punyaTabunganEmas,
                      (v) => setState(() => _punyaTabunganEmas = v ?? false)),
                  _buildCheckbox('Memiliki kendaraan lebih dari 1 unit', _punyaKendaraanLebihSatu,
                      (v) => setState(() => _punyaKendaraanLebihSatu = v ?? false)),
                ],
              ),
              const SizedBox(height: 14),

              // ── Kondisi Khusus PKH ──
              _buildSectionCard(
                icon: Icons.family_restroom_outlined,
                title: 'Kondisi Khusus (PKH)',
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
                    subtitle: 'Ada anggota keluarga lansia',
                    value: _adaLansia,
                    onChanged: (v) => setState(() => _adaLansia = v),
                  ),
                  const Divider(height: 16),
                  _buildToggleRow(
                    label: 'Ibu Hamil',
                    subtitle: 'Ada ibu hamil dalam keluarga',
                    value: _adaIbuHamil,
                    onChanged: (v) => setState(() => _adaIbuHamil = v),
                  ),
                  const Divider(height: 16),
                  _buildToggleRow(
                    label: 'Anak Balita (0–6 tahun)',
                    subtitle: 'Ada anak usia 0–6 tahun',
                    value: _adaBalita,
                    onChanged: (v) => setState(() => _adaBalita = v),
                  ),
                  const Divider(height: 16),
                  _buildToggleRow(
                    label: 'Anak Usia Sekolah (SD–SMA)',
                    subtitle: 'Ada anak yang masih bersekolah',
                    value: _adaAnakSekolah,
                    onChanged: (v) => setState(() => _adaAnakSekolah = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _simpanPerubahan,
            icon: _isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 20),
            label: Text(
              _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: bgDark,
              foregroundColor: Colors.white,
              disabledBackgroundColor: bgDark.withOpacity(0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────

  Widget _buildReadOnlyField(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
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
          Row(children: [
            Icon(icon, color: primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ]),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
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
        const Text('Pendapatan Bulanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _pendapatanController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => v!.trim().isEmpty ? 'Tidak boleh kosong' : null,
          onChanged: (val) {
            if (val.isEmpty) return;
            final clean = val.replaceAll('.', '');
            final formatted = _formatAngka(clean);
            _pendapatanController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
          decoration: InputDecoration(
            prefixText: 'Rp  ',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kondisi Rumah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _kondisiRumah,
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

  Widget _buildCheckbox(String label, bool value, void Function(bool?) onChanged) {
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
        Switch(value: value, onChanged: onChanged, activeColor: isWarning ? dangerRed : primaryBlue),
      ],
    );
  }
}