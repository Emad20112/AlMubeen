// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  final client = HttpClient();
  try {
    var req = await client.getUrl(
      Uri.parse('https://api.islamic.app/v1/audio/surah/ar.alafasy/1.mp3'),
    );
    var res = await req.close();
    print('Surah: ${res.statusCode}');

    req = await client.getUrl(
      Uri.parse('https://api.islamic.app/v1/audio/ayah'),
    );
    res = await req.close();
    print('Ayah base: ${res.statusCode}');
  } finally {
    client.close();
  }
}
