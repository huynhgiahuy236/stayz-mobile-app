import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_mobile/main.dart';

void main() {
  testWidgets('StayZ booking flow renders main screens', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Ana Mandara Villas Đà Lạt'), findsOneWidget);
    expect(find.text('CHỌN PHÒNG'), findsOneWidget);

    await tester.tap(find.text('CHỌN PHÒNG'));
    await tester.pumpAndSettle();

    expect(find.text('Chọn phòng'), findsOneWidget);
    expect(find.text('TIẾP TỤC ĐẶT PHÒNG'), findsOneWidget);

    await tester.tap(find.text('TIẾP TỤC ĐẶT PHÒNG'));
    await tester.pumpAndSettle();

    expect(find.text('Xác nhận đặt phòng'), findsOneWidget);
    await tester.drag(find.byType(Scrollable), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết thanh toán'), findsOneWidget);
  });
}
