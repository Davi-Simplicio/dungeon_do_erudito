import 'package:dungeon_quiz/main.dart';

void main() {
  testWidgets('App loads without error', (WidgetTester tester) async {
    await tester.pumpWidget(const DungeonEruditoApp());  // ✅ Correct class name
    
    expect(find.text('DUNGEON'), findsOneWidget);
    expect(find.text('DO ERUDITO'), findsOneWidget);
  });
}