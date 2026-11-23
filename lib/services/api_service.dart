import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/nasabah_model.dart';
import '../models/setoran_model.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = "http://187.77.112.45:4001/api";
  static const _storage = FlutterSecureStorage();

  // Helper Ambil Bearer Token Sanctum
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Helper Cek Session Aktif (Default 7 hari)
  static Future<bool> isSessionValid({int maxDays = 7}) async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    final tsString = await _storage.read(key: 'login_timestamp');
    if (tsString == null) return true;

    final loginTime = DateTime.fromMillisecondsSinceEpoch(int.parse(tsString));
    final diff = DateTime.now().difference(loginTime);

    if (diff.inDays >= maxDays) {
      await logout();
      return false;
    }
    return true;
  }

  // 1. API LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': 'Flutter',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'auth_token', value: data['token']);
        await _storage.write(
          key: 'login_timestamp',
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        final user = UserModel.fromJson(data['user']);
        return {'success': true, 'user': user, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ??
              'Login gagal. Periksa kembali email dan password.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi server: $e',
      };
    }
  }

  // 2. API REGISTER
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    String? noHp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          if (noHp != null && noHp.isNotEmpty) 'no_hp': noHp,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': 'Flutter',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['token'] != null) {
          await _storage.write(key: 'auth_token', value: data['token']);
          await _storage.write(
            key: 'login_timestamp',
            value: DateTime.now().millisecondsSinceEpoch.toString(),
          );
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mendaftar, periksa data Anda',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi ke server',
      };
    }
  }

  // 5. Kirim email penanganan lupa password
  static Future<Map<String, dynamic>> kirimResetPasswordEmail({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Link reset password berhasil dikirim',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  // 6. Submit simpan password baru
  static Future<Map<String, dynamic>> submitPasswordBaru({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Password berhasil diperbarui',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  // 7. API PROFIL NASABAH ME
  static Future<NasabahModel?> getNasabahProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return NasabahModel.fromJson(body['data'] ?? body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 8. API RIWAYAT SETORAN
  static Future<List<SetoranModel>> getRiwayatSetoran() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/setoran'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        List listData = body is List ? body : (body['data'] ?? []);
        return listData.map((e) => SetoranModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 9. API PENARIKAN SALDO
  static Future<Map<String, dynamic>> ajukanPenarikan({
    required double nominal,
    required String metodePenarikan,
    String? namaBankEwallet,
    String? nomorTujuan,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/penarikan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nominal': nominal,
          'metode_penarikan': metodePenarikan,
          'nama_bank_ewallet': namaBankEwallet,
          'nomor_tujuan': nomorTujuan,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Pengajuan penarikan berhasil dikirim.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengajukan penarikan.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }

  // 10. API LOGOUT
  static Future<bool> logout() async {
    try {
      final token = await getToken();
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'login_timestamp');
      return true;
    } catch (e) {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'login_timestamp');
      return false;
    }
  }

  // 11. API GET PENCAPAIAN / RANKING
  static Future<List<dynamic>> getPencapaian() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/pencapaian'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 12. API GET RIWAYAT PENARIKAN
  static Future<List<dynamic>> getPenarikan() async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/penarikan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List) {
          return body;
        }

        if (body is Map<String, dynamic> && body.containsKey('data')) {
          return body['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 13. API UPDATE PROFIL NASABAH
  static Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String noHp,
    String? email,
    String? alamat,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/nasabah/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nama': nama,
          'no_hp': noHp,
          if (email != null && email.isNotEmpty) 'email': email,
          'alamat': alamat,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Profil berhasil diperbarui',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 14. API Ubah Password saat Login
  static Future<Map<String, dynamic>> ubahPasswordProfile({
    required String passwordLama,
    required String passwordBaru,
    required String konfirmasiPassword,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/password/change'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': passwordLama,
          'new_password': passwordBaru,
          'new_password_confirmation': konfirmasiPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Password berhasil diubah',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 15. API AJUKAN SETORAN MANDIRI (Mendukung Upload Foto Bukti)
  static Future<Map<String, dynamic>> ajukanSetoran({
    required String jenisSampah,
    required double estimasiBerat,
    String? catatan,
    XFile? fotoBukti,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/setoran/ajukan'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['jenis_sampah'] = jenisSampah;
      request.fields['estimasi_berat'] = estimasiBerat.toString();
      if (catatan != null && catatan.isNotEmpty) {
        request.fields['catatan'] = catatan;
      }

      if (fotoBukti != null) {
        final bytes = await fotoBukti.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto_bukti',
            bytes,
            filename: fotoBukti.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Pengajuan setoran berhasil dikirim',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 16. API BATALKAN PENARIKAN (Hanya saat status menunggu)
  static Future<Map<String, dynamic>> batalkanPenarikan({
    required int idPenarikan,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/penarikan/$idPenarikan/batal'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message':
            data['message'] ?? 'Pengajuan penarikan berhasil dibatalkan.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 17. API KIRIM LINK VERIFIKASI EMAIL (Setelah Login dari Dashboard)
  static Future<Map<String, dynamic>> kirimLinkVerifikasiDashboard() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/email/kirim-verifikasi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message':
            data['message'] ?? 'Link verifikasi telah dikirim ke email Anda.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 18. API VERIFIKASI TOKEN EMAIL (Dipanggil saat Deep Link dibuka)
  static Future<Map<String, dynamic>> verifikasiEmailToken({
    required String email,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/email/verifikasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'token': token}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Email berhasil diverifikasi.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 19. API UPLOAD FOTO PROFIL
  static Future<Map<String, dynamic>> uploadFotoProfil(XFile foto) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/nasabah/foto-profil'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      final bytes = await foto.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('foto_profil', bytes, filename: foto.name),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Foto profil berhasil diperbarui',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}
