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
    Uri? baseUri,
    HttpClient? httpClient,
    String? accessToken,
    String? clientId,
    Map<String, String> headers = const {},
    this.requestTimeout = const Duration(seconds: 15),
  })  : baseUri = baseUri ??
            Uri.parse('https://apis.quran.foundation/content/api/v4'),
        _httpClient = httpClient ?? HttpClient(),
        _headers = Map.unmodifiable({
          if (accessToken != null && accessToken.isNotEmpty)
            'x-auth-token': accessToken,
          if (clientId != null && clientId.isNotEmpty) 'x-client-id': clientId,
          ...headers,
        });

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

    debugPrint('QuranComApiClient: GET $uri');
    if (_headers.isNotEmpty) {
      debugPrint('QuranComApiClient: headers: ${_headers.keys.toList()}');
    }
    if (queryParameters.isNotEmpty) {
      debugPrint('QuranComApiClient: queryParameters: $queryParameters');
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

      debugPrint('QuranComApiClient: response status=${response.statusCode}');
      debugPrint(
        'QuranComApiClient: response body: ${responseBody.length} bytes',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'QuranComApiClient: non-2xx response: ${response.statusCode} for $uri',
        );
        debugPrint(
          'QuranComApiClient: response body (truncated): '
          '${responseBody.length > 1000 ? responseBody.substring(0, 1000) : responseBody}',
        );
        return DataError(
          DataFailure(
            kind: _failureKindForStatus(response.statusCode),
            message: 'Quran Foundation request failed with ${response.statusCode}.',
            code: response.statusCode.toString(),
            uri: uri,
          ),
        );
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is JsonMap) {
        return DataSuccess(decoded);
      }

      return DataError(
        DataFailure(
          kind: DataFailureKind.invalidResponse,
          message: 'Quran Foundation response was not a JSON object.',
          uri: uri,
        ),
      );
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('QuranComApiClient: timeout for $uri - ${error.toString()}');
      return DataError(
        DataFailure(
          kind: DataFailureKind.timeout,
          message: 'Quran Foundation request timed out.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on FormatException catch (error, stackTrace) {
      debugPrint('QuranComApiClient: format exception for $uri - ${error.toString()}');
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Quran Foundation response.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      debugPrint('QuranComApiClient: network exception for $uri - ${error.toString()}');
      return DataError(
        DataFailure(
          kind: DataFailureKind.network,
          message: 'Unable to reach Quran Foundation.',
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
    final uri = _resolve(path, queryParameters);

    debugPrint('QuranComApiClient: GET (list) $uri');

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

      debugPrint('QuranComApiClient: response status=${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return DataError(
          DataFailure(
            kind: _failureKindForStatus(response.statusCode),
            message: 'Quran Foundation request failed with ${response.statusCode}.',
            code: response.statusCode.toString(),
            uri: uri,
          ),
        );
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is JsonList) {
        return DataSuccess(decoded);
      }

      return DataError(
        DataFailure(
          kind: DataFailureKind.invalidResponse,
          message: 'Quran Foundation response was not a JSON list.',
          uri: uri,
        ),
      );
    } on TimeoutException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.timeout,
          message: 'Quran Foundation request timed out.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on FormatException catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.parsing,
          message: 'Unable to parse Quran Foundation response.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return DataError(
        DataFailure(
          kind: DataFailureKind.network,
          message: 'Unable to reach Quran Foundation.',
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void dispose() {
    _httpClient.close(force: true);
  }

  Uri _resolve(String path, Map<String, String> queryParameters) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath =
        baseUri.path.endsWith('/') ? baseUri.path : '${baseUri.path}/';
    final mergedQueryParameters = <String, String>{
      ...baseUri.queryParameters,
      ...queryParameters,
    };

    return baseUri.replace(
      path: '$basePath$normalizedPath',
      queryParameters:
          mergedQueryParameters.isEmpty ? null : mergedQueryParameters,
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
