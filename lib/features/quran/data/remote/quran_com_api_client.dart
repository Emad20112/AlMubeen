import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:al_mubeen/core/data/data_failure.dart';
import 'package:al_mubeen/core/data/data_result.dart';
import 'package:al_mubeen/core/data/json_map.dart';

abstract interface class QuranComApiClient {
  Future<DataResult<JsonMap>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
  });

  Future<DataResult<JsonList>> getJsonList(
    String path, {
    Map<String, String> queryParameters = const {},
  });
}

final class HttpQuranComApiClient implements QuranComApiClient {
  HttpQuranComApiClient({
    required Uri baseUri,
    HttpClient? httpClient,
    Map<String, String> headers = const {},
    this.requestTimeout = const Duration(seconds: 15),
  }) : baseUri = baseUri,
       _httpClient = httpClient ?? HttpClient(),
       _headers = Map.unmodifiable(headers);

  final Uri baseUri;
  final Duration requestTimeout;
  final HttpClient _httpClient;
  final Map<String, String> _headers;

  @override
  Future<DataResult<JsonMap>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final uri = _resolve(path, queryParameters);

    debugPrint('QuranBackendClient: GET $uri');
    if (queryParameters.isNotEmpty) {
      debugPrint('QuranBackendClient: queryParameters: $queryParameters');
    }

    try {
      final request = await _httpClient.getUrl(uri).timeout(requestTimeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'AlMubeen/1.0');

      for (final entry in _headers.entries) {
        request.headers.set(entry.key, entry.value);
      }

      final response = await request.close().timeout(requestTimeout);
      final responseBody = await utf8.decoder
          .bind(response)
          .join()
          .timeout(requestTimeout);

      debugPrint('QuranBackendClient: response status=${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _errorFromBody(
          statusCode: response.statusCode,
          body: responseBody,
          uri: uri,
        );
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is! JsonMap) {
        return DataError(
          DataFailure(
            kind: DataFailureKind.invalidResponse,
            message: 'Backend response was not a JSON object.',
            uri: uri,
          ),
        );
      }

      return _unwrapBackendMap(decoded, uri);
    } on TimeoutException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.timeout,
          message: 'Backend request timed out.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse backend response.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.network,
          message: 'Unable to reach Al-Mubeen backend.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<DataResult<JsonList>> getJsonList(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final result = await getJson(path, queryParameters: queryParameters);
    return result.when(
      success: (json) {
        for (final value in json.values) {
          if (value is JsonList) {
            return DataSuccess(value);
          }
        }

        return DataError(
          DataFailure(
            kind: DataFailureKind.invalidResponse,
            message: 'Backend response did not contain a JSON list.',
          ),
        );
      },
      error: DataError.new,
    );
  }

  void dispose() {
    _httpClient.close(force: true);
  }

  DataResult<JsonMap> _unwrapBackendMap(JsonMap envelope, Uri uri) {
    final ok = envelope['ok'];
    if (ok == false) {
      final error = envelope['error'];
      final message = error is JsonMap
          ? error['message']?.toString() ?? 'Backend request failed.'
          : 'Backend request failed.';

      return DataError(
        DataFailure(
          kind: DataFailureKind.network,
          message: message,
          uri: uri,
        ),
      );
    }

    final data = envelope['data'];
    if (data is JsonMap) {
      return DataSuccess(data);
    }

    if (data == null) {
      return const DataSuccess(<String, dynamic>{});
    }

    return DataError(
      DataFailure(
        kind: DataFailureKind.invalidResponse,
        message: 'Backend "data" field was not a JSON object.',
        uri: uri,
      ),
    );
  }

  DataError<JsonMap> _errorFromBody({
    required int statusCode,
    required String body,
    required Uri uri,
  }) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is JsonMap && decoded['error'] is JsonMap) {
        final message =
            (decoded['error'] as JsonMap)['message']?.toString() ??
            'Backend request failed with $statusCode.';
        return DataError(
          DataFailure(
            kind: _failureKindForStatus(statusCode),
            message: message,
            code: statusCode.toString(),
            uri: uri,
          ),
        );
      }
    } catch (_) {}

    return DataError(
      DataFailure(
        kind: _failureKindForStatus(statusCode),
        message: 'Backend request failed with $statusCode.',
        code: statusCode.toString(),
        uri: uri,
      ),
    );
  }

  Uri _resolve(String path, Map<String, String> queryParameters) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path
        : '${baseUri.path}/';
    final mergedQueryParameters = <String, String>{
      ...baseUri.queryParameters,
      ...queryParameters,
    };

    return baseUri.replace(
      path: '$basePath$normalizedPath',
      queryParameters: mergedQueryParameters.isEmpty
          ? null
          : mergedQueryParameters,
    );
  }

  DataFailureKind _failureKindForStatus(int statusCode) {
    return switch (statusCode) {
      401 => DataFailureKind.unauthorized,
      403 => DataFailureKind.forbidden,
      404 => DataFailureKind.notFound,
      429 => DataFailureKind.rateLimited,
      _ => DataFailureKind.network,
    };
  }
}
