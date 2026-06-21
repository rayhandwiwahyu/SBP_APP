import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController      = TextEditingController();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _instansiController  = TextEditingController();

  bool _isHiddenPassword      = true;
  bool _isHiddenKonfirmasi    = true;
  bool _isLoading             = false;
  String? _jabatanTerpilih;

  static const Color primaryGreen = Color(0xFF1B8A5A);
 

  final List<String> _jabatanList = [
    'Petugas Kelurahan',
    'Kepala Kelurahan',
    'Sekretaris Kelurahan',
    'Staff Sosial',
    'Petugas Lapangan',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _instansiController.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jabatanTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jabatan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Buat akun di Firebase Auth
    final error = await AuthService.register(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (error != null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // Simpan profil ke Realtime Database
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await DatabaseService.simpanProfilUser(
        uid: uid,
        namaLengkap: _namaController.text.trim(),
        email: _emailController.text.trim(),
        jabatan: _jabatanTerpilih!,
        instansi: _instansiController.text.trim(),
      );
    } catch (e) {
      // Profil gagal disimpan tapi akun sudah terbuat — lanjut saja
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Judul ──
              const Text(
                'Mulai Verifikasi Bansos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Silakan lengkapi data diri Anda untuk\nmembuat akun petugas.',
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 28),

              // ── Nama Lengkap ──
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _namaController,
                hint: 'Masukkan nama sesuai KTP',
                icon: Icons.person_outline,
                validator: (v) => v!.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // ── Email ──
              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'contoh@instansi.go.id',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Email tidak boleh kosong';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Password ──
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _passwordController,
                hint: 'Minimal 6 karakter',
                isHidden: _isHiddenPassword,
                onToggle: () => setState(() => _isHiddenPassword = !_isHiddenPassword),
                validator: (v) {
                  if (v!.isEmpty) return 'Password tidak boleh kosong';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Konfirmasi Password ──
              _buildLabel('Konfirmasi Password'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _konfirmasiController,
                hint: 'Ulangi password',
                isHidden: _isHiddenKonfirmasi,
                onToggle: () => setState(() => _isHiddenKonfirmasi = !_isHiddenKonfirmasi),
                validator: (v) {
                  if (v!.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                  if (v != _passwordController.text) return 'Password tidak sama';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Jabatan ──
              _buildLabel('Jabatan'),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: 16),

              // ── Nama Kelurahan/Instansi ──
              _buildLabel('Nama Kelurahan/Instansi'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _instansiController,
                hint: 'Contoh: Kelurahan Menteng...',
                icon: Icons.business_outlined,
                validator: (v) => v!.trim().isEmpty ? 'Instansi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),

              // ── Tombol Daftar ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _daftar,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Mendaftarkan...' : 'Daftar Sekarang',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Link ke Login ──
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                      children: [
                        TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Login di sini',
                          style: TextStyle(
                            color: Color(0xFF1B8A5A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ── Footer Badge ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(Icons.description_outlined, 'Data Terenkripsi'),
                  const SizedBox(width: 16),
                  _buildBadge(Icons.verified_outlined, 'Verified Resmi'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isLoading,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isHidden,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isHidden,
      enabled: !_isLoading,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _jabatanTerpilih,
      hint: const Text(
        'Pilih Jabatan Anda',
        style: TextStyle(fontSize: 13, color: Colors.black38),
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.work_outline, color: Colors.grey, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      items: _jabatanList
          .map((j) => DropdownMenuItem(
                value: j,
                child: Text(j, style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: _isLoading ? null : (val) => setState(() => _jabatanTerpilih = val),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: primaryGreen, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}