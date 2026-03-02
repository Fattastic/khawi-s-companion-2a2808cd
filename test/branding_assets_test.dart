import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical logo and app icon both exist', () {
    final logo = File('assets/images/logo.png');
    final appIcon = File('assets/images/app_icon.png');

    expect(logo.existsSync(), isTrue);
    expect(appIcon.existsSync(), isTrue);
    final logoBytes = logo.readAsBytesSync();
    final appBytes = appIcon.readAsBytesSync();

    expect(logoBytes.isNotEmpty, isTrue);
    expect(appBytes.isNotEmpty, isTrue);
  });
}
