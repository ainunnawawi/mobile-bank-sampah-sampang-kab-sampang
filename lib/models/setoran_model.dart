class SetoranModel {
  final int id;
  final String nomorTransaksi;
  final String tglSetoran;
  final String berat;
  final String hargaPerKg;
  final String nilaiSetoran;
  final String status;
  final String? keterangan;

  SetoranModel({
    required this.id,
    required this.nomorTransaksi,
    required this.tglSetoran,
    required this.berat,
    required this.hargaPerKg,
    required this.nilaiSetoran,
    required this.status,
    this.keterangan,
  });

  factory SetoranModel.fromJson(Map<String, dynamic> json) {
    return SetoranModel(
      id: json['id'] ?? 0,
      nomorTransaksi: json['nomor_transaksi'] ?? '',
      tglSetoran: json['tgl_setoran'] ?? '',
      berat: json['berat'] ?? '0',
      hargaPerKg: json['harga_per_kg'] ?? '0',
      nilaiSetoran: json['nilai_setoran'] ?? '0',
      status: json['status'] ?? '',
      keterangan: json['keterangan'],
    );
  }
}