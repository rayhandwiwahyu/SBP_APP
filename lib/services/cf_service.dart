import '../models/warga_model.dart';

// ── Enum jenis bansos ────────────────────────────────────────────────
enum JenisBansos { pkh, bpnt, pip, blt, bantuanDaerah, tidakLayak }

class HasilAnalisis {
  final double cfPKH;
  final double cfBPNT;
  final double cfPIP;
  final double cfBLT;
  final double cfBantuanDaerah;
  final double cfGabungan;
  final bool layak;
  final bool blacklisted;
  final JenisBansos rekomendasiUtama;
  final String namaRekomendasi;
  final List<String> alasanLayak;
  final List<DetailFaktor> detailFaktor;

  HasilAnalisis({
    required this.cfPKH,
    required this.cfBPNT,
    required this.cfPIP,
    required this.cfBLT,
    required this.cfBantuanDaerah,
    required this.cfGabungan,
    required this.layak,
    required this.blacklisted,
    required this.rekomendasiUtama,
    required this.namaRekomendasi,
    required this.alasanLayak,
    required this.detailFaktor,
  });
}

class DetailFaktor {
  final String faktor;
  final String kondisi;
  final double cfNilai;
  final bool terpenuhi;
  final bool negatif;

  DetailFaktor({
    required this.faktor,
    required this.kondisi,
    required this.cfNilai,
    required this.terpenuhi,
    this.negatif = false,
  });
}

class CFService {
  // ── CF Pakar — Pendapatan ─────────────────────────────────────────
  static const double cfPendapatanSangatRendah = 1.0; // < 500rb
  static const double cfPendapatanRendah       = 1.0; // 500rb–1,5jt
  static const double cfPendapatanMenengah     = 1.0; // 1,5jt–2,5jt

  // ── CF Pakar — Tanggungan ─────────────────────────────────────────
  static const double cfTanggunganBanyak  = 0.8; // > 4 orang
  static const double cfTanggunganSedang  = 1.0; // 3–4 orang
  static const double cfTanggunganSedikit = 0.6; // 1–2 orang

  // ── CF Pakar — Kondisi Rumah ──────────────────────────────────────
  static const double cfRumahGubuk         = 1.0;
  static const double cfRumahTidakPermanen = 0.8;
  static const double cfRumahSemiPermanen  = 0.6;

  // ── CF Pakar — Lahan ─────────────────────────────────────────────
  static const double cfTidakPunyaLahan = 1.0;
  static const double cfPunyaLahan      = -0.4;

  // ── CF Pakar — Aset ──────────────────────────────────────────────
  static const double cfTidakPunyaAset          = 0.8;
  static const double cfPunyaTernak             = -0.6;
  static const double cfPunyaTabunganEmas       = -0.4;
  static const double cfPunyaKeduanya           = -0.2;
  static const double cfPunyaKendaraanLebihSatu = -0.6;

  // ── CF Pakar — Kondisi Khusus ─────────────────────────────────────
  static const double cfDisabilitas       = 1.0;
  static const double cfLansia            = 0.8;
  static const double cfDisabilitasLansia = 1.0;
  static const double cfIbuHamil          = 0.8;
  static const double cfBalita            = 0.6;
  static const double cfAnakSekolah       = 0.2;

  // ── Rumus Kombinasi CF ────────────────────────────────────────────
  static double _kombinasi(double cf1, double cf2) {
    if (cf1 >= 0 && cf2 >= 0) {
      return cf1 + cf2 * (1 - cf1);
    } else if (cf1 < 0 && cf2 < 0) {
      return cf1 + cf2 * (1 + cf1);
    } else {
      final min = cf1.abs() < cf2.abs() ? cf1.abs() : cf2.abs();
      return (cf1 + cf2) / (1 - min);
    }
  }

  static double _gabungkan(List<double> listCF) {
    final filtered = listCF.where((c) => c != 0).toList();
    if (filtered.isEmpty) return 0.0;
    double hasil = filtered[0];
    for (int i = 1; i < filtered.length; i++) {
      hasil = _kombinasi(hasil, filtered[i]);
    }
    return hasil.clamp(-1.0, 1.0);
  }

  // ── Faktor Ekonomi Dasar (dipakai semua jenis bansos) ────────────
  static List<double> _faktorekonomiDasar(WargaModel d) {
    List<double> list = [];

    // Tanggungan
    if (d.jumlahTanggungan > 4) {
      list.add(cfTanggunganBanyak);
    } else if (d.jumlahTanggungan >= 3) {
      list.add(cfTanggunganSedang);
    } else if (d.jumlahTanggungan >= 1) {
      list.add(cfTanggunganSedikit);
    }

    // Kondisi Rumah
    if (d.kondisiRumah == 'Gubuk / Sangat Tidak Layak') {
      list.add(cfRumahGubuk);
    } else if (d.kondisiRumah == 'Tidak Permanen') {
      list.add(cfRumahTidakPermanen);
    } else if (d.kondisiRumah == 'Semi Permanen') {
      list.add(cfRumahSemiPermanen);
    }

    // Lahan
    if (d.statusLahan == 'Numpang / Tidak Ada') {
      list.add(cfTidakPunyaLahan);
    } else {
      list.add(cfPunyaLahan);
    }

    // Aset
    if (d.punyaTernak && d.punyaTabunganEmas) {
      list.add(cfPunyaKeduanya);
    } else if (d.punyaTernak) {
      list.add(cfPunyaTernak);
    } else if (d.punyaTabunganEmas) {
      list.add(cfPunyaTabunganEmas);
    } else {
      list.add(cfTidakPunyaAset);
    }

    // Kendaraan > 1
    if (d.punyaKendaraanLebihSatu) {
      list.add(cfPunyaKendaraanLebihSatu);
    }

    return list;
  }

  // ── Hitung CF PKH ─────────────────────────────────────────────────
  // Syarat: pendapatan < 1,5jt + ada komponen khusus PKH
  static double _hitungPKH(WargaModel d) {
    if (d.pendapatanBulanan >= 1500000) return 0.0;

    // Harus ada minimal 1 komponen PKH
    bool adaKomponenPKH = d.adaIbuHamil || d.adaBalita ||
        d.adaAnakSekolah || d.adaDisabilitas || d.adaLansia;
    if (!adaKomponenPKH) return 0.0;

    List<double> list = [];

    // Pendapatan
    if (d.pendapatanBulanan < 500000) {
      list.add(cfPendapatanSangatRendah);
    } else {
      list.add(cfPendapatanRendah);
    }

    // Komponen PKH khusus
    if (d.adaDisabilitas && d.adaLansia) {
      list.add(cfDisabilitasLansia);
    } else if (d.adaDisabilitas) {
      list.add(cfDisabilitas);
    } else if (d.adaLansia) {
      list.add(cfLansia);
    }
    if (d.adaIbuHamil)    list.add(cfIbuHamil);
    if (d.adaBalita)      list.add(cfBalita);
    if (d.adaAnakSekolah) list.add(cfAnakSekolah);

    // Faktor ekonomi dasar
    list.addAll(_faktorekonomiDasar(d));

    return _gabungkan(list).clamp(0.0, 1.0);
  }

  // ── Hitung CF BPNT (Sembako) ──────────────────────────────────────
  // Syarat: pendapatan < 2,5jt, keluarga miskin umum
  static double _hitungBPNT(WargaModel d) {
    if (d.pendapatanBulanan >= 2500000) return 0.0;

    List<double> list = [];

    // Pendapatan
    if (d.pendapatanBulanan < 500000) {
      list.add(cfPendapatanSangatRendah);
    } else if (d.pendapatanBulanan < 1500000) {
      list.add(cfPendapatanRendah);
    } else {
      list.add(cfPendapatanMenengah);
    }

    list.addAll(_faktorekonomiDasar(d));
    return _gabungkan(list).clamp(0.0, 1.0);
  }

  // ── Hitung CF PIP ─────────────────────────────────────────────────
  // Syarat: ada anak sekolah SD–SMA + pendapatan < 1,5jt
  static double _hitungPIP(WargaModel d) {
    if (!d.adaAnakSekolah) return 0.0;
    if (d.pendapatanBulanan >= 1500000) return 0.0;

    List<double> list = [];

    if (d.pendapatanBulanan < 500000) {
      list.add(cfPendapatanSangatRendah);
    } else {
      list.add(cfPendapatanRendah);
    }

    list.add(cfAnakSekolah);
    list.addAll(_faktorekonomiDasar(d));
    return _gabungkan(list).clamp(0.0, 1.0);
  }

  // ── Hitung CF BLT ─────────────────────────────────────────────────
  // Syarat: pendapatan < 1,5jt, tidak ada komponen PKH khusus
  static double _hitungBLT(WargaModel d) {
    if (d.pendapatanBulanan >= 1500000) return 0.0;

    List<double> list = [];

    if (d.pendapatanBulanan < 500000) {
      list.add(cfPendapatanSangatRendah);
    } else {
      list.add(cfPendapatanRendah);
    }

    list.addAll(_faktorekonomiDasar(d));
    return _gabungkan(list).clamp(0.0, 1.0);
  }

  // ── Hitung CF Bantuan Daerah ──────────────────────────────────────
  // Syarat: pendapatan < 2,5jt + kondisi ekonomi sulit
  // tapi tidak tercover program pusat (CF lainnya rendah)
  static double _hitungBantuanDaerah(WargaModel d, {
    required double cfPKH,
    required double cfBPNT,
    required double cfPIP,
    required double cfBLT,
  }) {
    if (d.pendapatanBulanan >= 2500000) return 0.0;

    // Jika sudah tercover program pusat dengan CF tinggi, tidak perlu bantuan daerah
    final maxPusat = [cfPKH, cfBPNT, cfPIP, cfBLT]
        .reduce((a, b) => a > b ? a : b);
    if (maxPusat >= 0.6) return 0.0;

    List<double> list = [];

    if (d.pendapatanBulanan < 500000) {
      list.add(cfPendapatanSangatRendah);
    } else if (d.pendapatanBulanan < 1500000) {
      list.add(cfPendapatanRendah);
    } else {
      list.add(cfPendapatanMenengah);
    }

    list.addAll(_faktorekonomiDasar(d));
    return _gabungkan(list).clamp(0.0, 1.0);
  }

  // ── Main: Analisis ────────────────────────────────────────────────
  static HasilAnalisis analisis(WargaModel data) {

    // Blacklist — ASN/PNS/TNI/Polri
    if (data.isASNTNIPolri) {
      return HasilAnalisis(
        cfPKH: 0.0, cfBPNT: 0.0, cfPIP: 0.0,
        cfBLT: 0.0, cfBantuanDaerah: 0.0,
        cfGabungan: 0.0,
        layak: false,
        blacklisted: true,
        rekomendasiUtama: JenisBansos.tidakLayak,
        namaRekomendasi: 'Tidak Layak — ASN/TNI/Polri',
        alasanLayak: ['ASN, TNI, dan Polri tidak memenuhi syarat penerima bantuan sosial berdasarkan regulasi Kemensos.'],
        detailFaktor: [],
      );
    }

    // Pendapatan > 2,5jt langsung tidak layak
    if (data.pendapatanBulanan >= 2500000) {
      return HasilAnalisis(
        cfPKH: 0.0, cfBPNT: 0.0, cfPIP: 0.0,
        cfBLT: 0.0, cfBantuanDaerah: 0.0,
        cfGabungan: 0.0,
        layak: false,
        blacklisted: false,
        rekomendasiUtama: JenisBansos.tidakLayak,
        namaRekomendasi: 'Tidak Layak — Pendapatan Di Atas Batas',
        alasanLayak: ['Pendapatan Rp ${_rp(data.pendapatanBulanan)}/bulan melebihi batas maksimal kelayakan bansos (Rp 2.500.000/bulan).'],
        detailFaktor: [
          DetailFaktor(
            faktor: 'Pendapatan Bulanan',
            kondisi: 'Rp ${_rp(data.pendapatanBulanan)}/bulan',
            cfNilai: 0.0,
            terpenuhi: false,
            negatif: true,
          ),
        ],
      );
    }

    // Hitung semua CF
    final cfPKH          = _hitungPKH(data);
    final cfBPNT         = _hitungBPNT(data);
    final cfPIP          = _hitungPIP(data);
    final cfBLT          = _hitungBLT(data);
    final cfBantuanDaerah = _hitungBantuanDaerah(
      data,
      cfPKH: cfPKH, cfBPNT: cfBPNT,
      cfPIP: cfPIP, cfBLT: cfBLT,
    );

    // Tentukan rekomendasi utama (CF tertinggi = prioritas)
    final Map<JenisBansos, double> semuaCF = {
      JenisBansos.pkh:           cfPKH,
      JenisBansos.bpnt:          cfBPNT,
      JenisBansos.pip:           cfPIP,
      JenisBansos.blt:           cfBLT,
      JenisBansos.bantuanDaerah: cfBantuanDaerah,
    };

    // Urutan prioritas jika CF sama
    final List<JenisBansos> prioritas = [
      JenisBansos.pkh,
      JenisBansos.bpnt,
      JenisBansos.pip,
      JenisBansos.blt,
      JenisBansos.bantuanDaerah,
    ];

    JenisBansos rekomendasiTerpilih = JenisBansos.tidakLayak;
    double cfTertinggi = 0.0;

    for (final jenis in prioritas) {
      final cf = semuaCF[jenis] ?? 0.0;
      if (cf > cfTertinggi) {
        cfTertinggi = cf;
        rekomendasiTerpilih = jenis;
      }
    }

    final layak = cfTertinggi >= 0.4;
    if (!layak) rekomendasiTerpilih = JenisBansos.tidakLayak;

    final cfGabungan = cfTertinggi;

    // Nama rekomendasi
    final Map<JenisBansos, String> namaMap = {
      JenisBansos.pkh:           'Program Keluarga Harapan (PKH)',
      JenisBansos.bpnt:          'BPNT / Bantuan Pangan Non Tunai (Sembako)',
      JenisBansos.pip:           'PIP / Program Indonesia Pintar',
      JenisBansos.blt:           'BLT / Bantuan Langsung Tunai',
      JenisBansos.bantuanDaerah: 'Bantuan Sosial Daerah',
      JenisBansos.tidakLayak:    'Tidak Layak Menerima Bantuan Sosial',
    };

    // Alasan
    List<String> alasan = [];
    if (data.pendapatanBulanan < 1500000) {
      alasan.add('Pendapatan Rp ${_rp(data.pendapatanBulanan)}/bulan di bawah ambang batas DTKS');
    }
    if (data.jumlahTanggungan >= 3) {
      alasan.add('Memiliki ${data.jumlahTanggungan} tanggungan keluarga');
    }
    if (data.kondisiRumah != 'Permanen') {
      alasan.add('Kondisi rumah: ${data.kondisiRumah}');
    }
    if (data.statusLahan == 'Numpang / Tidak Ada') {
      alasan.add('Tidak memiliki lahan/rumah sendiri');
    }
    if (!data.punyaTernak && !data.punyaTabunganEmas) {
      alasan.add('Tidak memiliki aset produktif');
    }
    if (data.adaDisabilitas) alasan.add('Terdapat anggota penyandang disabilitas');
    if (data.adaLansia)      alasan.add('Terdapat anggota lanjut usia (≥ 60 tahun)');
    if (data.adaIbuHamil)    alasan.add('Terdapat ibu hamil dalam keluarga');
    if (data.adaBalita)      alasan.add('Terdapat anak balita usia 0–6 tahun');
    if (data.adaAnakSekolah) alasan.add('Terdapat anak usia sekolah (SD–SMA)');

    // Detail Faktor
    double cfPendapatanVal = data.pendapatanBulanan < 500000
        ? cfPendapatanSangatRendah
        : data.pendapatanBulanan < 1500000
            ? cfPendapatanRendah
            : cfPendapatanMenengah;

    double cfTanggunganVal = data.jumlahTanggungan > 4
        ? cfTanggunganBanyak
        : data.jumlahTanggungan >= 3
            ? cfTanggunganSedang
            : cfTanggunganSedikit;

    double cfRumahVal = data.kondisiRumah == 'Gubuk / Sangat Tidak Layak'
        ? cfRumahGubuk
        : data.kondisiRumah == 'Tidak Permanen'
            ? cfRumahTidakPermanen
            : data.kondisiRumah == 'Semi Permanen'
                ? cfRumahSemiPermanen
                : 0.0;

    double cfAsetVal = (data.punyaTernak && data.punyaTabunganEmas)
        ? cfPunyaKeduanya
        : data.punyaTernak
            ? cfPunyaTernak
            : data.punyaTabunganEmas
                ? cfPunyaTabunganEmas
                : cfTidakPunyaAset;

    List<DetailFaktor> detail = [
      DetailFaktor(
        faktor: 'Pendapatan Bulanan',
        kondisi: 'Rp ${_rp(data.pendapatanBulanan)}/bulan',
        cfNilai: cfPendapatanVal,
        terpenuhi: data.pendapatanBulanan < 2500000,
      ),
      DetailFaktor(
        faktor: 'Jumlah Tanggungan',
        kondisi: '${data.jumlahTanggungan} orang',
        cfNilai: cfTanggunganVal,
        terpenuhi: data.jumlahTanggungan >= 1,
      ),
      DetailFaktor(
        faktor: 'Kondisi Rumah',
        kondisi: data.kondisiRumah,
        cfNilai: cfRumahVal,
        terpenuhi: data.kondisiRumah != 'Permanen',
      ),
      DetailFaktor(
        faktor: 'Status Lahan',
        kondisi: data.statusLahan,
        cfNilai: data.statusLahan == 'Numpang / Tidak Ada'
            ? cfTidakPunyaLahan
            : cfPunyaLahan,
        terpenuhi: data.statusLahan == 'Numpang / Tidak Ada',
        negatif: data.statusLahan != 'Numpang / Tidak Ada',
      ),
      DetailFaktor(
        faktor: 'Kepemilikan Aset',
        kondisi: (data.punyaTernak && data.punyaTabunganEmas)
            ? 'Ternak + Tabungan/Emas'
            : data.punyaTernak
                ? 'Punya Ternak'
                : data.punyaTabunganEmas
                    ? 'Punya Tabungan/Emas'
                    : 'Tidak Ada Aset',
        cfNilai: cfAsetVal,
        terpenuhi: !data.punyaTernak && !data.punyaTabunganEmas,
        negatif: cfAsetVal < 0,
      ),
      DetailFaktor(
        faktor: 'Kendaraan > 1',
        kondisi: data.punyaKendaraanLebihSatu ? 'Punya' : 'Tidak Ada',
        cfNilai: data.punyaKendaraanLebihSatu ? cfPunyaKendaraanLebihSatu : 0.0,
        terpenuhi: !data.punyaKendaraanLebihSatu,
        negatif: data.punyaKendaraanLebihSatu,
      ),
      DetailFaktor(
        faktor: 'Disabilitas / Lansia',
        kondisi: (data.adaDisabilitas && data.adaLansia)
            ? 'Ada Keduanya'
            : data.adaDisabilitas
                ? 'Ada Disabilitas'
                : data.adaLansia
                    ? 'Ada Lansia'
                    : 'Tidak Ada',
        cfNilai: (data.adaDisabilitas && data.adaLansia)
            ? cfDisabilitasLansia
            : data.adaDisabilitas
                ? cfDisabilitas
                : data.adaLansia
                    ? cfLansia
                    : 0.0,
        terpenuhi: data.adaDisabilitas || data.adaLansia,
      ),
      DetailFaktor(
        faktor: 'Ibu Hamil',
        kondisi: data.adaIbuHamil ? 'Ada' : 'Tidak Ada',
        cfNilai: data.adaIbuHamil ? cfIbuHamil : 0.0,
        terpenuhi: data.adaIbuHamil,
      ),
      DetailFaktor(
        faktor: 'Balita (0–6 tahun)',
        kondisi: data.adaBalita ? 'Ada' : 'Tidak Ada',
        cfNilai: data.adaBalita ? cfBalita : 0.0,
        terpenuhi: data.adaBalita,
      ),
      DetailFaktor(
        faktor: 'Anak Usia Sekolah (SD–SMA)',
        kondisi: data.adaAnakSekolah ? 'Ada' : 'Tidak Ada',
        cfNilai: data.adaAnakSekolah ? cfAnakSekolah : 0.0,
        terpenuhi: data.adaAnakSekolah,
      ),
    ];

    return HasilAnalisis(
      cfPKH: cfPKH,
      cfBPNT: cfBPNT,
      cfPIP: cfPIP,
      cfBLT: cfBLT,
      cfBantuanDaerah: cfBantuanDaerah,
      cfGabungan: cfGabungan,
      layak: layak,
      blacklisted: false,
      rekomendasiUtama: rekomendasiTerpilih,
      namaRekomendasi: namaMap[rekomendasiTerpilih]!,
      alasanLayak: alasan,
      detailFaktor: detail,
    );
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
}