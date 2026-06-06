class WargaModel {
  // Identitas
  final String namaLengkap;
  final String nik;
  final String kecamatan;

  // Sosial Ekonomi
  final double pendapatanBulanan;
  final int jumlahTanggungan;
  final String pekerjaanUtama;
  final bool isASNTNIPolri; // blacklist otomatis tidak layak

  // Kondisi Rumah & Aset
  final String kondisiRumah;
  final String statusLahan;
  final bool punyaTernak;
  final bool punyaTabunganEmas;
  final bool punyaKendaraanLebihSatu;

  // Kondisi Khusus PKH
  final bool adaDisabilitas;
  final bool adaLansia;
  final bool adaIbuHamil;
  final bool adaBalita;
  final bool adaAnakSekolah;

  WargaModel({
    required this.namaLengkap,
    required this.nik,
    required this.kecamatan,
    required this.pendapatanBulanan,
    required this.jumlahTanggungan,
    required this.pekerjaanUtama,
    required this.isASNTNIPolri,
    required this.kondisiRumah,
    required this.statusLahan,
    required this.punyaTernak,
    required this.punyaTabunganEmas,
    required this.punyaKendaraanLebihSatu,
    required this.adaDisabilitas,
    required this.adaLansia,
    required this.adaIbuHamil,
    required this.adaBalita,
    required this.adaAnakSekolah,
  });
}