// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  test('Test islamic.app reciters API connection', () async {
    final httpClient = HttpClient();
    try {
      final uri = Uri.parse('https://api.islamic.app/v1/audio/reciters');
      print('Connecting to: $uri');

      final request = await httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      // Set a generic User-Agent just in case it's needed by the API
      request.headers.set(HttpHeaders.userAgentHeader, 'AlMubeenTest/1.0');

      final response = await request.close();
      print('Response Status Code: ${response.statusCode}');

      expect(
        response.statusCode,
        inInclusiveRange(200, 299),
        reason: 'Expected a success status code',
      );

      final responseBody = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(responseBody);

      // Let's print a small part of the response to verify it looks correct
      if (decoded is List) {
        print('Success! Received a list of ${decoded.length} reciters.');
        if (decoded.isNotEmpty) {
          print('First reciter: ${decoded.first}');
        }
      } else if (decoded is Map) {
        print('Success! Received a Map response.');
        print('Response keys: ${decoded.keys}');
      } else {
        print('Received response: $decoded');
      }
    } catch (e) {
      print('Connection failed: $e');
      fail('Connection to islamic.app failed: $e');
    } finally {
      httpClient.close(force: true);
    }
  });
}
