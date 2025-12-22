import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends GetxService {
  late final Dio dio;
  final storage = const FlutterSecureStorage();

  final RxBool isLoggedIn = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rxn<UserModel> _currentUser = Rxn<UserModel>();

  UserModel? get currentUser => _currentUser.value;
  String get errorMessage => _errorMessage.value.isEmpty
      ? 'An unknown error occurred'
      : _errorMessage.value;
  set errorMessage(String? msg) => _errorMessage.value = msg?.trim() ?? '';

  void setCurrentUser(UserModel user) {
    _currentUser.value = user;
  }

  @override
  Future<AuthService> init() async {
    dio = Get.find<ApiService>().dio;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    final token = await storage.read(key: 'access_token');
    final userJson = await storage.read(key: 'current_user');
    if (userJson != null) {
      _currentUser.value = UserModel.fromJson(jsonDecode(userJson));
    }
    isLoggedIn.value = token != null && token.isNotEmpty;
    return this;
  }

  Future<bool> login(
      {required String username, required String password}) async {
    errorMessage = '';
    try {
      final response = await dio.post('/api/android/user/login',
          data: {"username": username.trim(), "password": password});
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        setCurrentUser(user);
        await storage.write(
            key: 'access_token', value: data['accessToken'] as String?);
        await storage.write(
            key: 'refresh_token', value: data['refreshToken'] as String?);
        await storage.write(
            key: 'current_user', value: jsonEncode(user.toJson()));
        isLoggedIn.value = true;
        errorMessage = '';
        return true;
      } else {
        errorMessage = response.data['error'] ?? 'Login failed';
        return false;
      }
    } on DioException catch (e) {
      String msg = 'Login failed';
      if (e.response?.data is Map && e.response!.data['error'] != null) {
        msg = e.response!.data['error'];
      } else if (e.message != null) {
        msg = e.message!;
      }
      errorMessage = msg;
      return false;
    } catch (e) {
      errorMessage = 'Unexpected error. Please try again.';
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String name,
    required String email,
    String? phone,
    String? role,
    String? club, // if you add club later
  }) async {
    errorMessage = '';
    try {
      final response = await dio.post(
        '/api/android/user/register',
        data: {
          "username": username.trim(),
          "password": password,
          "name": name.trim(),
          "email": email.trim(),
          if (phone != null && phone.isNotEmpty) "phone": phone.trim(),
          if (role != null) "role": role,
          // if (club != null) "club": club,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        // Do NOT auto-login → do NOT save token or user
        return true;
      } else {
        errorMessage = response.data['error'] ?? 'Registration failed';
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['error'] != null) {
        errorMessage = e.response!.data['error'] as String;
      } else if (e.message != null) {
        errorMessage = e.message!;
      } else {
        errorMessage = 'Network error. Check your connection.';
      }
      return false;
    } catch (e) {
      errorMessage = 'Unexpected error during registration';
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await dio
          .post('/api/android/user/logout')
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
    await storage.deleteAll();
    isLoggedIn.value = false;
    _currentUser.value = null;
    errorMessage = '';
    return true;
  }
}
