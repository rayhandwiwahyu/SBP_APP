import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'dashboard_page.dart';
import 'riwayat_page.dart';
import 'input_data_warga_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color bgDark = Color(0xFF0D1B2A);

  String _namaLengkap = '...';
  String _jabatan      = '...';
  String _instansi     = '...';
  String _email        = '...';
  bool _isLoading      = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid  = user?.uid ?? '';
      final profil = await DatabaseService.ambilProfilUser(uid);

      if (mounted) {
        setState(() {
          _namaLengkap = profil?['namaLengkap'] as String? ?? 'Tanpa Nama';
          _jabatan      = profil?['jabatan'] as String? ?? '-';
          _instansi     = profil?['instansi'] as String? ?? '-';
          _email        = user?.email ?? '-';
          _isLoading    = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Sistem Pakar Bansos', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildMenuList(context),
                  const SizedBox(height: 20),
                  _buildLogoutButton(context),
                  const SizedBox(height: 20),
                  _buildFooterText(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFE3F2FD),
                child: const Icon(Icons.person, size: 50, color: primaryBlue),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _namaLengkap,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            _jabatan,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            _instansi,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            _email,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.4)),
            ),
            child: const Text(
              'AKUN TERVERIFIKASI',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.edit_outlined, 'label': 'Edit Profile', 'color': primaryBlue},
      {'icon': Icons.lock_outline, 'label': 'Pengaturan Keamanan', 'color': primaryBlue},
      {'icon': Icons.info_outline, 'label': 'Tentang Aplikasi', 'color': primaryBlue},
      {'icon': Icons.help_outline, 'label': 'Pusat Bantuan', 'color': primaryBlue},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(14) : Radius.zero,
                  bottom: i == menuItems.length - 1 ? const Radius.circular(14) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(item['label'] as String, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              if (i < menuItems.length - 1)
                const Divider(height: 1, indent: 50),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout, color: Color(0xFFC62828), size: 18),
          label: const Text('Logout', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 14)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFC62828)),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Column(
      children: const [
        Text('Kementerian Sosial Republik Indonesia', style: TextStyle(color: Colors.grey, fontSize: 11)),
        SizedBox(height: 2),
        Text('v2.0.0 • Bansos Pintar Mobile', style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analisis'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          if (index == 3) return;
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
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const InputDataWargaPage()),
              );
              break;
          }
        },
      ),
    );
  }
}