import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/warga_model.dart';
import '../services/cf_service.dart';

class DatabaseService {
  static final _db = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://bansos-app-c9752-default-rtdb.asia-southeast1.firebasedatabase.app/',
).ref();

  // ── Simpan data warga + hasil analisis ───────────────────────────
  static Future<void> simpanHasilAnalisis({
    required WargaModel warga,
    required HasilAnalisis hasil,
  }) async {
    final data = {
      // Identitas
      'namaLengkap':            warga.namaLengkap,
      'nik':                    warga.nik,
      'kecamatan':              warga.kecamatan,
      'pekerjaanUtama':         warga.pekerjaanUtama,

      // Ekonomi
      'pendapatanBulanan':      warga.pendapatanBulanan,
      'jumlahTanggungan':       warga.jumlahTanggungan,

      // Rumah & Aset
      'kondisiRumah':           warga.kondisiRumah,
      'statusLahan':            warga.statusLahan,
      'isASNTNIPolri':          warga.isASNTNIPolri,
      'punyaTernak':            warga.punyaTernak,
      'punyaTabunganEmas':      warga.punyaTabunganEmas,
      'punyaKendaraanLebihSatu': warga.punyaKendaraanLebihSatu,

      // Kondisi Khusus PKH
      'adaDisabilitas':         warga.adaDisabilitas,
      'adaLansia':              warga.adaLansia,
      'adaIbuHamil':            warga.adaIbuHamil,
      'adaBalita':              warga.adaBalita,
      'adaAnakSekolah':         warga.adaAnakSekolah,

      // Hasil Analisis
      'hasilRekomendasi':       hasil.namaRekomendasi,
      'cfGabungan':             hasil.cfGabungan,
      'cfPKH':                  hasil.cfPKH,
      'cfBPNT':                 hasil.cfBPNT,
      'cfPIP':                  hasil.cfPIP,
      'cfBLT':                  hasil.cfBLT,
      'cfBantuanDaerah':        hasil.cfBantuanDaerah,
      'layak':                  hasil.layak,
      'blacklisted':            hasil.blacklisted,
      'tanggalAnalisis':        DateTime.now().toIso8601String().split('T')[0],
      'waktuAnalisis':          DateTime.now().toIso8601String(),
    };

    // Simpan dengan NIK sebagai key agar tidak duplikat
    await _db.child('warga').child(warga.nik).set(data);
  }

  // ── Ambil semua data warga ────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> ambilSemuaWarga() async {
    final snapshot = await _db.child('warga').get();
    if (!snapshot.exists) return [];

    final List<Map<String, dynamic>> list = [];
    final data = snapshot.value as Map<dynamic, dynamic>;

    data.forEach((key, value) {
      final item = Map<String, dynamic>.from(value as Map);
      item['id'] = key.toString();
      list.add(item);
    });

    // Urutkan berdasarkan waktu terbaru
    list.sort((a, b) {
      final aTime = a['waktuAnalisis'] as String? ?? '';
      final bTime = b['waktuAnalisis'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    return list;
  }

  // ── Ambil data warga berdasarkan NIK ─────────────────────────────
  static Future<Map<String, dynamic>?> ambilWargaByNIK(String nik) async {
    final snapshot = await _db.child('warga').child(nik).get();
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // ── Hapus data warga ──────────────────────────────────────────────
  static Future<void> hapusWarga(String nik) async {
    await _db.child('warga').child(nik).remove();
  }

  // ── Statistik dashboard ───────────────────────────────────────────
  static Future<Map<String, int>> ambilStatistik() async {
    final snapshot = await _db.child('warga').get();
    if (!snapshot.exists) {
      return {'total': 0, 'layak': 0, 'tidakLayak': 0};
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    int total     = 0;
    int layak     = 0;
    int tidakLayak = 0;

    data.forEach((key, value) {
      total++;
      final item = Map<String, dynamic>.from(value as Map);
      if (item['layak'] == true) {
        layak++;
      } else {
        tidakLayak++;
      }
    });

    return {'total': total, 'layak': layak, 'tidakLayak': tidakLayak};
  }
}