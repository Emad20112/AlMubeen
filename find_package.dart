import 'dart:isolate';
void main() async {
  final uri = await Isolate.resolvePackageUri(Uri.parse('package:flutter_islamic_icons/flutter_islamic_icons.dart'));
  print(uri);
}
