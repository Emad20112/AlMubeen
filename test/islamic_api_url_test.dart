// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  final client = HttpClient();
  try {
    // test 1
    var req = await client.getUrl(
      Uri.parse('https://api.islamic.app/v1/audio/ayah/ar.alafasy/1/1.mp3'),
    );
    var res = await req.close();
    print('Test 1 (ar.alafasy/1/1.mp3): ${res.statusCode}');

    // test 2
    req = await client.getUrl(
      Uri.parse('https://api.islamic.app/v1/audio/ayah/ar.alafasy/1/1'),
    );
    res = await req.close();
    print('Test 2 (ar.alafasy/1/1): ${res.statusCode}');

    // test 3
    req = await client.getUrl(
      Uri.parse('https://api.islamic.app/v1/audio/ayah/ar.alafasy/1:1.mp3'),
    );
    res = await req.close();
    print('Test 3 (ar.alafasy/1:1.mp3): ${res.statusCode}');
  } finally {
    client.close();
  }
}
