import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/club_model.dart';
import '../models/player_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class AuthInterceptor extends Interceptor {
  final ApiService api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthInterceptor(this.api);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
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
      final res = await refreshDio.post('/api/android/user/getRefreshToken',
          data: {'refreshToken': refreshToken});

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

          final cloned = await refreshDio
              .fetch(opts); // retry with refreshDio to reuse baseUrl/timeouts
          return handler.resolve(cloned);
        }
      }
    } catch (_) {
      // ignore and fallthrough to logout
    }

    _forceLogout(handler, err);
  }

  void _forceLogout(ErrorInterceptorHandler handler, DioException err) {
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
  final auth = Get.find<AuthService>();

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

//======================== GET ALL POSITIONS ==================
  Future<List<Map<String, dynamic>>> getAllPositions() async {
    final positions = await dio.get('/api/android/position');
    final List data = positions.data['data'] ?? [];
    return List<Map<String, dynamic>>.from(data);
  }

  //================GET ALL PLAYERS ============================
  Future<List<PlayerInClub>> getAllPlayers() async {
    final r = await dio.get('/api/android/player');
    final List data = r.data['data'] ?? [];
    return data
        .map((e) => PlayerInClub.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Player> getPlayerWithClub(String playerId) async {
    final r = await dio.get('/api/android/player/$playerId');
    final data = r.data['data'];
    final playerJson = (data['player'] as Map<String, dynamic>);
    final clubJson = data['club'] as Map<String, dynamic>?;
    final playerInClub = PlayerInClub.fromJson(playerJson);
    final club = clubJson != null ? ClubModel.fromJson(clubJson) : null;
    return Player.fromPlayerInClub(playerInClub);
  }

// ============================= NEW PLAYER ===============================
  Future<void> createPlayer({
    required String clubId,
    required String name,
    required int age,
    required String country,
    String? photo,
    String? positionId,
    String? gender,
    String? phone,
    String? email,
    int? jerseyNumber,
  }) async {
    try {
      final response = await dio.post('/api/android/player/new', data: {
        "club": clubId,
        "name": name.trim(),
        "age": age,
        "country": country.trim(),
        "photo": photo,
        "position": positionId,
        "gender": gender,
        "phone": phone,
        "email": email,
        "jerseyNumber": jerseyNumber,
      });

      if (response.statusCode != 201 || response.data['success'] != true) {
        throw Exception(response.data['error'] ?? "Failed to create player");
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? "Network error";
      throw Exception(msg);
    }
  }

// ============================ UPDATE PLAYER ====================
  Future<Player> updatePlayer(String id, dynamic updates) async {
    final response = await dio.patch(
      '/api/android/player/$id',
      data: updates, // Dio automatically handles FormData vs JSON
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Update failed');
    }

    if (response.data['data'] == null) {
      throw Exception('No player data returned');
    }

    return Player.fromPlayerInClub(
      PlayerInClub.fromJson(response.data['data'] as Map<String, dynamic>),
      // club: null,
    );
  }


  Future<void> deletePlayer(String id) async {
    try {
      final response = await dio.delete(
        '/api/android/player/$id',
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      // If error, try to parse JSON error message
      dynamic errorMsg = "Failed to delete player";
      try {
        final data = response.data;
        errorMsg = data['error'] ?? errorMsg;
      } catch (_) {}

      throw Exception(errorMsg);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      String message = e.response?.data is String
          ? e.response!.data
          : e.response?.data['error'] ?? e.message ?? 'Delete failed';

      if (status == 401) throw Exception('Unauthorized access');
      if (status == 403) throw Exception('Forbidden action');
      if (status == 404) throw Exception('Player not found');

      throw Exception(message);
    } catch (e) {
      rethrow;
    }
  }

  // ================GET ALL CLUBS=============================
  Future<List<ClubModel>> getAllClubs() async {
    final r = await dio.get('/api/android/club');
    final List data = r.data['data'] ?? [];
    return data
        .map((e) => ClubModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
// //==================CREATE CLUB================================
  //================CREATE CLUB=================================

  Future<ClubModel> createClub({
    required String name,
    required String country,
    String? logo,
    String? level,
  }) async {
    try {
      final response = await dio.post(
        '/api/android/club',
        data: {
          "name": name.trim(),
          "country": country.trim(),
          "logo": logo,
          "level": level,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to create club');
      }

      // Extract the club data from response
      final clubData = response.data['data'] ?? response.data['club'];

      if (clubData == null) {
        throw Exception('No club data returned from server');
      }

      // Convert to ClubModel and return
      return ClubModel.fromJson(clubData as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['error'] ?? e.message ?? 'Network error';
      throw Exception('Create club failed: $errorMsg');
    } catch (e) {
      rethrow;
    }
  }

//==================GET CLUB DETAILS BY NAME ===========
  Future<ClubModel> getClubDetailsByName(String clubName) async {
    final encoded = Uri.encodeComponent(clubName);
    final r = await dio.get('/api/android/club/$encoded');
    return ClubModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  // =========================GET ALL USERS ===================
  Future<List<UserModel>> getAllUsers() async {
    final users = await dio.get('/api/android/user');
    final List data = users.data['data'] ?? [];
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

// ============================= NEW: USER =========================
  Future<UserModel> registerUser(Map<String, dynamic> data) async {
    final user = await dio.post('/api/android/user/register', data: data);
    final userData = user.data['data']['user'];
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

// ============================ UPDATE USER ========================
  Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
    final response = await dio.patch(
      '/api/android/user/$id',
      data: updates,
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Update failed');
    }
    return UserModel.fromJson(response.data['data']);
  }

// ============================ DELETE USER ========================
  Future<void> deleteUser(String id) async {
    try {
      final response = await dio.delete(
        '/api/android/user/$id',
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
          response.data['error'] ?? "Failed to delete user",
        );
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data['error'] ?? e.message;
      if (status == 401) {
        throw Exception('Unathorized access');
      } else if (status == 403) {
        throw Exception('Forbidden action');
      } else if (status == 404) {
        throw Exception('User not found');
      } else {
        throw Exception(message ?? 'Delete failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
