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

  // 3. API PROFIL NASABAH ME
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

  // 5. API RIWAYAT SETORAN
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

  // 4. API PENARIKAN SALDO
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

  // 5. API LOGOUT
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

  // 6. API GET PENCAPAIAN / RANKING
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
}