import 'dart:convert';

import 'package:flutter/foundation.dart';

typedef ApiLogOutput = void Function(String message);

class ApiLogger {
  ApiLogger({ApiLogOutput? output, bool enabled = true})
    : _output = output ?? debugPrint,
      enabled = enabled;

  final ApiLogOutput _output;
  final bool enabled;
  int _requestCounter = 0;

  int nextRequestId() => ++_requestCounter;

  void logRequest({
    required int requestId,
    required DateTime startedAt,
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    List<Map<String, Object?>>? files,
  }) {
    if (!enabled) {
      return;
    }

    _output(
      _buildBlock(
        title:
            '[HTTP][$requestId] REQUEST ${method.toUpperCase()} ${uri.toString()}',
        lines: [
          'startedAt: ${startedAt.toIso8601String()}',
          'method: ${method.toUpperCase()}',
          'url: ${uri.toString()}',
          'headers: ${_pretty(headers)}',
          'query: ${_pretty(queryParameters ?? <String, dynamic>{})}',
          'body: ${_pretty(body)}',
          'files: ${_pretty(files ?? const <Map<String, Object?>>[])}',
        ],
      ),
    );
  }

  void logResponse({
    required int requestId,
    required DateTime finishedAt,
    required Duration duration,
    required int statusCode,
    required Map<String, String> headers,
    required String body,
  }) {
    if (!enabled) {
      return;
    }

    _output(
      _buildBlock(
        title: '[HTTP][$requestId] RESPONSE $statusCode',
        lines: [
          'finishedAt: ${finishedAt.toIso8601String()}',
          'durationMs: ${duration.inMilliseconds}',
          'statusCode: $statusCode',
          'headers: ${_pretty(headers)}',
          'body: $body',
        ],
      ),
    );
  }

  void logError({
    required int requestId,
    required DateTime finishedAt,
    required Duration duration,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (!enabled) {
      return;
    }

    _output(
      _buildBlock(
        title: '[HTTP][$requestId] ERROR ${error.runtimeType}',
        lines: [
          'finishedAt: ${finishedAt.toIso8601String()}',
          'durationMs: ${duration.inMilliseconds}',
          'error: $error',
          if (error is Exception) 'details: ${_pretty(error)}',
          'stackTrace: ${_stackSummary(stackTrace)}',
        ],
      ),
    );
  }

  String _buildBlock({required String title, required List<String> lines}) {
    final buffer = StringBuffer(title);
    for (final line in lines) {
      buffer
        ..writeln()
        ..write(line);
    }
    return buffer.toString();
  }

  String _pretty(Object? value) {
    if (value == null) {
      return 'null';
    }

    final encoder = const JsonEncoder.withIndent('  ');
    if (value is Map || value is List) {
      return encoder.convert(value);
    }

    return value.toString();
  }

  String _stackSummary(StackTrace stackTrace) {
    final lines = stackTrace
        .toString()
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .take(8)
        .toList();
    return lines.join('\n');
  }
}
