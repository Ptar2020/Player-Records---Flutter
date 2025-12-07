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

//======================== GET ALL POSITIONS ==================
  Future<List<Map<String, dynamic>>> getAllPositions() async {
    final positions = await dio.get('/api/android/position');
    final List data = positions.data['data'] ?? [];
    return List<Map<String, dynamic>>.from(data);
  }

// ================= NEW PLAYER ===============================
  Future<void> createPlayer({
    required String clubId,
    required String name,
    required int age,
    required String country,
    String? photo,
    String? positionId,
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
    return Player.fromPlayerInClub(playerInClub, club: club);
  }

// ============================ UPDATE PLAYER ====================
  Future<Player> updatePlayer(String id, Map<String, dynamic> updates) async {
    final response = await dio.patch(
      '/api/android/player/$id',
      data: updates,
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Update failed');
    }
    return response.data['data'] != null
        ? Player.fromPlayerInClub(
            PlayerInClub.fromJson(
                response.data['data'] as Map<String, dynamic>),
            club: null,
          )
        : throw Exception('No player data returned');
  }

  // ================GET ALL CLUBS=============================
  Future<List<ClubModel>> getAllClubs() async {
    final r = await dio.get('/api/android/club');
    final List data = r.data['data'] ?? [];
    return data
        .map((e) => ClubModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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

// ======================= NEW: USER =========================
  Future<UserModel> registerUser(Map<String, dynamic> data) async {
    final user = await dio.post('/api/android/user/register', data: data);
    final userData = user.data['data']['user'];
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

// ============================ UPDATE USER ====================
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

//   Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
//     try {
//       final r = await dio.patch('/api/android/user/$id', data: updates);
//       if (r.data['success'] == true) {
//         return UserModel.fromJson(r.data['data'] as Map<String, dynamic>);
//       } else {
//         throw Exception(r.data['error'] ?? 'Failed to update user');
//       }
//     } on DioError catch (e) {
//       final msg = e.response?.data is Map
//           ? e.response?.data['error'] ?? 'Failed to update user'
//           : 'Network error';
//       throw Exception(msg);
//     }
//   }
}
