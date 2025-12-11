import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // PASTIKAN URL INI BENAR DAN SERVER BERJALAN!
  static const String baseUrl = 'http://36.88.99.179:8000/api/';

  // Login method
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await Dio().post(
        "${baseUrl}auth/login",
        data: {'email': email, 'password': password, 'role': 1},
      );
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await Dio().post("${baseUrl}auth/register", data: data);
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Absensi method
  static Future<Map<String, dynamic>> submitAbsen({
    required int idKrsDetail,
    required double latitude,
    required double longitude,
    required String token,
  }) async {
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      
      // PASTIKAN ENDPOINT INI COCOK DENGAN BACKEND ANDA!
      final response = await dio.post(
        "${baseUrl}krs/absen", 
        data: {
          'id_krs_detail': idKrsDetail,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
         return {'error': true, 'message': e.response!.data['message'] ?? 'Error dari server'};
      }
      return {'error': true, 'message': 'Koneksi gagal atau server tidak merespons'};
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  // Simpan Token
  static Future<void> saveToken(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_email', email);
  }

  // get Token
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null ? jsonDecode(token) : null;
  }

  // logout method
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('email');
  }
}