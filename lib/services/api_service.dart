import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/nasabah_model.dart';
import '../models/setoran_model.dart';

class ApiService {
  // Catatan URL:
  // - Chrome Web: 'http://127.0.0.1:8000/api'
  // - Android Emulator: 'http://10.0.2.2:8000/api'
  // - HP Fisik: 'http://IP_LAPTOP_KAMU:8000/api'
  // Ganti URL lama menjadi link Ngrok terbaru dari temanmu:
  static const String baseUrl = "http://187.77.112.45:4001/api";
  static const _storage = FlutterSecureStorage();

  // Helper Ambil Bearer Token Sanctum
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
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
          'device_name': 'flutter_mobile_app',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token ke storage HP
        await _storage.write(key: 'auth_token', value: data['token']);
        final user = UserModel.fromJson(data['user']);
        return {'success': true, 'user': user, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal. Periksa kembali email dan password.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi server: $e'};
    }
  }

// 2. API REGISTER
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
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
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': 'flutter_mobile_app',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika server langsung memberikan token, simpan ke FlutterSecureStorage
        if (data['token'] != null) {
          await _storage.write(key: 'auth_token', value: data['token']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      } else {
        // Menampilkan pesan error dari validasi Laravel
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

  // 3. API Kirim Link Email Verifikasi
  static Future<Map<String, dynamic>> kirimVerifikasiEmail({
    required String nama,
    required String email,
    required String noHp,
  }) async {
    // SIMULASI SEMENTARA (Hapus jika API backend Laravel sudah dibuat)
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Email verifikasi berhasil dikirim (Simulasi)',
    };
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/register/kirim-verifikasi'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'nama': nama,
  //         'email': email,
  //         'no_hp': noHp,
  //       }),
  //     );

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return {
  //         'success': true,
  //         'message': data['message'] ?? 'Email verifikasi berhasil dikirim',
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': data['message'] ?? 'Gagal mengirim verifikasi',
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': 'Terjadi kesalahan koneksi: $e',
  //     };
  //   }
  }

  // 4. API Simpan Password Baru (Registrasi Selesai)
  static Future<Map<String, dynamic>> setPasswordRegister({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    // SIMULASI SEMENTARA (Kembalikan ke http.post jika rute Laravel sudah dibuat)
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Password berhasil disimpan (Simulasi)',
    };
    // try {
    //   final response = await http.post(
    //     Uri.parse('$baseUrl/register/set-password'),
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Accept': 'application/json',
    //     },
    //     body: jsonEncode({
    //       'email': email,
    //       'token': token,
    //       'password': password,
    //       'password_confirmation': passwordConfirmation,
    //     }),
    //   );

    //   final data = jsonDecode(response.body);

    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     return {
    //       'success': true,
    //       'message': data['message'] ?? 'Password berhasil dibuat',
    //     };
    //   } else {
    //     return {
    //       'success': false,
    //       'message': data['message'] ?? 'Gagal menyimpan password',
    //     };
    //   }
    // } catch (e) {
    //   return {
    //     'success': false,
    //     'message': 'Terjadi kesalahan koneksi: $e',
    //   };
    // }
  }

  // 5.Kirim email penanganan lupa password
  static Future<Map<String, dynamic>> kirimResetPasswordEmail({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/email'),
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

  // 6.Submit simpan password baru
  static Future<Map<String, dynamic>> submitPasswordBaru({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/reset'),
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
        return NasabahModel.fromJson(body['data']);
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
        List listData = body['data'];
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
    required String metodePenarikan, // 'tunai' atau 'transfer'
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
          if (namaBankEwallet != null) 'nama_bank_ewallet': namaBankEwallet,
          if (nomorTujuan != null) 'nomor_tujuan': nomorTujuan,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mengajukan penarikan.'};
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
      return true;
    } catch (e) {
      await _storage.delete(key: 'auth_token');
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
  static Future<List<dynamic>> getRiwayatPenarikan() async {
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
        return body['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // static Future<List<dynamic>> getPenarikan() async {
  //   try {
  //     final token = await _storage.read(key: 'auth_token');

  //     final response = await http.get(
  //       Uri.parse('$baseUrl/penarikan'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final body = jsonDecode(response.body);
  //       if (body['status'] == 'success' && body['data'] != null) {
  //         return body['data'] as List<dynamic>;
  //       }
  //     }
  //     return [];
  //   } catch (e) {
  //     print('Error getPenarikan: $e');
  //     return [];
  //   }
  // }
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
        
        // Debugging untuk mengecek struktur response di terminal
        print('Response Get Penarikan: $body');

        // Jika response berupa List langsung: [ {...}, {...} ]
        if (body is List) {
          return body;
        }

        // Jika response dibungkus key "data": { "data": [ {...} ] }
        if (body is Map<String, dynamic> && body.containsKey('data')) {
          return body['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print('Error getPenarikan: $e');
      return [];
    }
  }

  // 12. API UPDATE PROFIL NASABAH
  static Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String noHp,
    String? alamat,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/nasabah/update'), // sesuaikan rute backend Laravel
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nama': nama,
          'no_hp': noHp,
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

  // 13. API Ubah Password saat Login
  static Future<Map<String, dynamic>> ubahPasswordProfile({
    required String passwordLama,
    required String passwordBaru,
    required String konfirmasiPassword,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/password/change'), // sesuaikan rute backend Laravel
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

  static Future<Map<String, dynamic>> ajukanSetoran({
    required String jenisSampah,
    required double estimasiBerat,
    String? catatan,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/setoran/ajukan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'jenis_sampah': jenisSampah,
          'estimasi_berat': estimasiBerat,
          'catatan': catatan,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Pengajuan setoran berhasil dikirim',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}