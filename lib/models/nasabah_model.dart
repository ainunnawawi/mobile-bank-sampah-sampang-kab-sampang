class NasabahModel {
  final int id;
  final String nama;
  final String? email;
  final String? noTelp;
  final String? alamat;
  final String saldo;
  final String? fotoProfil;
  final bool isVerified;

  NasabahModel({
    required this.id,
    required this.nama,
    this.email,
    this.noTelp,
    this.alamat,
    required this.saldo,
    this.fotoProfil,
    this.isVerified = false,
  });

  factory NasabahModel.fromJson(Map<String, dynamic> json) {
    final bool verifiedStatus = json['is_verified'] == true ||
        json['is_verified'] == 1 ||
        json['email_verified_at'] != null;

    String? rawFoto = json['foto_profil']?.toString();
    if (rawFoto != null && rawFoto.isNotEmpty && !rawFoto.startsWith('http')) {
      rawFoto = 'http://187.77.112.45:4001/storage/$rawFoto';
    }

    return NasabahModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'],
      noTelp: json['no_telp'] ?? json['no_hp'],
      alamat: json['alamat'],
      fotoProfil: rawFoto,
      saldo: json['saldo']?.toString() ?? '0',
      isVerified: verifiedStatus,
    );
  }
}