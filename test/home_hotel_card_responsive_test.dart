import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('featured hotel card has no overflow on iPhone SE', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final responsive = HomeResponsive.of(context);
              return SizedBox(
                height: 304 * responsive.scale,
                child: HotelCard(
                  name: 'Hotel de l Opera Hanoi - MGallery',
                  location: 'Ha Noi',
                  price: '2.500.000 d / dem',
                  colors: const [Color(0xFFB8D8E8), Color(0xFF345E75)],
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hotel de l Opera Hanoi - MGallery'), findsOneWidget);
  });
}
