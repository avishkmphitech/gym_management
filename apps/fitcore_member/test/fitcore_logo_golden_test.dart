import 'package:fitcore_member/core/widgets/fitcore_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final px in [48.0, 96.0, 192.0]) {
    testWidgets('FitCore mark golden ${px.toInt()}px @1.0 DPR', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(px, px);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ColoredBox(
            color: const Color(0xFF151515),
            child: Center(
              child: FitCoreLogo(size: px),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FitCoreLogo),
        matchesGoldenFile('goldens/fitcore_logo_${px.toInt()}.png'),
      );
    });
  }

  testWidgets('FitCore horizontal lockup golden', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(560, 220);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const logoSize = 96.0;
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: ColoredBox(
          color: const Color(0xFF151515),
          child: Center(
            child: FitCoreLogoLockup(
              logoSize: logoSize,
              tagline: 'Power Your Gym',
              wordmarkStyle: TextStyle(
                fontFamily: 'Roboto',
                fontSize: logoSize * 0.48,
                fontWeight: FontWeight.w600,
                color: FitCoreBrandColors.lockupText,
                height: 1.0,
                letterSpacing: -0.4,
              ),
              taglineStyle: TextStyle(
                fontFamily: 'Roboto',
                fontSize: logoSize * 0.22,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFB8B6B0),
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(FitCoreLogoLockup),
      matchesGoldenFile('goldens/fitcore_logo_lockup.png'),
    );
  });
}
