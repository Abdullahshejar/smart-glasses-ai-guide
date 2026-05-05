import 'package:flutter_test/flutter_test.dart';
import 'package:smartglasses_app/app.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MuseumGuideApp());
    await tester.pumpAndSettle();

    expect(find.text('Museum Guide'), findsOneWidget);
  });
}
