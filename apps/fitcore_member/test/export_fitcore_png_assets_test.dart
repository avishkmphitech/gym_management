// Writes transparent PNGs of the FitCore mark (48, 96, 192) to assets/branding/.
// Run from apps/fitcore_member:
//   flutter test test/export_fitcore_png_assets_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:fitcore_member/core/widgets/fitcore_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Export fitcore_logo_{48,96,192}.png (transparent) to assets/branding', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const dims = [48, 96, 192];
    final dir = Directory('assets/branding');
    await dir.create(recursive: true);

    for (final px in dims) {
      final size = px.toDouble();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      paintFitCoreMark(canvas, Size(size, size), FitCoreBrandColors.accent);
      final picture = recorder.endRecording();
      final image = await picture.toImage(px, px);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      expect(byteData, isNotNull);
      final file = File('${dir.path}/fitcore_logo_$px.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());
      expect(file.existsSync(), isTrue, reason: file.path);
    }
  });
}
