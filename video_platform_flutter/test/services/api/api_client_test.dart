import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:video_platform_flutter/services/api/api_client.dart';
import 'package:video_platform_flutter/services/api/api_exception.dart';
import 'package:video_platform_flutter/services/api/api_logger.dart';

void main() {
  group('ApiClient logging', () {
    test('logs full GET request and response', () async {
      final logs = <String>[];
      final client = ApiClient(
        baseUrl: 'http://example.com/base',
        tokenProvider: () => 'token-123',
        logger: ApiLogger(output: logs.add),
        httpClient: MockClient((request) async {
          expect(request.url.toString(), 'http://example.com/base/api/videos?q=cat&page=2');
          expect(request.headers['Authorization'], 'Bearer token-123');
          return http.Response(
            jsonEncode({
              'success': true,
              'videos': [],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await client.getJson(
        '/api/videos',
        queryParameters: {'q': 'cat', 'page': 2},
      );

      expect(logs.join('\n'), contains('REQUEST GET http://example.com/base/api/videos?q=cat&page=2'));
      expect(logs.join('\n'), contains('"Authorization": "Bearer token-123"'));
      expect(logs.join('\n'), contains('"q": "cat"'));
      expect(logs.join('\n'), contains('RESPONSE 200'));
      expect(logs.join('\n'), contains('"videos":[]'));
    });

    test('logs JSON POST request body and response', () async {
      final logs = <String>[];
      final client = ApiClient(
        baseUrl: 'http://example.com',
        tokenProvider: () => 'token-456',
        logger: ApiLogger(output: logs.add),
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.headers['Content-Type'], 'application/json');
          expect(request.body, '{"username":"alice","password":"secret"}');
          return http.Response(
            jsonEncode({'success': true, 'token': 'jwt'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await client.postJson(
        '/api/auth/login',
        body: {'username': 'alice', 'password': 'secret'},
      );

      expect(logs.join('\n'), contains('REQUEST POST http://example.com/api/auth/login'));
      expect(logs.join('\n'), contains('"password": "secret"'));
      expect(logs.join('\n'), contains('"token":"jwt"'));
    });

    test('logs delete failure response body and keeps raw body on exception', () async {
      final logs = <String>[];
      final client = ApiClient(
        baseUrl: 'http://example.com',
        tokenProvider: () => 'token-789',
        logger: ApiLogger(output: logs.add),
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({'success': false, 'msg': 'no permission'}),
            403,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final future = client.deleteJson('/api/comments/3');

      await expectLater(
        future,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.responseBody, 'responseBody', contains('no permission')),
        ),
      );
      expect(logs.join('\n'), contains('RESPONSE 403'));
      expect(logs.join('\n'), contains('no permission'));
      expect(logs.join('\n'), contains('ERROR ApiException'));
    });

    test('logs multipart fields and file metadata', () async {
      final logs = <String>[];
      final httpClient = _TestMultipartClient(
        handler: (request) async {
          expect(request.method, 'POST');
          expect(request.url.toString(), 'http://example.com/api/upload');
          expect(request.headers['Authorization'], 'Bearer token-123');
          expect(request.fields['title'], 'Demo');
          expect(request.files.single.filename, 'video.mp4');
          return http.Response(
            jsonEncode({'success': true, 'id': 9}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );
      final client = ApiClient(
        baseUrl: 'http://example.com',
        tokenProvider: () => 'token-123',
        logger: ApiLogger(output: logs.add),
        httpClient: httpClient,
      );

      await client.postMultipart(
        '/api/upload',
        fields: {'title': 'Demo'},
        files: [
          http.MultipartFile.fromBytes(
            'file',
            Uint8List.fromList(<int>[1, 2, 3, 4]),
            filename: 'video.mp4',
          ),
        ],
      );

      expect(logs.join('\n'), contains('REQUEST POST http://example.com/api/upload'));
      expect(logs.join('\n'), contains('"title": "Demo"'));
      expect(logs.join('\n'), contains('"filename": "video.mp4"'));
      expect(logs.join('\n'), contains('"length": 4'));
    });

    test('logs raw response when JSON parsing fails', () async {
      final logs = <String>[];
      final client = ApiClient(
        baseUrl: 'http://example.com',
        tokenProvider: () => 'token-123',
        logger: ApiLogger(output: logs.add),
        httpClient: MockClient((request) async {
          return http.Response(
            '<html>bad gateway</html>',
            502,
            headers: {'content-type': 'text/html'},
          );
        }),
      );

      final future = client.getJson('/api/videos');

      await expectLater(
        future,
        throwsA(
          isA<ApiException>()
              .having((e) => e.responseBody, 'responseBody', '<html>bad gateway</html>'),
        ),
      );
      expect(logs.join('\n'), contains('<html>bad gateway</html>'));
    });

    test('logs network exceptions', () async {
      final logs = <String>[];
      final client = ApiClient(
        baseUrl: 'http://example.com',
        tokenProvider: () => 'token-123',
        logger: ApiLogger(output: logs.add),
        httpClient: MockClient((request) async {
          throw http.ClientException('socket failed');
        }),
      );

      await expectLater(
        client.getJson('/api/videos'),
        throwsA(isA<http.ClientException>()),
      );

      expect(logs.join('\n'), contains('ERROR ClientException'));
      expect(logs.join('\n'), contains('socket failed'));
    });

    test('logs unauthorized failures with raw response body', () async {
      final logs = <String>[];
      final client = ApiClient(
        baseUrl: 'http://example.com',
        tokenProvider: () => 'token-123',
        logger: ApiLogger(output: logs.add),
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({'success': false, 'msg': 'expired'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await expectLater(
        client.getJson('/api/videos/1'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.responseBody, 'responseBody', contains('expired')),
        ),
      );

      expect(logs.join('\n'), contains('RESPONSE 401'));
      expect(logs.join('\n'), contains('expired'));
    });
  });
}

class _TestMultipartClient extends http.BaseClient {
  _TestMultipartClient({required this.handler});

  final Future<http.Response> Function(http.MultipartRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.MultipartRequest) {
      throw StateError('Expected MultipartRequest');
    }

    final response = await handler(request);
    final stream = Stream<List<int>>.fromIterable([
      utf8.encode(response.body),
    ]);
    return http.StreamedResponse(
      stream,
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      request: request,
    );
  }
}
