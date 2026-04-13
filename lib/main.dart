import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/design_tokens.dart';
import 'controllers/game_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DungeonEruditoApp());
}

// ─────────────────────────────────────────────────────────────
//  APP ROOT
// ─────────────────────────────────────────────────────────────

class DungeonEruditoApp extends StatelessWidget {
  const DungeonEruditoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dungeon do Erudito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: DT.bg,
        colorScheme: const ColorScheme.dark(
          primary: DT.gold,
          secondary: DT.violet,
          surface: DT.surface,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const GameController(),
    );
  }
}
