import 'package:flutter/foundation.dart';

enum DataFailureKind {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,
  invalidResponse,
  parsing,
  storage,
  cacheMiss,
  cancelled,
  unknown,
}

@immutable
final class DataFailure {
  const DataFailure({
    required this.kind,
    required this.message,
    this.code,
    this.uri,
    this.cause,
    this.stackTrace,
  });

  final DataFailureKind kind;
  final String message;
  final String? code;
  final Uri? uri;
  final Object? cause;
  final StackTrace? stackTrace;

  DataFailure copyWith({
    DataFailureKind? kind,
    String? message,
    String? code,
    Uri? uri,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return DataFailure(
      kind: kind ?? this.kind,
      message: message ?? this.message,
      code: code ?? this.code,
      uri: uri ?? this.uri,
      cause: cause ?? this.cause,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('DataFailure(kind: $kind, message: $message');
    if (code != null) {
      buffer.write(', code: $code');
    }
    if (uri != null) {
      buffer.write(', uri: $uri');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
