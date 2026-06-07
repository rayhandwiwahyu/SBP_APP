import 'package:flutter/material.dart';
import 'dart:async';
import '../models/warga_model.dart';
import '../services/cf_service.dart';
import 'detail_keputusan_page.dart';

class AnalisisPage extends StatefulWidget {
  final WargaModel dataWarga;

  const AnalisisPage({super.key, required this.dataWarga});

  @override
  State<AnalisisPage> createState() => _AnalisisPageState();
}

class _AnalisisPageState extends State<AnalisisPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  late HasilAnalisis _hasil;

  static const Color bgDark = Color(0xFF0D1B2A);
  static const Color primaryBlue = Color(0xFF1565C0);

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Validasi Data Input',
      'subtitle': 'Memeriksa kelengkapan data...',
      'done': false,
    },
    {
      'title': 'Menghitung Indeks Kesejahteraan',
      'subtitle': 'Membandingkan pendapatan per kapita...',
      'done': false,
    },
    {
      'title': 'Menghitung Certainty Factor',
      'subtitle': 'Menggabungkan semua nilai CF...',
      'done': false,
    },
    {
      'title': 'Menghasilkan Keputusan',
      'subtitle': 'Menentukan rekomendasi bantuan...',
      'done': false,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Jalankan CF di awal
    _hasil = CFService.analisis(widget.dataWarga);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: _hasil.cfGabungan,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
    _simulateSteps();
  }

void _simulateSteps() async {
  // Step 1 — Validasi Data
  await Future.delayed(const Duration(seconds: 2));
  if (mounted) {
    setState(() {
      _steps[0]['done'] = true;
      _steps[0]['subtitle'] = 'Selesai — data valid';
      _currentStep = 1;
    });
  }

  // Step 2 — Hitung Indeks Kesejahteraan
  await Future.delayed(const Duration(seconds: 3));
  if (mounted) {
    setState(() {
      _steps[1]['done'] = true;
      _steps[1]['subtitle'] =
          'Pendapatan Rp ${widget.dataWarga.pendapatanBulanan.toInt()} / bulan';
      _currentStep = 2;
    });
  }

  // Step 3 — Hitung CF
  await Future.delayed(const Duration(seconds: 3));
  if (mounted) {
    setState(() {
      _steps[2]['done'] = true;
      _steps[2]['subtitle'] =
          'CF Gabungan: ${(_hasil.cfGabungan * 100).toStringAsFixed(0)}%';
      _currentStep = 3;
    });
  }

  // Step 4 — Keputusan
  await Future.delayed(const Duration(seconds: 2));
  if (mounted) {
    setState(() {
      _steps[3]['done'] = true;
      _steps[3]['subtitle'] = _hasil.namaRekomendasi;
    });
  }

  // Jeda sebelum pindah halaman
  await Future.delayed(const Duration(seconds: 1));
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetailKeputusanPage(
          dataWarga: widget.dataWarga,
          hasil: _hasil,
        ),
      ),
    );
  }
}

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
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
          'Analisis Sistem',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildProgressCircle(),
            const SizedBox(height: 20),
            _buildLogicTreeCard(),
            const SizedBox(height: 14),
            _buildForwardChainingLog(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProgressCircle() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (_, __) {
              return SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _hasil.layak
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RotationTransition(
                          turns: _rotationController,
                          child: const Icon(
                            Icons.psychology_outlined,
                            color: primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (_, __) => Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Analisis Sedang Berjalan...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Memproses data ${widget.dataWarga.namaLengkap}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogicTreeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '≡ LOGIC TREE EXPLORER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTreeNode(Icons.dataset_outlined, Colors.blueGrey),
              _buildTreeArrow(),
              _buildTreeNode(Icons.psychology, primaryBlue, active: true),
              _buildTreeArrow(),
              _buildTreeNode(Icons.verified_outlined, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(IconData icon, Color color, {bool active = false}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: active ? primaryBlue.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? primaryBlue : Colors.grey.shade300,
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [BoxShadow(color: primaryBlue.withOpacity(0.2), blurRadius: 8)]
            : [],
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }

  Widget _buildTreeArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 18),
    );
  }

  Widget _buildForwardChainingLog() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log Inferensi (Forward Chaining)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ..._steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone = step['done'] as bool;
            final isActive = i == _currentStep && !isDone;

            return _buildLogStep(
              icon: isDone
                  ? Icons.check_circle
                  : (isActive ? Icons.sync : Icons.radio_button_unchecked),
              color: isDone
                  ? const Color(0xFF2E7D32)
                  : (isActive ? primaryBlue : Colors.grey.shade400),
              title: step['title'] as String,
              subtitle: step['subtitle'] as String,
              isActive: isActive,
              isLast: i == _steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogStep({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    bool isActive = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              isActive
                  ? RotationTransition(
                      turns: _rotationController,
                      child: Icon(icon, color: color, size: 20),
                    )
                  : Icon(icon, color: color, size: 20),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? primaryBlue : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Analisis'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onTap: (_) {},
      ),
    );
  }
}