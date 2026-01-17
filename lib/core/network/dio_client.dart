import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sellingapp/core/config/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(BaseOptions(baseUrl: config.apiBaseUrl, headers: {'Accept': 'application/json'}));

  // Cookie management: web falls back to in-memory
  CookieJar cookieJar;
  try {
    cookieJar = CookieJar();
  } catch (e) {
    cookieJar = CookieJar();
  }
  dio.interceptors.add(CookieManager(cookieJar));

  // Token header interceptor
  const storage = FlutterSecureStorage();
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
    try {
      final token = await storage.read(key: 'admin_api_token');
      if (token != null && token.isNotEmpty) {
        options.headers['X-Spree-Token'] = token;
      }
    } catch (e) {
      debugPrint('Token read failed: $e');
    }
    handler.next(options);
  }, onError: (e, handler) {
    debugPrint('Dio error: ${e.message}');
    handler.next(e);
  }));

  return dio;
});
