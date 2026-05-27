import 'package:flutter_test/flutter_test.dart';
import 'package:missioncontrol_app/app.dart';

void main() {
  testWidgets('App renders with tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MissionControlApp());
    expect(find.text('Mission Control'), findsOneWidget);
    expect(find.text('Ubersicht'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Code Quality'), findsOneWidget);
  });
}
