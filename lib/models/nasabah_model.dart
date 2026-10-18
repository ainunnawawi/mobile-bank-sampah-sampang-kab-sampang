class NasabahModel {
  final int id;
  final String nama;
  final String? noTelp;
  final String? alamat;
  final String saldo;

  NasabahModel({
    required this.id,
    required this.nama,
    this.noTelp,
    this.alamat,
    required this.saldo,
  });

  factory NasabahModel.fromJson(Map<String, dynamic> json) {
    return NasabahModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      noTelp: json['no_telp'],
      alamat: json['alamat'],
      saldo: json['saldo'] ?? '0',
    );
  }
}