import '../models/warga_model.dart';

class HasilAnalisis {
  final double cfSembako;
  final double cfPKH;
  final double cfGabungan;
  final bool layak;
  final bool blacklisted;
  final String rekomendasiUtama;
  final List<String> alasanLayak;
  final List<DetailFaktor> detailFaktor;

  HasilAnalisis({
    required this.cfSembako,
    required this.cfPKH,
    required this.cfGabungan,
    required this.layak,
    required this.blacklisted,
    required this.rekomendasiUtama,
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
  // ── CF PAKAR — Sembako (dari kuesioner pakar) ─────────────────────
  // Pendapatan
  static const double cfPendapatanSangatRendah = 1.0;  // < 500rb   → skala 6
  static const double cfPendapatanRendah       = 1.0;  // 500rb-1,5jt → skala 6
  static const double cfPendapatanMenengah     = 1.0;  // 1,5jt-2,5jt → skala 6
  static const double cfPendapatanTinggi       = -1.0; // > 2,5jt   → skala 6 (negatif)

  // Tanggungan
  static const double cfTanggunganBanyak       = 0.8;  // > 4 orang  → skala 5
  static const double cfTanggunganSedang       = 1.0;  // 3–4 orang  → skala 6
  static const double cfTanggunganSedikit      = 0.6;  // 1–2 orang  → skala 4

  // Kondisi Rumah
  static const double cfRumahGubuk             = 1.0;  // Gubuk      → skala 6
  static const double cfRumahTidakPermanen     = 0.8;  // Tdk permanen → skala 5
  static const double cfRumahSemiPermanen      = 0.6;  // Semi       → skala 4

  // Lahan
  static const double cfTidakPunyaLahan        = 1.0;  // Numpang    → skala 6
  static const double cfPunyaLahan             = -0.4; // Milik sdr  → skala 3 (negatif)

  // Aset
  static const double cfTidakPunyaAset         = 0.8;  // Tdk ada aset → skala 5
  static const double cfPunyaTernak            = -0.6; // Punya ternak → skala 4 (negatif)
  static const double cfPunyaTabunganEmas      = -0.4; // Tabungan/emas → skala 3 (negatif)
  static const double cfPunyaKeduanya          = -0.2; // Ternak+tabungan → skala 2 (negatif)
  static const double cfPunyaKendaraanLebihSatu = -0.6; // dari wawancara pakar

  // ── CF PAKAR — PKH ────────────────────────────────────────────────
  static const double cfDisabilitas            = 1.0;  // skala 6
  static const double cfLansia                 = 0.8;  // skala 5
  static const double cfDisabilitasLansia      = 1.0;  // skala 6
  static const double cfIbuHamil               = 0.8;  // skala 5
  static const double cfBalita                 = 0.6;  // skala 4
  static const double cfAnakSekolah            = 0.2;  // skala 2

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

  // ── Hitung CF Sembako ─────────────────────────────────────────────
  static double _hitungSembako(WargaModel d) {
  // Pendapatan > 2,5jt → langsung tidak layak Sembako
  if (d.pendapatanBulanan >= 2500000) return 0.0;

  List<double> listCF = [];

  // Pendapatan
  if (d.pendapatanBulanan < 500000) {
    listCF.add(cfPendapatanSangatRendah);
  } else if (d.pendapatanBulanan < 1500000) {
    listCF.add(cfPendapatanRendah);
  } else {
    listCF.add(cfPendapatanMenengah);
  }

  // Tanggungan
  if (d.jumlahTanggungan > 4) {
    listCF.add(cfTanggunganBanyak);
  } else if (d.jumlahTanggungan >= 3) {
    listCF.add(cfTanggunganSedang);
  } else if (d.jumlahTanggungan >= 1) {
    listCF.add(cfTanggunganSedikit);
  }

  // Kondisi Rumah
  if (d.kondisiRumah == 'Gubuk / Sangat Tidak Layak') {
    listCF.add(cfRumahGubuk);
  } else if (d.kondisiRumah == 'Tidak Permanen') {
    listCF.add(cfRumahTidakPermanen);
  } else if (d.kondisiRumah == 'Semi Permanen') {
    listCF.add(cfRumahSemiPermanen);
  }

  // Lahan
  if (d.statusLahan == 'Numpang / Tidak Ada') {
    listCF.add(cfTidakPunyaLahan);
  } else {
    listCF.add(cfPunyaLahan);
  }

  // Aset
  if (d.punyaTernak && d.punyaTabunganEmas) {
    listCF.add(cfPunyaKeduanya);
  } else if (d.punyaTernak) {
    listCF.add(cfPunyaTernak);
  } else if (d.punyaTabunganEmas) {
    listCF.add(cfPunyaTabunganEmas);
  } else {
    listCF.add(cfTidakPunyaAset);
  }

  // Kendaraan > 1
  if (d.punyaKendaraanLebihSatu) {
    listCF.add(cfPunyaKendaraanLebihSatu);
  }

  return _gabungkan(listCF);
}

  // ── Hitung CF PKH ─────────────────────────────────────────────────
  static double _hitungPKH(WargaModel d) {
    List<double> listCF = [];

    // Harus memenuhi syarat ekonomi dasar dulu
    if (d.pendapatanBulanan < 2500000) {
      if (d.pendapatanBulanan < 500000) listCF.add(cfPendapatanSangatRendah);
      else if (d.pendapatanBulanan < 1500000) listCF.add(cfPendapatanRendah);
      else listCF.add(cfPendapatanMenengah);
    } else {
      return 0.0; // > 2,5jt → tidak memenuhi syarat PKH
    }

    // Komponen PKH khusus
    if (d.adaDisabilitas && d.adaLansia) {
      listCF.add(cfDisabilitasLansia);
    } else if (d.adaDisabilitas) {
      listCF.add(cfDisabilitas);
    } else if (d.adaLansia) {
      listCF.add(cfLansia);
    }

    if (d.adaIbuHamil) listCF.add(cfIbuHamil);
    if (d.adaBalita)   listCF.add(cfBalita);
    if (d.adaAnakSekolah) listCF.add(cfAnakSekolah);

    return _gabungkan(listCF);
  }

  // ── Main: Analisis ────────────────────────────────────────────────
  static HasilAnalisis analisis(WargaModel data) {
    // Blacklist — ASN/PNS/TNI/Polri otomatis tidak layak
    if (data.isASNTNIPolri) {
      return HasilAnalisis(
        cfSembako: 0.0,
        cfPKH: 0.0,
        cfGabungan: 0.0,
        layak: false,
        blacklisted: true,
        rekomendasiUtama: 'Tidak Layak — ASN/TNI/Polri',
        alasanLayak: ['ASN, TNI, dan Polri tidak termasuk kriteria penerima bantuan sosial berdasarkan regulasi Kemensos.'],
        detailFaktor: [],
      );
    }

    if (data.pendapatanBulanan >= 2500000) {
    return HasilAnalisis(
      cfSembako: 0.0,
      cfPKH: 0.0,
      cfGabungan: 0.0,
      layak: false,
      blacklisted: false,
      rekomendasiUtama: 'Tidak Layak — Pendapatan Di Atas Batas',
      alasanLayak: [
        'Pendapatan Rp ${_rp(data.pendapatanBulanan)}/bulan melebihi batas maksimal kelayakan bansos (Rp 2.500.000/bulan) berdasarkan regulasi DTKS Kemensos.',
      ],
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

    final cfSembako = _hitungSembako(data);
    final cfPKH     = _hitungPKH(data);
    final cfGabungan = cfSembako > 0
        ? _kombinasi(cfSembako, cfPKH > 0 ? cfPKH : 0)
        : cfSembako;

    final layak = cfGabungan >= 0.4;

    // Rekomendasi
    String rekomendasi;
    if (!layak) {
      rekomendasi = 'Tidak Layak Menerima Bansos';
    } else if (cfPKH >= 0.6 && cfSembako >= 0.6) {
      rekomendasi = 'Bansos Sembako + PKH';
    } else if (cfPKH > cfSembako && cfPKH >= 0.4) {
      rekomendasi = 'Bansos Uang Tunai (PKH)';
    } else {
      rekomendasi = 'Bansos Sembako';
    }

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

    // Detail Faktor
    double cfPendapatanVal = data.pendapatanBulanan < 500000
        ? cfPendapatanSangatRendah
        : data.pendapatanBulanan < 1500000
            ? cfPendapatanRendah
            : data.pendapatanBulanan < 2500000
                ? cfPendapatanMenengah
                : cfPendapatanTinggi;

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
        negatif: cfPendapatanVal < 0,
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
        faktor: 'Anak Usia Sekolah',
        kondisi: data.adaAnakSekolah ? 'Ada' : 'Tidak Ada',
        cfNilai: data.adaAnakSekolah ? cfAnakSekolah : 0.0,
        terpenuhi: data.adaAnakSekolah,
      ),
    ];

    return HasilAnalisis(
      cfSembako: cfSembako.clamp(0.0, 1.0),
      cfPKH: cfPKH.clamp(0.0, 1.0),
      cfGabungan: cfGabungan,
      layak: layak,
      blacklisted: false,
      rekomendasiUtama: rekomendasi,
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