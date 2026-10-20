import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';
import 'api_consumer.dart';
import 'api_endpoints.dart';


class DioClient implements ApiConsumer {
  final Dio _dio;

  DioClient({Dio? dio}) : _dio = dio ?? createDefaultDio();

  Dio get dio => _dio;

  static Dio createDefaultDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
        ),
      );
    }

    return dio;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    dynamic cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken as CancelToken?,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is TimeoutException ||
          e is NotFoundException ||
          e is CancelException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    dynamic cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken as CancelToken?,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is TimeoutException ||
          e is NotFoundException ||
          e is CancelException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    dynamic cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken as CancelToken?,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is TimeoutException ||
          e is NotFoundException ||
          e is CancelException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    dynamic cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken as CancelToken?,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is TimeoutException ||
          e is NotFoundException ||
          e is CancelException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    dynamic cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken as CancelToken?,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is TimeoutException ||
          e is NotFoundException ||
          e is CancelException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  void handleDioException(DioException exception) {
    if (exception.type == DioExceptionType.cancel) {
      throw const CancelException('Request was cancelled.');
    }

    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      throw const TimeoutException(
        'Connection timed out. Please check your internet connection.',
      );
    }

    if (exception.type == DioExceptionType.connectionError) {
      throw const NetworkException(
        'Unable to connect to the server. Please check your internet connection.',
      );
    }

    final response = exception.response;
    if (response != null) {
      final statusCode = response.statusCode;
      if (statusCode == 404) {
        throw const NotFoundException('The requested resource was not found.');
      }
      final dynamic data = response.data;
      String message = 'Server error occurred.';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (response.statusMessage != null) {
        message = response.statusMessage!;
      }
      throw ServerException(message, statusCode: statusCode);
    }

    throw ServerException(
      exception.message ?? 'An unexpected network error occurred.',
    );
  }
}
