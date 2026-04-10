class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.responseBody,
    this.responseHeaders,
    this.requestContext,
  });

  final String message;
  final int? statusCode;
  final String? responseBody;
  final Map<String, String>? responseHeaders;
  final String? requestContext;

  @override
  String toString() => message;
}
