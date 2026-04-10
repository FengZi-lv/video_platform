import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app.dart';
import '../i_video_service.dart';
import 'api_exception.dart';
import 'api_logger.dart';

typedef TokenProvider = String? Function();

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenProvider tokenProvider,
    http.Client? httpClient,
    ApiLogger? logger,
  }) : _baseUri = Uri.parse(baseUrl),
       _tokenProvider = tokenProvider,
       _httpClient = httpClient ?? http.Client(),
       _logger = logger ?? ApiLogger();

  final Uri _baseUri;
  final TokenProvider _tokenProvider;
  final http.Client _httpClient;
  final ApiLogger _logger;
  static const Set<String> _guestAllowedPaths = <String>{
    '/api/auth/login',
    '/api/auth/register',
    '/api/videos',
    '/api/videos/search',
  };

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = _headers(path);
    return _sendJsonRequest(
      method: 'GET',
      uri: uri,
      headers: headers,
      queryParameters: queryParameters,
      sender: () => _httpClient.get(uri, headers: headers),
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path, null);
    final headers = _headers(path, contentType: true);
    final payload = body ?? <String, dynamic>{};
    return _sendJsonRequest(
      method: 'POST',
      uri: uri,
      headers: headers,
      body: payload,
      sender: () =>
          _httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
    );
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final uri = _buildUri(path, null);
    final headers = _headers(path);
    return _sendJsonRequest(
      method: 'DELETE',
      uri: uri,
      headers: headers,
      sender: () => _httpClient.delete(uri, headers: headers),
    );
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    UploadProgressCallback? onProgress,
  }) async {
    final uri = _buildUri(path, null);
    final headers = _headers(path);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields.addAll(fields ?? const <String, String>{});
    request.files.addAll(files);

    final logFiles = request.files
        .map(
          (file) => <String, Object?>{
            'field': file.field,
            'filename': file.filename,
            'contentType': file.contentType.toString(),
            'length': file.length,
          },
        )
        .toList();

    return _sendJsonRequest(
      method: 'POST',
      uri: uri,
      headers: headers,
      body: Map<String, String>.from(request.fields),
      files: logFiles,
      sender: () async {
        if (onProgress == null) {
          final streamed = await _httpClient.send(request);
          return http.Response.fromStream(streamed);
        }

        // 使用 StreamedRequest 手动构建 multipart 以追踪上传进度
        final totalBytes = request.contentLength;
        final streamedReq = http.StreamedRequest('POST', uri);

        // 将原 MultipartRequest 的数据通过进度追踪的 stream 传输
        final source = request.finalize();

        // 注意：必须在 finalize 之后再复制 headers，因为 finalize 会生成带 boundary 的 content-type
        streamedReq.headers.addAll(headers);
        streamedReq.headers.addAll(request.headers);
        streamedReq.contentLength = totalBytes;

        int sentBytes = 0;

        source
            .transform(
              StreamTransformer<List<int>, List<int>>.fromHandlers(
                handleData: (data, sink) {
                  sentBytes += data.length;
                  onProgress(totalBytes > 0 ? sentBytes / totalBytes : 0.0);
                  sink.add(data);
                },
              ),
            )
            .listen(
              streamedReq.sink.add,
              onError: streamedReq.sink.addError,
              onDone: streamedReq.sink.close,
            );

        final streamed = await _httpClient.send(streamedReq);
        onProgress(1.0);
        return http.Response.fromStream(streamed);
      },
    );
  }

  Future<Map<String, dynamic>> _sendJsonRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required Future<http.Response> Function() sender,
    Map<String, dynamic>? queryParameters,
    Object? body,
    List<Map<String, Object?>>? files,
  }) async {
    final requestId = _logger.nextRequestId();
    final startedAt = DateTime.now();
    _logger.logRequest(
      requestId: requestId,
      startedAt: startedAt,
      method: method,
      uri: uri,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      files: files,
    );

    try {
      final response = await sender();
      _logger.logResponse(
        requestId: requestId,
        finishedAt: DateTime.now(),
        duration: DateTime.now().difference(startedAt),
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
      );
      final decoded = _decodeJson(
        response,
        requestContext: '$method ${uri.toString()}',
      );
      return decoded;
    } catch (error, stackTrace) {
      _logger.logError(
        requestId: requestId,
        finishedAt: DateTime.now(),
        duration: DateTime.now().difference(startedAt),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final sanitizedPath = path.startsWith('/') ? path.substring(1) : path;
    return _baseUri.replace(
      path: '${_baseUri.path}/$sanitizedPath'.replaceAll('//', '/'),
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, String> _headers(String path, {bool contentType = false}) {
    final token = _tokenProvider();
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final authToken =
        token ?? (_isGuestAllowedPath(normalizedPath) ? 'guest' : null);

    if (authToken == null) {
      throw ApiException('请先登录', statusCode: 401);
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
    if (contentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  bool _isGuestAllowedPath(String path) {
    if (_guestAllowedPaths.contains(path)) {
      return true;
    }

    final videoDetailPattern = RegExp(r'^/api/videos/\d+$');
    final userProfilePattern = RegExp(r'^/api/users/\d+$');
    return videoDetailPattern.hasMatch(path) ||
        userProfilePattern.hasMatch(path);
  }

  Map<String, dynamic> _decodeJson(
    http.Response response, {
    String? requestContext,
  }) {
    if (response.statusCode == 401) {
      throw ApiException(
        '请先登录',
        statusCode: response.statusCode,
        responseBody: response.body,
        responseHeaders: response.headers,
        requestContext: requestContext,
      );
    }

    Map<String, dynamic> json;
    try {
      json = (jsonDecode(response.body) as Map).cast<String, dynamic>();
    } catch (_) {
      throw ApiException(
        '服务端返回了无法解析的数据',
        statusCode: response.statusCode,
        responseBody: response.body,
        responseHeaders: response.headers,
        requestContext: requestContext,
      );
    }

    final success = json['success'];
    if (response.statusCode >= 400 || (success is bool && !success)) {
      final msg = (json['msg'] ?? json['message'] ?? '请求失败').toString();

      globalScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );

      throw ApiException(
        msg,
        statusCode: response.statusCode,
        responseBody: response.body,
        responseHeaders: response.headers,
        requestContext: requestContext,
      );
    }
    return json;
  }
}
