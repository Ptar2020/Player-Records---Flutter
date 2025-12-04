// lib/services/api_service.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../models/player.dart';
import '../models/club_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class AuthInterceptor extends Interceptor {
  final ApiService api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthInterceptor(this.api);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // Only process 401s
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) {
      _forceLogout(handler, err);
      return;
    }

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: api.baseUrl));
      final res = await refreshDio.post('/api/android/user/getRefreshToken', data: {'refreshToken': refreshToken});

      if (res.data != null && res.data['success'] == true) {
        final newToken = res.data['data']['accessToken'] as String?;
        final newRefresh = res.data['data']['refreshToken'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await _storage.write(key: 'access_token', value: newToken);
          if (newRefresh != null && newRefresh.isNotEmpty) {
            await _storage.write(key: 'refresh_token', value: newRefresh);
          }

          // retry original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          final cloned = await refreshDio.fetch(opts); // retry with refreshDio to reuse baseUrl/timeouts
          return handler.resolve(cloned);
        }
      }
    } catch (_) {
      // ignore and fallthrough to logout
    }

    _forceLogout(handler, err);
  }

  void _forceLogout(ErrorInterceptorHandler handler, DioError err) {
    try {
      Get.find<AuthService>().logout();
    } catch (_) {}
    _storage.deleteAll();
    handler.next(err);
  }
}

class ApiService extends GetxService {
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @override
  Future<ApiService> init() async {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ));

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';

    dio.interceptors.add(AuthInterceptor(this));

    return this;
  }

  // PLAYERS
  Future<List<PlayerInClub>> getAllPlayers() async {
    final r = await dio.get('/api/android/player');
    final List data = r.data['data'] ?? [];
    return data.map((e) => PlayerInClub.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Player> getPlayerWithClub(String playerId) async {
    final r = await dio.get('/api/android/player/$playerId');
    final data = r.data['data'];
    final playerJson = (data['player'] as Map<String, dynamic>);
    final clubJson = data['club'] as Map<String, dynamic>?;
    final playerInClub = PlayerInClub.fromJson(playerJson);
    final club = clubJson != null ? ClubModel.fromJson(clubJson) : null;
    return Player.fromPlayerInClub(playerInClub, club: club);
  }

  // CLUBS
  Future<List<ClubModel>> getAllClubs() async {
    final r = await dio.get('/api/android/club');
    final List data = r.data['data'] ?? [];
    return data.map((e) => ClubModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ClubModel> getClubDetailsByName(String clubName) async {
    final encoded = Uri.encodeComponent(clubName);
    final r = await dio.get('/api/android/club/$encoded');
    return ClubModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  // USERS
  Future<List<UserModel>> getAllUsers() async {
    final r = await dio.get('/api/android/user');
    final List data = r.data['data'] ?? [];
    return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final r = await dio.patch('/api/android/user/$id', data: updates);
      if (r.data['success'] == true) {
        return UserModel.fromJson(r.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(r.data['error'] ?? 'Failed to update user');
      }
    } on DioError catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['error'] ?? 'Failed to update user' : 'Network error';
      throw Exception(msg);
    }
  }
}

// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';

// import '../models/player.dart';
// import '../models/club_model.dart';
// import '../models/user_model.dart';
// import 'auth_service.dart';


// // ===========================================================
// //                    AUTH INTERCEPTOR
// // ===========================================================
// class AuthInterceptor extends Interceptor {
//   final ApiService api;

//   AuthInterceptor(this.api);

//   final FlutterSecureStorage _storage = const FlutterSecureStorage(
//     aOptions: AndroidOptions(encryptedSharedPreferences: true),
//   );

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     final token = await _storage.read(key: 'access_token');

//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }

//     options.headers['Content-Type'] = 'application/json';
//     options.headers['Accept'] = 'application/json';

//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode != 401) {
//       return handler.next(err);
//     }

//     final refreshToken = await _storage.read(key: 'refresh_token');
//     if (refreshToken == null) {
//       return _forceLogout(handler, err);
//     }

//     try {
//       final refreshDio = Dio(BaseOptions(baseUrl: api.baseUrl));

//       final res = await refreshDio.post(
//         '/api/android/user/getRefreshToken',
//         data: {'refreshToken': refreshToken},
//       );

//       if (res.data['success'] == true) {
//         final newToken = res.data['data']['accessToken'];
//         final newRefresh = res.data['data']['refreshToken'];

//         await _storage.write(key: 'access_token', value: newToken);
//         if (newRefresh != null) {
//           await _storage.write(key: 'refresh_token', value: newRefresh);
//         }

//         // Retry the failed request with new token
//         err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
//         final retry = await Dio().fetch(err.requestOptions);
//         return handler.resolve(retry);
//       }
//     } catch (_) {}

//     _forceLogout(handler, err);
//   }

//   void _forceLogout(ErrorInterceptorHandler handler, DioException err) {
//     Get.find<AuthService>().logout();
//     _storage.deleteAll();
//     handler.next(err);
//   }
// }


// // ===========================================================
// //                        API SERVICE
// // ===========================================================
// class ApiService extends GetxService {
//   late final Dio dio;

//   String get baseUrl => dotenv.env['BASE_URL']!;

//   @override
//   Future<ApiService> init() async {
//     dio = Dio(BaseOptions(
//       baseUrl:  baseUrl,
//       connectTimeout: const Duration(seconds: 12),
//       receiveTimeout: const Duration(seconds: 12),
//     ));

//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';

//     dio.interceptors.add(AuthInterceptor(this));

//     return this;
//   }

//   // ===========================================================
//   //                        PLAYERS
//   // ===========================================================
//   Future<List<PlayerInClub>> getAllPlayers() async {
//     final r = await dio.get('/api/android/player');
//     final List data = r.data['data'] ?? [];
//     return data.map((e) => PlayerInClub.fromJson(e as Map<String, dynamic>)).toList();
//   }

// // Add this inside ApiService class
// Future<Player> getPlayerWithClub(String playerId) async {
//   final r = await dio.get('/api/android/player/$playerId');
//   final data = r.data['data'];
//   final playerInClub = PlayerInClub.fromJson(data['player'] as Map<String, dynamic>);
//   final clubJson = data['club'] as Map<String, dynamic>?;
//   final club = clubJson != null ? ClubModel.fromJson(clubJson) : null;
//   return Player.fromPlayerInClub(playerInClub, club: club);
// }
//   // ===========================================================
//   //                        CLUBS
//   // ===========================================================
//   Future<List<ClubModel>> getAllClubs() async {
//     final r = await dio.get('/api/android/club');
//     final List data = r.data['data'] ?? [];
//     return data.map((e) => ClubModel.fromJson(e as Map<String, dynamic>)).toList();
//   }

//   Future<ClubModel> getClubDetailsByName(String clubName) async {
//     final encoded = Uri.encodeComponent(clubName);
//     final r = await dio.get('/api/android/club/$encoded');
//     return ClubModel.fromJson(r.data['data'] as Map<String, dynamic>);
//   }

//   // ===========================================================
//   //                        USERS
//   // ===========================================================
//   Future<List<UserModel>> getAllUsers() async {
//     final r = await dio.get('/api/android/user');
//     final List data = r.data['data'] ?? [];
//     return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
//   }

//   Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
//     try {
//       final r = await dio.patch('/api/android/user/$id', data: updates);

//       if (r.data['success'] == true) {
//         return UserModel.fromJson(r.data['data'] as Map<String, dynamic>);
//       } else {
//         throw Exception(r.data['error'] ?? 'Failed to update user');
//       }
//     } on DioException catch (e) {
//       final msg = e.response?.data is Map
//           ? e.response?.data['error'] ?? 'Failed to update user'
//           : 'Network error';
//       throw Exception(msg);
//     }
//   }
// }














// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';

// import '../models/player.dart';
// import '../models/club_model.dart';
// import '../models/user_model.dart';
// import 'auth_service.dart';


// // ===========================================================
// //                    AUTH INTERCEPTOR
// // ===========================================================
// class AuthInterceptor extends Interceptor {
//   final ApiService api;

//   AuthInterceptor(this.api);

//   final FlutterSecureStorage _storage = const FlutterSecureStorage(
//     aOptions: AndroidOptions(encryptedSharedPreferences: true),
//   );

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     final token = await _storage.read(key: 'access_token');

//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }

//     options.headers['Content-Type'] = 'application/json';
//     options.headers['Accept'] = 'application/json';

//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     // If NOT 401 → return normal error
//     if (err.response?.statusCode != 401) {
//       return handler.next(err);
//     }

//     final refreshToken = await _storage.read(key: 'refresh_token');
//     if (refreshToken == null) {
//       return _forceLogout(handler, err);
//     }

//     try {
//       final refreshDio = Dio(BaseOptions(baseUrl: api.baseUrl));

//       final res = await refreshDio.post(
//         '/api/android/user/getRefreshToken',
//         data: {'refreshToken': refreshToken},
//       );

//       if (res.data['success'] == true) {
//         final newToken = res.data['data']['accessToken'];
//         final newRefresh = res.data['data']['refreshToken'];

//         await _storage.write(key: 'access_token', value: newToken);
//         if (newRefresh != null) {
//           await _storage.write(key: 'refresh_token', value: newRefresh);
//         }

//         // Retry the failed request with new token
//         err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
//         final retry = await Dio().fetch(err.requestOptions);
//         return handler.resolve(retry);
//       }
//     } catch (_) {}

//     // If refresh fails → logout
//     _forceLogout(handler, err);
//   }

//   void _forceLogout(ErrorInterceptorHandler handler, DioException err) {
//     Get.find<AuthService>().logout();
//     _storage.deleteAll();
//     handler.next(err);
//   }
// }



// // ===========================================================
// //                        API SERVICE
// // ===========================================================
// class ApiService extends GetxService {
//   late final Dio dio;

//   /// BASE URL from `.env`
//   String get baseUrl => dotenv.env['BASE_URL']!;

//   @override
//   Future<ApiService> init() async {
//     dio = Dio(BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 12),
//       receiveTimeout: const Duration(seconds: 12),
//     ));

//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';

//     dio.interceptors.add(AuthInterceptor(this));

//     return this;
//   }

//   // ===========================================================
//   //                        PLAYERS
//   // ===========================================================
//   Future<List<Player>> getAllPlayers() async {
//     final r = await dio.get('/api/android/player');
//     final List data = r.data['data'] ?? [];
//     return data.map((e) => Player.fromJson(e)).toList();
//   }


//   // ===========================================================
//   //                        CLUBS
//   // ===========================================================
//   Future<List<ClubModel>> getAllClubs() async {
//     final r = await dio.get('/api/android/club');
//     final List data = r.data['data'] ?? [];
//     return data.map((e) => ClubModel.fromJson(e)).toList();
//   }


//   Future<ClubModel> getClubDetailsByName(String clubName) async {
//     final encoded = Uri.encodeComponent(clubName);
//     final r = await dio.get('/api/android/club/$encoded');
//     return ClubModel.fromJson(r.data['data']);
//   }


//   // ===========================================================
//   //                        USERS
//   // ===========================================================
//   Future<List<UserModel>> getAllUsers() async {
//     final r = await dio.get('/api/android/user');
//     final List data = r.data['data'] ?? [];
//     return data.map((e) => UserModel.fromJson(e)).toList();
//   }


//   // ======================= UPDATE USER ========================
//   Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
//     try {
//       final r = await dio.patch('/api/android/user/$id', data: updates);

//       if (r.data['success'] == true) {
//         return UserModel.fromJson(r.data['data']);
//       } else {
//         throw Exception(r.data['error'] ?? 'Failed to update user');
//       }
//     } on DioException catch (e) {
//       final msg = e.response?.data is Map
//           ? e.response?.data['error'] ?? 'Failed to update user'
//           : 'Network error';
//       throw Exception(msg);
//     }
//   }
// }
















// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import '../models/player.dart';
// import '../models/club_model.dart';
// import '../models/user_model.dart';
// import 'auth_service.dart';

// // ========================== AUTH INTERCEPTOR (MUST BE OUTSIDE THE CLASS) ==========================
// class AuthInterceptor extends Interceptor {
//   final ApiService apiService;

//   AuthInterceptor(this.apiService);

//   final FlutterSecureStorage _storage = const FlutterSecureStorage(
//     aOptions: AndroidOptions(encryptedSharedPreferences: true),
//   );

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     final token = await _storage.read(key: 'access_token');
//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//     options.headers['Content-Type'] = 'application/json';
//     options.headers['Accept'] = 'application/json';
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode != 401) {
//       return handler.next(err);
//     }

//     final refreshToken = await _storage.read(key: 'refresh_token');
//     if (refreshToken == null) {
//       return _logoutAndRedirect(handler, err);
//     }

//     try {
//       final refreshDio = Dio(BaseOptions(baseUrl: apiService.baseUrl));
//       final res = await refreshDio.post(
//         '/api/android/user/getRefreshToken',
//         data: {'refreshToken': refreshToken},
//       );

//       if (res.data['success'] == true) {
//         final newToken = res.data['data']['accessToken'];
//         final newRefresh = res.data['data']['refreshToken'];

//         await _storage.write(key: 'access_token', value: newToken);
//         if (newRefresh != null) {
//           await _storage.write(key: 'refresh_token', value: newRefresh);
//         }

//         err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
//         final cloneReq = await Dio().fetch(err.requestOptions);
//         return handler.resolve(cloneReq);
//       }
//     } catch (_) {
//       // Ignore refresh errors
//     }

//     _logoutAndRedirect(handler, err);
//   }

//   void _logoutAndRedirect(ErrorInterceptorHandler handler, DioException err) {
//     Get.find<AuthService>().logout(); // or set isLoggedIn.value = false
//     _storage.deleteAll();
//     handler.next(err);
//   }
// }

// // ========================== MAIN API SERVICE =======R===================
// class ApiService extends GetxService {
//   late final Dio dio;
//   static final String _baseUrl = dotenv.env['BASE_URL'];
//   // final String baseUrl = 'http://192.168.130.97:3000';

//   @override
//   Future<ApiService> init() async {
//     dio = Dio(BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 12),
//       receiveTimeout: const Duration(seconds: 12),
//     ));

//     // THIS FIXES YOUR "Unexpected end of JSON input" FOREVER
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';

//     dio.interceptors.add(AuthInterceptor(this));
//     return this;
//   }

//   // ========================== GET ALL PLAYERS ==========================
//   Future<List<Player>> getAllPlayers() async {
//     final response = await dio.get('/api/android/player');
//     final List data = response.data['data'] ?? [];
//     return data.map((json) => Player.fromJson(json)).toList();
//   }

//   // ========================== GET ALL CLUBS ==========================
//   Future<List<ClubModel>> getAllClubs() async {
//     final response = await dio.get('/api/android/club');
//     final List data = response.data['data'] ?? [];
//     return data.map((json) => ClubModel.fromJson(json)).toList();
//   }

//   // ========================== GET CLUB DETAILS ==========================
//   Future<ClubModel> getClubDetailsByName(String clubName) async {
//     final encodedName = Uri.encodeComponent(clubName);
//     final response = await dio.get('/api/android/club/$encodedName');
//     return ClubModel.fromJson(response.data['data']);
//   }

//   // ========================== GET ALL USERS ==========================
//   Future<List<UserModel>> getAllUsers() async {
//     final response = await dio.get('/api/android/user');
//     final List data = response.data['data'] ?? [];
//     return data.map((json) => UserModel.fromJson(json)).toList();
//   }

//   // ========================== UPDATE USER (NOW WORKS 100%) ==========================
//   Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
//     try {
//       final response = await dio.patch(
//         '/api/android/user/$id',
//         data: updates,
//       );

//       if (response.data['success'] == true) {
//         return UserModel.fromJson(response.data['data']);
//       } else {
//         throw Exception(response.data['error'] ?? 'Failed to update user');
//       }
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data is Map
//           ? e.response!.data['error'] ?? 'Failed to update user'
//           : e.response?.data?.toString() ?? 'Network error';
//       throw Exception(errorMsg);
//     }
//   }
// }


// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import '../models/player.dart';
// import '../models/club_model.dart';
// import '../models/user_model.dart';
// import 'auth_service.dart';

// class ApiService extends GetxService {
//   late final Dio dio;
//   final FlutterSecureStorage storage = const FlutterSecureStorage(
//     aOptions: AndroidOptions(encryptedSharedPreferences: true),
//   );

//   final String baseUrl = 'http://192.168.130.97:3000';

//   @override
//   Future<ApiService> init() async {
//     dio = Dio();
//     dio.options.baseUrl = baseUrl;
//     dio.options.connectTimeout = const Duration(seconds: 12);
//     dio.options.receiveTimeout = const Duration(seconds: 12);

//     dio.interceptors.add(AuthInterceptor(this));
//     return this;
//   }

//   // ==========================GET ALL PLAYERS ==========================
//   Future<List<Player>> getAllPlayers() async {
//     try {
//       final response = await dio.get('/api/android/player');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => Player.fromJson(json)).toList();
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['error'] ?? 'Failed to load players');
//     }
//   }

//   // ==========================GET ALL CLUBS ==========================
//   Future<List<ClubModel>> getAllClubs() async {
//     try {
//       final response = await dio.get('/api/android/club');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => ClubModel.fromJson(json)).toList();
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['error'] ?? 'Failed to load clubs');
//     }
//   }

//   // ==========================GET C CLUB DETAILS ==========================
//   Future<ClubModel> getClubDetailsByName(String clubName) async {
//     try {
//       final encodedName = Uri.encodeComponent(clubName);
//       final response = await dio.get('/api/android/club/$encodedName');
//       return ClubModel.fromJson(response.data['data']);
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['error'] ?? 'Failed to load club details');
//     }
//   }

//   // ==========================GET ALL USERS ==========================
//   Future<List<UserModel>> getAllUsers() async {
//     try {
//       final response = await dio.get('/api/android/user');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => UserModel.fromJson(json)).toList();
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['error'] ?? 'Failed to load users');
//     }
//   }

// ==========================UPDATE USER ==========================

//   Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
//     try {
//       final response = await dio.patch(
//         '/api/android/user/$id',
//         data: updates,
//       );
//       if (response.data['success'] == true) {
//         return UserModel.fromJson(response.data['data']);
//       } else {
//         throw Exception(response.data['error'] ?? 'Failed to update user');
//       }
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['error'] ?? 'Failed to update user');
//     }
//   }
// }

// // ========================== AUTH INTERCEPTOR ==========================
// class AuthInterceptor extends Interceptor {
//   final ApiService apiService;
//   AuthInterceptor(this.apiService);

//   FlutterSecureStorage get _storage => apiService.storage;

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     final token = await _storage.read(key: 'access_token');
//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//     options.headers['Content-Type'] = 'application/json';
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode != 401) return handler.next(err);

//     final refreshToken = await _storage.read(key: 'refresh_token');
//     if (refreshToken == null) return _logoutAndRedirect(handler, err);

//     try {
//       final refreshDio = Dio();
//       final res = await refreshDio.post(
//         '${apiService.baseUrl}/api/android/user/getRefreshToken',
//         data: {'refreshToken': refreshToken},
//       );
//       if (res.data['success'] == true) {
//         final newToken = res.data['data']['accessToken'];
//         final newRefresh = res.data['data']['refreshToken'];
//         await _storage.write(key: 'access_token', value: newToken);
//         if (newRefresh != null) {
//           await _storage.write(key: 'refresh_token', value: newRefresh);
//         }
//         err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
//         final clone = await Dio().fetch(err.requestOptions);
//         return handler.resolve(clone);
//       }
//     } catch (_) {}
//     _logoutAndRedirect(handler, err);
//   }

//   void _logoutAndRedirect(ErrorInterceptorHandler handler, DioException err) {
//     Get.find<AuthService>().isLoggedIn.value = false;
//     _storage.deleteAll();
//     handler.next(err);
//   }
// }


// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import '../models/player.dart';
// import '../models/club_model.dart';
// import '../models/user_model.dart';
// import 'auth_service.dart';

// class ApiService extends GetxService {
//   late final Dio dio;

//   final FlutterSecureStorage storage = const FlutterSecureStorage(
//     aOptions: AndroidOptions(encryptedSharedPreferences: true),
//   );

//   static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.150.97:3000';

//   @override
//   Future<ApiService> init() async {
//     dio = Dio();
//     dio.options.baseUrl = _baseUrl;
//     dio.options.connectTimeout = const Duration(seconds: 12);
//     dio.options.receiveTimeout = const Duration(seconds: 12);

//     dio.interceptors.add(AuthInterceptor());

//     return this;
//   }

//   // =================================== PLAYERS ===================================
// // In api_service.dart — REPLACE the whole getAllPlayers() method
// Future<List<Player>> getAllPlayers() async {
//   try {
//     final response = await dio.get('/api/android/player');

//     // ADD THIS DEBUG LOG — you will see it immediately
//     if (kDebugMode) {
//       print("RAW RESPONSE FROM /api/android/player:");
//       print("Status: ${response.statusCode}");
//       print("Full body: ${response.data}");
//       print("Type of response.data: ${response.data.runtimeType}");
//     }

//     // The backend returns { success: true, data: [...] }
//     if (response.data is Map && response.data['success'] == true) {
//       final List data = response.data['data'] ?? [];
//       print("SUCCESS: ${data.length} players received from backend");
//       return data.map((json) => Player.fromJson(json)).toList();
//     } else {
//       // Handle old format or direct array
//       if (response.data is List) {
//         print("WARNING: Direct array format detected — ${response.data.length} players");
//         return (response.data as List).map((json) => Player.fromJson(json)).toList();
//       }
//       throw Exception("Invalid response format");
//     }
//   } on DioException catch (e) {
//     String msg = "Network error";
//     if (e.response != null) {
//       msg = "Server error: ${e.response?.statusCode} — ${e.response?.data}";
//     } else {
//       msg = e.message ?? "Unknown Dio error";
//     }
//     print("API ERROR (getAllPlayers): $msg");
//     rethrow;
//   } catch (e) {
//     print("UNEXPECTED ERROR in getAllPlayers: $e");
//     rethrow;
//   }
// }

// //=====================FOR UPDATING A USER==============================================
// // In api_service.dart
// Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
//   try {
//     final response = await dio.patch('/api/android/user/$userId', data: updates);
//     return response.data['success'] == true;
//   } on DioException catch (e) {
//     if (kDebugMode) print("Update user error: ${e.response?.data ?? e.message}");
//     return false;
//   }
// }


//   Future<ClubModel> getClubDetailsByName(String clubName) async {
//     try {
//       final encodedName = Uri.encodeComponent(clubName);
//       final response = await dio.get('/api/android/club/$encodedName');

//       if (response.data['success'] == false) {
//         throw Exception(response.data['error'] ?? 'Club not found');
//       }
//       return ClubModel.fromJson(response.data['data']);
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data['error'] ?? 'Failed to load club';
//       throw Exception(errorMsg);
//     }
//   }

//   Future<List<ClubModel>> getAllClubs() async {
//     try {
//       final response = await dio.get('/api/android/club');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => ClubModel.fromJson(json)).toList();
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data['error'] ?? 'Failed to load clubs';
//       throw Exception(errorMsg);
//     }
//   }
  
//     // =================================== ALL USERS ===================================
//   Future<List<UserModel>> getAllUsers() async {
//     try {
//       final response = await dio.get('/api/android/user'); 

//       if (response.data['success'] == true) {
//         final List<dynamic> data = response.data['data'] ?? [];
//         return data.map((json) => UserModel.fromJson(json)).toList();
//       } else {
//         throw Exception(response.data['error'] ?? 'Failed to load users');
//       }
//     } on DioException catch (e) {
//       String msg = 'Failed to load users';

//       if (e.response?.data is Map) {
//         msg = e.response?.data['error'] ?? msg;
//       } else if (e.type == DioExceptionType.connectionTimeout ||
//                  e.type == DioExceptionType.receiveTimeout) {
//         msg = 'Connection timeout';
//       }

//       if (kDebugMode) print('GetAllUsers Error: $msg');
//       throw Exception(msg);
//     }
//   }
// }

// // ================================== AUTH INTERCEPTOR ==================================
// class AuthInterceptor extends Interceptor {
//   FlutterSecureStorage get _storage => Get.find<ApiService>().storage;

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     final token = await _storage.read(key: 'access_token');

//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';

//       if (kDebugMode) {
//         print("════════════════════════════════════════════════");
//         print("API → ${options.method} ${options.path}");
//         print("Token → ${token.substring(0, 15)}...");
//         print("Time  → ${DateTime.now().toString().substring(11, 19)}");
//         print("════════════════════════════════════════════════");
//       }
//     }

//     options.headers['Content-Type'] = 'application/json';
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode != 401) return handler.next(err);

//     final refreshToken = await _storage.read(key: 'refresh_token');
//     if (refreshToken == null) return _logoutAndRedirect(handler, err);

//     try {
//       final refreshDio = Dio();
//       final res = await refreshDio.post(
//         '${ApiService._baseUrl}/api/android/user/getRefreshToken',
//         data: {'refreshToken': refreshToken},
//       );

//       if (res.data['success'] == true) {
//         final newToken = res.data['data']['accessToken'];
//         final newRefresh = res.data['data']['refreshToken'];

//         await _storage.write(key: 'access_token', value: newToken);
//         if (newRefresh != null) {
//           await _storage.write(key: 'refresh_token', value: newRefresh);
//         }

//         err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
//         final clone = await Dio().fetch(err.requestOptions);
//         return handler.resolve(clone);
//       }
//     } catch (e) {
//       if (kDebugMode) print("Refresh failed: $e");
//     }

//     _logoutAndRedirect(handler, err);
//   }

//   void _logoutAndRedirect(ErrorInterceptorHandler handler, DioException err) {
//     Get.find<AuthService>().isLoggedIn.value = false;
//     _storage.deleteAll();

//     if (Get.currentRoute != '/login') {
//       Get.offAllNamed('/login');
//       Get.snackbar("Session Expired", "Please login again",
//           backgroundColor: Colors.red[600], colorText: Colors.white);
//     }
//     handler.next(err);
//   }
// }




// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart'; 
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'package:precords_android/models/player.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/models/user_model.dart';

// import 'auth_service.dart';

// class ApiService extends GetxService {
//   // Main HTTP client
//   final Dio dio = Dio();

//   // Shared secure storage (same instance used by AuthService)
//   final FlutterSecureStorage storage = const FlutterSecureStorage(
//     aOptions: AndroidOptions(encryptedSharedPreferences: true),
//   );

//   // Base URL from .env (fallback to local IP)
//   static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.133.97:3000';

//   ApiService() {
//     dio.options.baseUrl = _baseUrl;
//     dio.options.connectTimeout = const Duration(seconds: 12);
//     dio.options.receiveTimeout = const Duration(seconds: 12);

//     // Attach our smart interceptor with debug logs
//     dio.interceptors.add(AuthInterceptor());
//   }

//   // =================================== PLAYERS ===================================
//   Future<List<Player>> getAllPlayers() async {
//     try {
//       final response = await dio.get('/api/android/player');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => Player.fromJson(json)).toList();
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data is Map
//           ? e.response?.data['error'] ?? 'Failed to load players'
//           : 'Failed to load players';
//       throw Exception(errorMsg);
//     }
//   }

//   // =================================== CLUB BY NAME ===================================
//   Future<ClubModel> getClubDetailsByName(String clubName) async {
//     try {
//       final encodedName = Uri.encodeComponent(clubName);
//       final response = await dio.get('/api/android/club/$encodedName');

//       if (response.data['success'] == false) {
//         throw Exception(response.data['error'] ?? 'Club not found');
//       }
//       return ClubModel.fromJson(response.data['data']);
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data['error'] ?? 'Failed to load club details';
//       throw Exception(errorMsg);
//     }
//   }

//   // =================================== ALL CLUBS ===================================
//   Future<List<ClubModel>> getAllClubs() async {
//     try {
//       final response = await dio.get('/api/android/club');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => ClubModel.fromJson(json)).toList();
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data['error'] ?? 'Failed to load clubs';
//       throw Exception(errorMsg);
//     }
//   }
// }

//   // =================================== ALL USERS ===================================
//   Future<List<UserModel>> getAllUsers() async {
//     try {
//       final response = await dio.get('/api/android/user'); 

//       if (response.statusCode == 200 && response.data['success'] == true) {
//         final List<dynamic> data = response.data['data'] ?? [];
//         return data.map((json) => UserModel.fromJson(json)).toList();
//       } else {
//         throw Exception(response.data['error'] ?? 'Failed to load users');
//       }
//     } on DioException catch (e) {
//       String errorMsg = 'Failed to load users';

//       if (e.response?.data != null && e.response?.data is Map) {
//         errorMsg = e.response?.data['error'] ?? errorMsg;
//       } else if (e.type == DioExceptionType.connectionTimeout ||
//                  e.type == DioExceptionType.receiveTimeout) {
//         errorMsg = 'Connection timeout. Check your internet.';
//       } else if (e.type == DioExceptionType.badResponse) {
//         errorMsg = 'Server error: ${e.response?.statusCode}';
//       }

//       if (kDebugMode) print("GetAllUsers Error: $errorMsg");
//       throw Exception(errorMsg);
//     } catch (e) {
//       if (kDebugMode) print("Unexpected error in getAllUsers: $e");
//       throw Exception('Unexpected error occurred');
//     }
//   }

// // ================================== AUTH INTERCEPTOR ==================================
// // This runs on EVERY API call → adds token + shows debug logs + auto refresh
// class AuthInterceptor extends Interceptor {
//   // Lazy access to storage → NO MORE "ApiService not found" crash!
//   FlutterSecureStorage get _storage => Get.find<ApiService>().storage;

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     final token = await _storage.read(key: 'access_token');

//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';

//       // BEAUTIFUL DEBUG LOGS (only in debug mode)
//       if (kDebugMode) {
//         print("════════════════════════════════════════════════");
//         print("API CALL      → ${options.method} ${options.path}");
//         print("Token Sent    → ${token.substring(0, 20)}...${token.length > 10 ? token.substring(token.length - 10) : ''}");
//         print("Time          → ${DateTime.now().toString().substring(11, 19)}");
//         print("Status        → LOGGED IN");
//         print("════════════════════════════════════════════════");
//       }
//     } else {
//       if (kDebugMode) {
//         print("NO TOKEN → Calling ${options.path} (login or public route)");
//         print("Status    → NOT LOGGED IN");
//         print("────────────────────────────────────────────────");
//       }
//     }

//     options.headers['Content-Type'] = 'application/json';
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     // Handle expired token
//     if (err.response?.statusCode != 401) {
//       return handler.next(err);
//     }

//     if (kDebugMode) print("401 → Trying to refresh token...");

//     final refreshToken = await _storage.read(key: 'refresh_token');

//     if (refreshToken != null) {
//       try {
//         final refreshDio = Dio();
//         final response = await refreshDio.post(
//           '${ApiService._baseUrl}/api/android/user/getRefreshToken',
//           data: {'refreshToken': refreshToken},
//         );

//         if (response.data['success'] == true) {
//           final newAccessToken = response.data['data']['accessToken'];
//           final newRefreshToken = response.data['data']['refreshToken'];

//           await _storage.write(key: 'access_token', value: newAccessToken);
//           if (newRefreshToken != null) {
//             await _storage.write(key: 'refresh_token', value: newRefreshToken);
//           }

//           if (kDebugMode) print("TOKEN REFRESHED SUCCESSFULLY!");

//           err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
//           final clonedRequest = await Dio().fetch(err.requestOptions);
//           return handler.resolve(clonedRequest);
//         }
//       } catch (e) {
//         if (kDebugMode) print("Token refresh failed: $e");
//       }
//     }

//     // Final logout
//     if (kDebugMode) print("SESSION EXPIRED → Logging out");
//     final authService = Get.find<AuthService>();
//     authService.isLoggedIn.value = false;
//     await _storage.deleteAll();

//     if (Get.currentRoute != '/login') {
//       Get.offAllNamed('/login');
//       Get.snackbar(
//         "Session Expired",
//         "Please log in again",
//         backgroundColor: Colors.red[600],
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 4),
//         margin: const EdgeInsets.all(20),
//         borderRadius: 12,
//       );
//     }

//     handler.next(err);
//   }
// }































// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:precords_android/models/player.dart';
// import 'package:precords_android/models/club_model.dart'; 

                  
// import 'auth_service.dart';

// class ApiService extends GetxService {
//   final Dio dio = Dio();
//   final storage = const FlutterSecureStorage();
  
//   // Base URL from .env (with fallback)
//   static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.123.97:3000';

//   ApiService() {
//     dio.options.baseUrl = _baseUrl;
//     dio.options.connectTimeout = const Duration(seconds: 12);
//     dio.options.receiveTimeout = const Duration(seconds: 12);

//     // Add auth interceptor (handles token + auto refresh + logout)
//     dio.interceptors.add(AuthInterceptor());
//   }

//   // ==================== PLAYERS ====================
//   Future<List<Player>> getAllPlayers() async {
//     try {
//       final response = await dio.get('/api/android/player');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => Player.fromJson(json)).toList();
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data is Map
//           ? e.response?.data['error'] ?? 'Failed to load players'
//           : 'Failed to load players';
//       throw Exception(errorMsg);
//     }
//   }

//   // ==================== PLAYERS-CLUBS ====================
// // Add this to ApiService class
// Future<ClubModel> getClubDetailsByName(String clubName) async {
//   try {
//     // Encode the name to handle spaces and special chars
//     final encodedName = Uri.encodeComponent(clubName);   
//     //  final response = await dio.get('/api/android/club/$encodedName');

//     final response = await dio.get('/api/android/club/$encodedName');

//     if (response.data['success'] == false) {
//       throw Exception(response.data['error'] ?? 'Club not found');
//     }

//     final json = response.data['data'];
//     return ClubModel.fromJson(json);
//   } on DioException catch (e) {
//     final errorMsg = e.response?.data['error'] ?? 'Failed to load club details';
//     throw Exception(errorMsg);
//   }
// }
//   // ==================== CLUBS ====================
//   Future<List<ClubModel>> getAllClubs() async {
//     try {
//       final response = await dio.get('/api/android/club');
//       final List data = response.data['data'] ?? [];
//       return data.map((json) => ClubModel.fromJson(json)).toList();
//     } on DioException catch (e) {
//       final errorMsg = e.response?.data['error'] ?? 'Failed to load clubs';
//       throw Exception(errorMsg);
//     }
//   }
// }

// // CLEAN & WORKING AuthInterceptor (with auto refresh + centered snackbar)
// class AuthInterceptor extends Interceptor {
//   @override
//   void onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     final token = await const FlutterSecureStorage().read(key: 'access_token');
//     if (token != null) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//     options.headers['Content-Type'] = 'application/json';
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode != 401) {
//       return handler.next(err);
//     }

//     final refreshToken = await const FlutterSecureStorage().read(key: 'refresh_token');

//     if (refreshToken != null) {
//       try {
//         final refreshDio = Dio();
//         final response = await refreshDio.post(
//           '${ApiService._baseUrl}/api/android/user/getRefreshToken',
//           data: {'refreshToken': refreshToken},
//         );

//         if (response.data['success'] == true) {
//           final newAccessToken = response.data['data']['accessToken'];
//           final newRefreshToken = response.data['data']['refreshToken'];

//           await const FlutterSecureStorage().write(key: 'access_token', value: newAccessToken);
//           if (newRefreshToken != null) {
//             await const FlutterSecureStorage().write(key: 'refresh_token', value: newRefreshToken);
//           }

//           err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
//           final clonedRequest = await Dio().fetch(err.requestOptions);
//           return handler.resolve(clonedRequest);
//         }
//       } catch (e) {
//         print("Token refresh failed: $e");
//       }
//     }

//     // ─── LOGOUT ON FINAL FAILURE ───
//     final authService = Get.find<AuthService>();
//     authService.isLoggedIn.value = false;
//     await const FlutterSecureStorage().deleteAll();

//     if (Get.currentRoute != '/login') {
//       Get.offAllNamed('/login');

//       Get.snackbar(
//         "",
//         "",
//         backgroundColor: Colors.red[600],
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 5),
//         margin: const EdgeInsets.all(20),
//         borderRadius: 16,
//         mainButton: TextButton(onPressed: null, child: const SizedBox()),
//         titleText: const Center(
//           child: Text(
//             "Session Expired",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
//           ),
//         ),
//         messageText: const Center(
//           child: Text(
//             "Please log in again",
//             style: TextStyle(fontSize: 15),
//           ),
//         ),
//       );
//     }

//     handler.next(err);
//   }
// }

