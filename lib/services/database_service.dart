import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/warga_model.dart';
import '../services/cf_service.dart';

class DatabaseService {
  static final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://bansos-app-c9752-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  // Ambil UID user yang sedang login
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── Simpan data warga + hasil analisis ───────────────────────────
  static Future<void> simpanHasilAnalisis({
    required WargaModel warga,
    required HasilAnalisis hasil,
  }) async {
    print('🔵 UID saat ini: $_uid');
    final data = {
      'namaLengkap':             warga.namaLengkap,
      'nik':                     warga.nik,
      'kecamatan':               warga.kecamatan,
      'pekerjaanUtama':          warga.pekerjaanUtama,
      'pendapatanBulanan':       warga.pendapatanBulanan,
      'jumlahTanggungan':        warga.jumlahTanggungan,
      'kondisiRumah':            warga.kondisiRumah,
      'statusLahan':             warga.statusLahan,
      'isASNTNIPolri':           warga.isASNTNIPolri,
      'punyaTernak':             warga.punyaTernak,
      'punyaTabunganEmas':       warga.punyaTabunganEmas,
      'punyaKendaraanLebihSatu': warga.punyaKendaraanLebihSatu,
      'adaDisabilitas':          warga.adaDisabilitas,
      'adaLansia':               warga.adaLansia,
      'adaIbuHamil':             warga.adaIbuHamil,
      'adaBalita':               warga.adaBalita,
      'adaAnakSekolah':          warga.adaAnakSekolah,
      'hasilRekomendasi':        hasil.namaRekomendasi,
      'cfGabungan':              hasil.cfGabungan,
      'cfPKH':                   hasil.cfPKH,
      'cfBPNT':                  hasil.cfBPNT,
      'cfPIP':                   hasil.cfPIP,
      'cfBLT':                   hasil.cfBLT,
      'cfBantuanDaerah':         hasil.cfBantuanDaerah,
      'layak':                   hasil.layak,
      'blacklisted':             hasil.blacklisted,
      'tanggalAnalisis':         DateTime.now().toIso8601String().split('T')[0],
      'waktuAnalisis':           DateTime.now().toIso8601String(),
    };

    print('🔵 Path: users/$_uid/warga/${warga.nik}');
    print('🔵 Mulai .set()...');

    // ✅ Simpan per user: users/{uid}/warga/{nik}
    try {
    await _db.child('users').child(_uid).child('warga').child(warga.nik)
        .set(data)
        .timeout(const Duration(seconds: 10));
    print('🟢 .set() BERHASIL');
  } catch (e) {
    print('🔴 .set() ERROR: $e');
    rethrow;
  }
}

  // ── Ambil semua data warga milik user yang login ──────────────────
  static Future<List<Map<String, dynamic>>> ambilSemuaWarga() async {
    // ✅ Ambil hanya data warga milik user yang login
    final snapshot = await _db.child('users').child(_uid).child('warga').get();
    if (!snapshot.exists) return [];

    final List<Map<String, dynamic>> list = [];
    final data = snapshot.value as Map<dynamic, dynamic>;

    data.forEach((key, value) {
      final item = Map<String, dynamic>.from(value as Map);
      item['id'] = key.toString();
      list.add(item);
    });

    list.sort((a, b) {
      final aTime = a['waktuAnalisis'] as String? ?? '';
      final bTime = b['waktuAnalisis'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    return list;
  }

  // ── Ambil data warga berdasarkan NIK ─────────────────────────────
  static Future<Map<String, dynamic>?> ambilWargaByNIK(String nik) async {
    final snapshot = await _db
        .child('users').child(_uid).child('warga').child(nik).get();
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // ── Hapus data warga ──────────────────────────────────────────────
  static Future<void> hapusWarga(String nik) async {
    await _db.child('users').child(_uid).child('warga').child(nik).remove();
  }

  // ── Statistik dashboard (hanya data milik user login) ────────────
  static Future<Map<String, int>> ambilStatistik() async {
    final snapshot = await _db.child('users').child(_uid).child('warga').get();
    if (!snapshot.exists) {
      return {'total': 0, 'layak': 0, 'tidakLayak': 0};
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    int total      = 0;
    int layak      = 0;
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

  // ── Simpan profil user ────────────────────────────────────────────
  static Future<void> simpanProfilUser({
    required String uid,
    required String namaLengkap,
    required String email,
    required String jabatan,
    required String instansi,
  }) async {
    await _db.child('users').child(uid).child('profil').set({
      'namaLengkap':   namaLengkap,
      'email':         email,
      'jabatan':       jabatan,
      'instansi':      instansi,
      'tanggalDaftar': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  // ── Ambil profil user ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> ambilProfilUser(String uid) async {
    final snapshot = await _db.child('users').child(uid).child('profil').get();
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // ── Update data warga (kecuali nama & NIK) ────────────────────────
static Future<void> updateWarga({
  required String nik,
  required Map<String, dynamic> dataBaru,
}) async {
  await _db.child('users').child(_uid).child('warga').child(nik).update(dataBaru);
}

  // ── Ambil data rekap untuk laporan ────────────────────────────────
static Future<Map<String, dynamic>> ambilDataRekap() async {
  final snapshot = await _db.child('users').child(_uid).child('warga').get();

  if (!snapshot.exists) {
    return {
      'total': 0,
      'layak': 0,
      'tidakLayak': 0,
      'perBansos': <String, int>{},
      'perKecamatan': <String, Map<String, int>>{},
    };
  }

  final data = snapshot.value as Map<dynamic, dynamic>;

  int total      = 0;
  int layak      = 0;
  int tidakLayak = 0;

  final Map<String, int> perBansos = {
    'PKH': 0,
    'BPNT': 0,
    'PIP': 0,
    'BLT': 0,
    'Bantuan Daerah': 0,
  };

  final Map<String, Map<String, int>> perKecamatan = {};

  data.forEach((key, value) {
    total++;
    final item = Map<String, dynamic>.from(value as Map);
    final isLayak = item['layak'] == true;

    if (isLayak) {
      layak++;
    } else {
      tidakLayak++;
    }

    // Hitung per jenis bansos
    final rekomendasi = item['hasilRekomendasi'] as String? ?? '';
    if (rekomendasi.contains('PKH')) {
      perBansos['PKH'] = (perBansos['PKH'] ?? 0) + 1;
    } else if (rekomendasi.contains('BPNT')) {
      perBansos['BPNT'] = (perBansos['BPNT'] ?? 0) + 1;
    } else if (rekomendasi.contains('PIP')) {
      perBansos['PIP'] = (perBansos['PIP'] ?? 0) + 1;
    } else if (rekomendasi.contains('BLT')) {
      perBansos['BLT'] = (perBansos['BLT'] ?? 0) + 1;
    } else if (rekomendasi.contains('Daerah')) {
      perBansos['Bantuan Daerah'] = (perBansos['Bantuan Daerah'] ?? 0) + 1;
    }

    // Hitung per kecamatan
    final kecamatan = item['kecamatan'] as String? ?? 'Tidak Diketahui';
    perKecamatan.putIfAbsent(kecamatan, () => {'total': 0, 'layak': 0, 'tidakLayak': 0});
    perKecamatan[kecamatan]!['total'] = (perKecamatan[kecamatan]!['total'] ?? 0) + 1;
    if (isLayak) {
      perKecamatan[kecamatan]!['layak'] = (perKecamatan[kecamatan]!['layak'] ?? 0) + 1;
    } else {
      perKecamatan[kecamatan]!['tidakLayak'] = (perKecamatan[kecamatan]!['tidakLayak'] ?? 0) + 1;
    }
  });

  return {
    'total': total,
    'layak': layak,
    'tidakLayak': tidakLayak,
    'perBansos': perBansos,
    'perKecamatan': perKecamatan,
  };
}
}