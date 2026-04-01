import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DungeonEruditoApp());
}

// ─────────────────────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────────────────────

enum GameState { menu, skillTree, dungeon, gameOver, victory }

class Question {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int tier;

  const Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.tier,
  });
}

class PlayerStats {
  int maxHp;
  int currentHp;
  int shards;
  int runShards;
  int floor;
  int level;
  int experience;
  int vigorLevel;
  int siphonLevel;
  int oracleLevel;
  int shieldLevel;
  int armorLevel;
  int focusLevel;
  int wealthLevel;
  bool shieldReady;
  int highestFloor;
  int checkpointFloor;

  PlayerStats({
    this.maxHp = 3,
    this.currentHp = 3,
    this.shards = 0,
    this.runShards = 0,
    this.floor = 1,
    this.level = 1,
    this.experience = 0,
    this.vigorLevel = 0,
    this.siphonLevel = 0,
    this.oracleLevel = 0,
    this.shieldLevel = 0,
    this.armorLevel = 0,
    this.focusLevel = 0,
    this.wealthLevel = 0,
    this.shieldReady = false,
    this.highestFloor = 1,
    this.checkpointFloor = 1,
  });

  bool get hasSiphon => siphonLevel > 0;
  bool get hasOracle => oracleLevel > 0;
  bool get hasShield => shieldLevel > 0;
  bool get hasArmor => armorLevel > 0;
  bool get hasFocus => focusLevel > 0;
  bool get hasWealth => wealthLevel > 0;

  int get expToNextLevel => 100 * level;
  double get expProgress => experience / expToNextLevel;

  void startRun() {
    currentHp = maxHp;
    floor = max(1, checkpointFloor);
    runShards = 0;
    shieldReady = hasShield;
  }

  void gainExp(int amount) {
    experience += amount;
    while (experience >= expToNextLevel) {
      experience -= expToNextLevel;
      levelUp();
    }
  }

  void levelUp() {
    level++;
    maxHp += 1;
    currentHp = maxHp;
  }

  Map<String, dynamic> toJson() => {
    'maxHp': maxHp,
    'currentHp': currentHp,
    'shards': shards,
    'level': level,
    'experience': experience,
    'vigorLevel': vigorLevel,
    'siphonLevel': siphonLevel,
    'oracleLevel': oracleLevel,
    'shieldLevel': shieldLevel,
    'armorLevel': armorLevel,
    'focusLevel': focusLevel,
    'wealthLevel': wealthLevel,
    'highestFloor': highestFloor,
    'checkpointFloor': checkpointFloor,
  };

  static PlayerStats fromJson(Map<String, dynamic> json) => PlayerStats(
    maxHp: json['maxHp'] ?? 3,
    currentHp: json['currentHp'] ?? 3,
    shards: json['shards'] ?? 0,
    level: json['level'] ?? 1,
    experience: json['experience'] ?? 0,
    vigorLevel: json['vigorLevel'] ?? 0,
    siphonLevel: json['siphonLevel'] ?? 0,
    oracleLevel: json['oracleLevel'] ?? 0,
    shieldLevel: json['shieldLevel'] ?? 0,
    armorLevel: json['armorLevel'] ?? 0,
    focusLevel: json['focusLevel'] ?? 0,
    wealthLevel: json['wealthLevel'] ?? 0,
    highestFloor: json['highestFloor'] ?? 1,
    checkpointFloor: json['checkpointFloor'] ?? 1,
  );
}

// ─────────────────────────────────────────────────────────────
//  BANCO DE QUESTÕES - FLUTTER & MOBILE HISTORY
// ─────────────────────────────────────────────────────────────

class QuestionBank {
  static final List<Question> _all = [
    // Tier 1 - Flutter Basics
    const Question(
      prompt: 'Em que ano o Flutter foi anunciado pela primeira vez?',
      options: ['2015', '2017', '2018', '2016'],
      correctIndex: 1,
      explanation: 'Flutter foi anunciado em 2015 no Dart Developer Summit.',
      tier: 1,
    ),
    const Question(
      prompt: 'Qual empresa criou o Flutter?',
      options: ['Facebook', 'Google', 'Apple', 'Microsoft'],
      correctIndex: 1,
      explanation: 'Google desenvolveu o Flutter como um framework open-source.',
      tier: 1,
    ),
    const Question(
      prompt: 'Flutter usa qual linguagem de programação?',
      options: ['Kotlin', 'Swift', 'Dart', 'Java'],
      correctIndex: 2,
      explanation: 'Dart é a linguagem oficial usada no desenvolvimento com Flutter.',
      tier: 1,
    ),
    const Question(
      prompt: 'Qual é o widget básico em Flutter que cria uma coluna?',
      options: ['Row', 'Column', 'Stack', 'Container'],
      correctIndex: 1,
      explanation: 'Column organiza widgets verticalmente, Row organiza horizontalmente.',
      tier: 1,
    ),
    const Question(
      prompt: 'O que permite Flutter funcionar em múltiplas plataformas?',
      options: ['WebView', 'Mecanismo de renderização Skia', 'JVM', 'LLVM'],
      correctIndex: 1,
      explanation: 'Flutter usa Skia para renderização rápida em todas as plataformas.',
      tier: 1,
    ),
    // Tier 2 - Mobile History
    const Question(
      prompt: 'Qual foi o primeiro smartphone?',
      options: ['iPhone', 'BlackBerry', 'Simon', 'Nokia 9000'],
      correctIndex: 2,
      explanation: 'Simon, lançado em 1992, é considerado o primeiro smartphone.',
      tier: 2,
    ),
    const Question(
      prompt: 'Em que ano foi lançado o primeiro iPhone?',
      options: ['2005', '2007', '2008', '2006'],
      correctIndex: 1,
      explanation: 'Steve Jobs apresentou o iPhone em junho de 2007.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual sistema operacional mobile foi lançado primeiro?',
      options: ['iOS', 'Android', 'Windows Mobile', 'Symbian'],
      correctIndex: 2,
      explanation: 'Windows Mobile foi o primeiro, mas Android foi o primeiro open-source.',
      tier: 2,
    ),
    const Question(
      prompt: 'Quantos cores tinha o iPhone original?',
      options: ['Nenhum (preto e branco)', 'Variante de cinza', '8 cores', '256 cores'],
      correctIndex: 0,
      explanation: 'O iPhone original tinha uma tela monocromática antes do 3G.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual foi a primeira versão do Android?',
      options: ['Android 1.0', 'Android 2.0', 'Android 1.5', 'Android 1.6'],
      correctIndex: 0,
      explanation: 'Android 1.0 foi lançado em setembro de 2008.',
      tier: 2,
    ),
    // Tier 3 - Flutter Advanced
    const Question(
      prompt: 'O que é um StatefulWidget em Flutter?',
      options: [
        'Widget que não muda',
        'Widget que pode mudar de estado durante seu ciclo de vida',
        'Widget importado de pacotes',
        'Widget que só funciona web'
      ],
      correctIndex: 1,
      explanation: 'StatefulWidget pode mudar seu estado interno chamando setState().',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual é o método chamado quando um Widget é criado?',
      options: ['build()', 'initState()', 'dispose()', 'didChangeDependencies()'],
      correctIndex: 1,
      explanation: 'initState() é chamado uma vez quando o State é criado.',
      tier: 3,
    ),
    const Question(
      prompt: 'Para que serve o Provider em Flutter?',
      options: [
        'Gerenciar estado de forma simples e reativa',
        'Fazer requisições HTTP',
        'Desenhar em Canvas',
        'Compilar código'
      ],
      correctIndex: 0,
      explanation: 'Provider é uma biblioteca popular para gerenciamento de estado reativo.',
      tier: 3,
    ),
    const Question(
      prompt: 'O que é Hot Reload em Flutter?',
      options: [
        'Reiniciar a aplicação completamente',
        'Atualizar código sem perder estado do app',
        'Compilar o APK',
        'Sincronizar com servidor'
      ],
      correctIndex: 1,
      explanation: 'Hot Reload permite desenvolvimento rápido injecting código sem reiniciar.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual widget Flutter cria um layout de grade?',
      options: ['GridView', 'Table', 'Row', 'Wrap'],
      correctIndex: 0,
      explanation: 'GridView cria uma grade responsiva de widgets.',
      tier: 3,
    ),
    // Tier 4 - Mobile Evolution
    const Question(
      prompt: 'Quantos anos levou entre o primeiro iPhone e o 5G em smartphones?',
      options: ['10 anos', '12 anos', '13 anos', '15 anos'],
      correctIndex: 2,
      explanation: 'iPhone foi 2007, primeiros 5G phones foram 2020.',
      tier: 4,
    ),
    const Question(
      prompt: 'Qual smartphone foi o primeiro com câmera de 64MP?',
      options: ['Samsung Galaxy S20', 'Mi 9T Pro', 'Samsung Galaxy S9+', 'OnePlus 7'],
      correctIndex: 1,
      explanation: 'Xiaomi Mi 9T Pro foi pioneiro com 64MP sensor principal.',
      tier: 4,
    ),
    const Question(
      prompt: 'Em que ano foi lançado o Android Market (Google Play)?',
      options: ['2008', '2010', '2012', '2014'],
      correctIndex: 0,
      explanation: 'Android Market foi lançado em 2008, rebatizado como Google Play em 2012.',
      tier: 4,
    ),
    const Question(
      prompt: 'Qual foi a primeira linguagem de programação para apps Android?',
      options: ['Java', 'Kotlin', 'C++', 'Python'],
      correctIndex: 0,
      explanation: 'Java era a única opção oficial até Kotlin ser suportado.',
      tier: 4,
    ),
    // Tier 5 - Flutter Architecture
    const Question(
      prompt: 'Qual é a estrutura de camadas do Flutter?',
      options: [
        'Framework, Engine, Embedder',
        'Frontend, Backend, Database',
        'UI, Logic, State',
        'Client, Server, Network'
      ],
      correctIndex: 0,
      explanation: 'Flutter tem Framework (Dart), Engine (C++), e Embedders (iOS/Android).',
      tier: 5,
    ),
    const Question(
      prompt: 'O que é o Skia engine no Flutter?',
      options: [
        'Motor JavaScript',
        'Mecanismo de renderização gráfica 2D/3D',
        'Compilador Dart',
        'Banco de dados local'
      ],
      correctIndex: 1,
      explanation: 'Skia é responsável pela renderização rápida de gráficos.',
      tier: 5,
    ),
    const Question(
      prompt: 'Qual padrão arquitetural Flutter recomenda para apps complexos?',
      options: ['MVC', 'BLoC', 'MVVM', 'Todos os anteriores'],
      correctIndex: 3,
      explanation: 'Flutter é flexível e suporta vários padrões, BLoC é popular.',
      tier: 5,
    ),
    const Question(
      prompt: 'O que é a árvore de widgets em Flutter?',
      options: [
        'Uma estrutura de dados em árvore que representa a UI',
        'Um banco de dados',
        'Uma biblioteca de componentes',
        'Um framework CSS'
      ],
      correctIndex: 0,
      explanation: 'A árvore de widgets descreve toda a UI da aplicação recursivamente.',
      tier: 5,
    ),
    const Question(
      prompt: 'Em que linguagem é escrito o Flutter Engine?',
      options: ['Dart', 'C++', 'Java', 'Swift'],
      correctIndex: 1,
      explanation: 'O Engine é implementado principalmente em C++ para performance.',
      tier: 5,
    ),
  ];

  static Question forFloor(int floor) {
    final difficulty = _calculateDifficulty(floor);
    final pool = _all.where((q) => q.tier <= difficulty).toList()..shuffle();
    return pool.first;
  }

  static int _calculateDifficulty(int floor) {
    if (floor <= 3) return 1;
    if (floor <= 6) return 2;
    if (floor <= 10) return 3;
    if (floor <= 15) return 4;
    return 5;
  }
}

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────

class DT {
  static const bg      = Color(0xFF08080E);
  static const surface = Color(0xFF111118);
  static const border  = Color(0xFF22222E);
  static const gold    = Color(0xFFCCA830);
  static const goldL   = Color(0xFFEDD97A);
  static const violet  = Color(0xFF7C5CDB);
  static const cyan    = Color(0xFF5BB8D4);
  static const red     = Color(0xFFCF4545);
  static const green   = Color(0xFF3BAA78);
  static const amber   = Color(0xFFD4882A);
  static const muted   = Color(0xFF55556A);
  static const purple  = Color(0xFF9B6DD4);
  static const blue    = Color(0xFF4A9FD8);

  static const caption = TextStyle(
    color: Color(0xFF6E6E88),
    fontSize: 12,
    letterSpacing: 0.3,
    height: 1.4,
  );
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

// ─────────────────────────────────────────────────────────────
//  GAME CONTROLLER
// ─────────────────────────────────────────────────────────────

class GameController extends StatefulWidget {
  const GameController({super.key});
  @override
  State<GameController> createState() => _GameControllerState();
}

class _GameControllerState extends State<GameController> {
  GameState _state = GameState.menu;
  final _player = PlayerStats();

  void _startRun() {
    _player.startRun();
    setState(() => _state = GameState.dungeon);
  }

  void _openSkillTree() => setState(() => _state = GameState.skillTree);

  void _onDied() {
    if (_player.floor > _player.checkpointFloor) {
      _player.checkpointFloor = _player.floor;
    }
    _player.shards += _player.runShards;
    setState(() => _state = GameState.gameOver);
  }

  void _onFloorCleared(int earned, int expEarned) {
    _player.runShards += earned;
    _player.gainExp(expEarned);

    if (_player.floor > _player.highestFloor) {
      _player.highestFloor = _player.floor;
    }

    _player.floor++;
    if (_player.floor > 20) {
      _player.shards += _player.runShards;
      if (_player.floor > _player.checkpointFloor) {
        _player.checkpointFloor = _player.floor;
      }
      setState(() => _state = GameState.victory);
    } else {
      setState(() {});
    }
  }

  void _onHpChanged(int hp) => setState(() => _player.currentHp = hp);

  @override
  Widget build(BuildContext context) => switch (_state) {
    GameState.menu => MenuScreen(
      player: _player,
      onStart: _startRun,
      onSkillTree: _player.shards > 0 ? _openSkillTree : null,
    ),
    GameState.skillTree => SkillTreeScreen(
      player: _player,
      onBack: () => setState(() => _state = GameState.menu),
    ),
    GameState.dungeon => DungeonScreen(
      player: _player,
      onDied: _onDied,
      onFloorCleared: _onFloorCleared,
      onHpChanged: _onHpChanged,
    ),
    GameState.gameOver => GameOverScreen(
      player: _player,
      onSkillTree: _openSkillTree,
      onRestart: _startRun,
    ),
    GameState.victory => VictoryScreen(
      player: _player,
      onRestart: _startRun,
    ),
  };
}

// ─────────────────────────────────────────────────────────────
//  MENU SCREEN
// ─────────────────────────────────────────────────────────────

class MenuScreen extends StatefulWidget {
  final PlayerStats player;
  final VoidCallback onStart;
  final VoidCallback? onSkillTree;

  const MenuScreen({
    super.key,
    required this.player,
    required this.onStart,
    this.onSkillTree,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.3,
            colors: [Color(0xFF160F28), DT.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) => Opacity(
                      opacity: _glow.value,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DT.gold.withOpacity(0.35),
                            width: 1.5,
                          ),
                          color: DT.gold.withOpacity(0.07),
                        ),
                        child: const Icon(
                          Icons.castle_rounded,
                          size: 44,
                          color: DT.gold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [DT.gold, DT.goldL, DT.gold],
                    ).createShader(r),
                    child: const Text(
                      'DUNGEON\nDO ERUDITO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'O saber é a única arma que importa',
                    style: TextStyle(
                      color: DT.muted,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _UpgradeBadges(player: widget.player),
                  if (widget.player.vigorLevel > 0 ||
                      widget.player.siphonLevel > 0 ||
                      widget.player.oracleLevel > 0 ||
                      widget.player.shieldLevel > 0 ||
                      widget.player.armorLevel > 0 ||
                      widget.player.focusLevel > 0 ||
                      widget.player.wealthLevel > 0)
                    const SizedBox(height: 24),
                  _LevelBar(player: widget.player),
                  const SizedBox(height: 24),
                  _PrimaryBtn(
                    icon: Icons.arrow_downward_rounded,
                    label: 'DESCER AO CALABOUÇO',
                    color: DT.gold,
                    onTap: widget.onStart,
                  ),
                  if (widget.onSkillTree != null) ...[
                    const SizedBox(height: 12),
                    _PrimaryBtn(
                      icon: Icons.account_tree_outlined,
                      label: 'ÁRVORE DE HABILIDADES',
                      color: DT.violet,
                      onTap: widget.onSkillTree!,
                    ),
                  ],
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MiniStat(
                        icon: Icons.favorite_rounded,
                        iconColor: DT.red,
                        label: '${widget.player.maxHp} vidas',
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        icon: Icons.diamond_outlined,
                        iconColor: DT.cyan,
                        label: '${widget.player.shards} fragmentos',
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        icon: Icons.trending_up_rounded,
                        iconColor: DT.blue,
                        label: 'Andar ${widget.player.highestFloor}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  final PlayerStats player;
  const _LevelBar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DT.surface,
        border: Border.all(color: DT.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: DT.blue),
                  const SizedBox(width: 6),
                  Text(
                    'Nível ${player.level}',
                    style: const TextStyle(
                      color: DT.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${player.experience}/${player.expToNextLevel} XP',
                style: DT.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: player.expProgress,
              backgroundColor: DT.blue.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(DT.blue.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeBadges extends StatelessWidget {
  final PlayerStats player;
  const _UpgradeBadges({required this.player});

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, Color color})>[];
    if (player.vigorLevel > 0)
      items.add((icon: Icons.favorite_rounded, label: 'Vigor ${player.vigorLevel}', color: DT.red));
    if (player.siphonLevel > 0)
      items.add((icon: Icons.water_drop_rounded, label: 'Sifão ${player.siphonLevel}', color: DT.green));
    if (player.oracleLevel > 0)
      items.add((icon: Icons.visibility_rounded, label: 'Oráculo', color: DT.amber));
    if (player.shieldLevel > 0)
      items.add((icon: Icons.shield_rounded, label: 'Escudo', color: DT.violet));
    if (player.armorLevel > 0)
      items.add((icon: Icons.security_rounded, label: 'Armadura', color: DT.purple));
    if (player.focusLevel > 0)
      items.add((icon: Icons.psychology_rounded, label: 'Foco', color: DT.blue));
    if (player.wealthLevel > 0)
      items.add((icon: Icons.attach_money_rounded, label: 'Riqueza', color: DT.gold));

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items
          .map((b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: b.color.withOpacity(0.1),
          border: Border.all(color: b.color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(b.icon, size: 11, color: b.color),
            const SizedBox(width: 5),
            Text(
              b.label,
              style: TextStyle(
                color: b.color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          border: Border.all(color: color.withOpacity(0.55), width: 1.2),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 18, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _MiniStat({required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor.withOpacity(0.65)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: DT.muted, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SKILL TREE SCREEN (ENHANCED SHOP)
// ─────────────────────────────────────────────────────────────

class SkillTreeScreen extends StatefulWidget {
  final PlayerStats player;
  final VoidCallback onBack;

  const SkillTreeScreen({super.key, required this.player, required this.onBack});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  PlayerStats get p => widget.player;

  int get _vigorCost  => (p.vigorLevel  + 1) * 3;
  int get _siphonCost => (p.siphonLevel + 1) * 4;
  int get _armorCost  => (p.armorLevel + 1) * 5;
  int get _focusCost  => (p.focusLevel + 1) * 6;
  int get _wealthCost => (p.wealthLevel + 1) * 8;

  void _buy(String id) {
    setState(() {
      switch (id) {
        case 'vigor':
          if (p.vigorLevel < 5 && p.shards >= _vigorCost) {
            p.shards -= _vigorCost;
            p.vigorLevel++;
            p.maxHp = 3 + p.vigorLevel;
          }
        case 'siphon':
          if (p.siphonLevel < 3 && p.shards >= _siphonCost) {
            p.shards -= _siphonCost;
            p.siphonLevel++;
          }
        case 'oracle':
          if (p.oracleLevel < 1 && p.shards >= 8) {
            p.shards -= 8;
            p.oracleLevel = 1;
          }
        case 'shield':
          if (p.shieldLevel < 1 && p.shards >= 10) {
            p.shards -= 10;
            p.shieldLevel = 1;
          }
        case 'armor':
          if (p.armorLevel < 3 && p.shards >= _armorCost) {
            p.shards -= _armorCost;
            p.armorLevel++;
          }
        case 'focus':
          if (p.focusLevel < 2 && p.shards >= _focusCost) {
            p.shards -= _focusCost;
            p.focusLevel++;
          }
        case 'wealth':
          if (p.wealthLevel < 3 && p.shards >= _wealthCost) {
            p.shards -= _wealthCost;
            p.wealthLevel++;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0.6),
            radius: 1.1,
            colors: [Color(0xFF0A1520), DT.bg],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    _IconBtn(
                      icon: Icons.arrow_back_rounded,
                      onTap: widget.onBack,
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.account_tree_outlined, color: DT.gold, size: 17),
                    const SizedBox(width: 8),
                    const Text(
                      'HABILIDADES',
                      style: TextStyle(
                        color: DT.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.diamond_outlined, color: DT.cyan, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      '${p.shards}',
                      style: const TextStyle(
                        color: DT.cyan,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Text(
                  'Os fragmentos persistem mesmo depois da morte. Mude-se após andar 10!',
                  style: DT.caption.copyWith(fontSize: 11),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _SkillCard(
                      icon: Icons.favorite_rounded,
                      color: DT.red,
                      name: 'Vigor do Erudito',
                      description: 'Aumenta vida máxima em +1 por nível.',
                      level: p.vigorLevel,
                      maxLevel: 5,
                      cost: _vigorCost,
                      canBuy: p.vigorLevel < 5 && p.shards >= _vigorCost,
                      onBuy: () => _buy('vigor'),
                    ),
                    const SizedBox(height: 10),
                    _SkillCard(
                      icon: Icons.water_drop_rounded,
                      color: DT.green,
                      name: 'Sifão de Vida',
                      description: 'Respostas corretas curam +1 vida por nível.',
                      level: p.siphonLevel,
                      maxLevel: 3,
                      cost: _siphonCost,
                      canBuy: p.siphonLevel < 3 && p.shards >= _siphonCost,
                      onBuy: () => _buy('siphon'),
                    ),
                    const SizedBox(height: 10),
                    _SkillCard(
                      icon: Icons.visibility_rounded,
                      color: DT.amber,
                      name: 'Visão do Oráculo',
                      description: 'Uma opção falsa some de cada enigma.',
                      level: p.oracleLevel,
                      maxLevel: 1,
                      cost: 8,
                      canBuy: p.oracleLevel < 1 && p.shards >= 8,
                      onBuy: () => _buy('oracle'),
                    ),
                    const SizedBox(height: 10),
                    _SkillCard(
                      icon: Icons.shield_rounded,
                      color: DT.violet,
                      name: 'Escudo Arcano',
                      description: 'Absorve o primeiro erro a cada descida.',
                      level: p.shieldLevel,
                      maxLevel: 1,
                      cost: 10,
                      canBuy: p.shieldLevel < 1 && p.shards >= 10,
                      onBuy: () => _buy('shield'),
                    ),
                    const SizedBox(height: 10),
                    _SkillCard(
                      icon: Icons.security_rounded,
                      color: DT.purple,
                      name: 'Armadura do Conhecimento',
                      description: 'Reduz dano em -1 por nível (máx. 1).',
                      level: p.armorLevel,
                      maxLevel: 3,
                      cost: _armorCost,
                      canBuy: p.armorLevel < 3 && p.shards >= _armorCost,
                      onBuy: () => _buy('armor'),
                    ),
                    const SizedBox(height: 10),
                    _SkillCard(
                      icon: Icons.psychology_rounded,
                      color: DT.blue,
                      name: 'Foco Mental',
                      description: 'Aumenta XP ganho em 25% por nível.',
                      level: p.focusLevel,
                      maxLevel: 2,
                      cost: _focusCost,
                      canBuy: p.focusLevel < 2 && p.shards >= _focusCost,
                      onBuy: () => _buy('focus'),
                    ),
                    const SizedBox(height: 10),
                    _SkillCard(
                      icon: Icons.attach_money_rounded,
                      color: DT.gold,
                      name: 'Ganância do Tesouro',
                      description: 'Aumenta fragmentos ganhos em 25% por nível.',
                      level: p.wealthLevel,
                      maxLevel: 3,
                      cost: _wealthCost,
                      canBuy: p.wealthLevel < 3 && p.shards >= _wealthCost,
                      onBuy: () => _buy('wealth'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name, description;
  final int level, maxLevel, cost;
  final bool canBuy;
  final VoidCallback onBuy;

  const _SkillCard({
    required this.icon,
    required this.color,
    required this.name,
    required this.description,
    required this.level,
    required this.maxLevel,
    required this.cost,
    required this.canBuy,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final maxed = level >= maxLevel;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DT.surface,
        border: Border.all(
          color: maxed ? color.withOpacity(0.45) : DT.border,
          width: maxed ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: maxed
            ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 14)]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...List.generate(
                      maxLevel,
                          (i) => Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: i < level ? color : Colors.white10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: DT.caption),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (maxed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'MAX',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: canBuy ? onBuy : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: canBuy
                      ? color.withOpacity(0.12)
                      : Colors.white.withOpacity(0.03),
                  border: Border.all(
                    color: canBuy ? color.withOpacity(0.6) : Colors.white10,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.diamond_outlined,
                      size: 12,
                      color: canBuy ? color : DT.muted,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$cost',
                      style: TextStyle(
                        color: canBuy ? color : DT.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DUNGEON SCREEN
// ─────────────────────────────────────────────────────────────

class DungeonScreen extends StatefulWidget {
  final PlayerStats player;
  final VoidCallback onDied;
  final Function(int, int) onFloorCleared;
  final Function(int) onHpChanged;

  const DungeonScreen({
    super.key,
    required this.player,
    required this.onDied,
    required this.onFloorCleared,
    required this.onHpChanged,
  });

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen>
    with TickerProviderStateMixin {
  late Question _q;
  late List<String> _opts;
  late List<bool?> _states;
  bool _answered = false;
  String _feedback = '';
  bool _feedbackOk = false;
  IconData _feedbackIcon = Icons.check_circle_rounded;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _load();
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _load() {
    _q = QuestionBank.forFloor(widget.player.floor);
    _opts = List.from(_q.options);

    if (widget.player.hasOracle) {
      final wrong = [
        for (int i = 0; i < _opts.length; i++)
          if (i != _q.correctIndex) i,
      ]..shuffle();
      if (wrong.isNotEmpty) _opts[wrong.first] = '';
    }

    _states = List.filled(_opts.length, null);
    _answered = false;
    _feedback = '';
  }

  PlayerStats get p => widget.player;

  Color get _accent {
    final f = p.floor;
    if (f <= 3) return DT.green;
    if (f <= 6) return DT.amber;
    if (f <= 10) return DT.red;
    if (f <= 15) return DT.violet;
    return DT.blue;
  }

  IconData get _floorIcon {
    final f = p.floor;
    if (f <= 3) return Icons.forest_rounded;
    if (f <= 6) return Icons.local_fire_department_rounded;
    if (f <= 10) return Icons.warning_amber_rounded;
    if (f <= 15) return Icons.remove_red_eye_rounded;
    return Icons.psychology_rounded;
  }

  int _calculateReward() {
    int base = max(1, p.floor ~/ 2 + 1);
    if (p.wealthLevel > 0) {
      base = (base * (1 + 0.25 * p.wealthLevel)).toInt();
    }
    return base;
  }

  int _calculateExp() {
    int base = 10 * p.floor;
    if (p.focusLevel > 0) {
      base = (base * (1 + 0.25 * p.focusLevel)).toInt();
    }
    return base;
  }

  void _answer(int idx) {
    if (_answered || _opts[idx].isEmpty) return;

    setState(() {
      _answered = true;
      final ok = idx == _q.correctIndex;

      if (ok) {
        _states[idx] = true;
        final earned = _calculateReward();
        final exp = _calculateExp();
        _feedbackOk = true;
        _feedbackIcon = Icons.check_circle_rounded;
        _feedback = '+$earned fragmentos  +$exp XP  —  Correto.';

        if (p.hasSiphon && p.currentHp < p.maxHp) {
          p.currentHp = min(p.maxHp, p.currentHp + p.siphonLevel);
          widget.onHpChanged(p.currentHp);
          _feedback += '  Vida recuperada.';
        }

        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!mounted) return;
          widget.onFloorCleared(earned, exp);
          _entryCtrl.reset();
          setState(_load);
          _entryCtrl.forward();
        });
      } else {
        _states[idx] = false;
        _states[_q.correctIndex] = true;

        int damage = 1;
        if (p.hasArmor) {
          damage = max(0, damage - min(1, p.armorLevel));
        }

        if (p.shieldReady) {
          p.shieldReady = false;
          _feedbackOk = true;
          _feedbackIcon = Icons.shield_rounded;
          _feedback = 'Escudo Arcano ativado  —  o golpe foi absorvido.';
        } else {
          p.currentHp -= damage;
          widget.onHpChanged(p.currentHp);
          _feedbackOk = false;
          _feedbackIcon = Icons.close_rounded;
          _feedback = 'Errado.  ${_q.explanation}';
          _shakeCtrl.forward(from: 0);
        }

        Future.delayed(const Duration(milliseconds: 2400), () {
          if (!mounted) return;
          if (p.currentHp <= 0) {
            widget.onDied();
          } else {
            _entryCtrl.reset();
            setState(_load);
            _entryCtrl.forward();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          sin(_shakeAnim.value * pi * 9) * 9 * (1 - _shakeAnim.value),
          0,
        ),
        child: child,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.6),
              radius: 1.4,
              colors: [_accent.withOpacity(0.11), DT.bg],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _TopBar(player: p, accent: _accent),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_floorIcon, size: 13, color: _accent),
                      const SizedBox(width: 7),
                      Text(
                        'ANDAR ${p.floor}',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _entryAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.07),
                        end: Offset.zero,
                      ).animate(_entryAnim),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: DT.surface,
                                border: Border.all(
                                  color: _accent.withOpacity(0.22),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withOpacity(0.06),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: Text(
                                _q.prompt,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            ...List.generate(_opts.length, (i) {
                              if (_opts[i].isEmpty) return const SizedBox.shrink();
                              return _ChoiceBtn(
                                text: _opts[i],
                                state: _states[i],
                                accent: _accent,
                                onTap: () => _answer(i),
                              );
                            }),
                            const SizedBox(height: 14),
                            AnimatedOpacity(
                              opacity: _feedback.isEmpty ? 0 : 1,
                              duration: const Duration(milliseconds: 220),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: (_feedbackOk ? DT.green : DT.red)
                                      .withOpacity(0.1),
                                  border: Border.all(
                                    color: (_feedbackOk ? DT.green : DT.red)
                                        .withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1),
                                      child: Icon(
                                        _feedbackIcon,
                                        size: 15,
                                        color: _feedbackOk ? DT.green : DT.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _feedback,
                                        style: TextStyle(
                                          color: _feedbackOk ? DT.green : DT.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final PlayerStats player;
  final Color accent;
  const _TopBar({required this.player, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Row(
            children: List.generate(player.maxHp, (i) {
              final filled = i < player.currentHp;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    filled
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 21,
                    color: filled ? DT.red : DT.muted,
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          if (player.hasShield)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: AnimatedOpacity(
                opacity: player.shieldReady ? 1.0 : 0.2,
                duration: const Duration(milliseconds: 400),
                child: const Icon(Icons.shield_rounded, size: 20, color: DT.violet),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: DT.cyan.withOpacity(0.07),
              border: Border.all(color: DT.cyan.withOpacity(0.22)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond_outlined, size: 12, color: DT.cyan),
                const SizedBox(width: 5),
                Text(
                  '${player.runShards}',
                  style: const TextStyle(
                    color: DT.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceBtn extends StatelessWidget {
  final String text;
  final bool? state;
  final Color accent;
  final VoidCallback onTap;

  const _ChoiceBtn({
    required this.text,
    required this.state,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color bg;
    final Color fg;
    final IconData? trailing;

    if (state == null) {
      border = accent.withOpacity(0.2);
      bg = DT.surface;
      fg = const Color(0xFFCDCDE0);
      trailing = null;
    } else if (state == true) {
      border = DT.green;
      bg = DT.green.withOpacity(0.1);
      fg = DT.green;
      trailing = Icons.check_rounded;
    } else {
      border = DT.red;
      bg = DT.red.withOpacity(0.1);
      fg = DT.red;
      trailing = Icons.close_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.2),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(trailing, size: 15, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GAME OVER SCREEN
// ─────────────────────────────────────────────────────────────

class GameOverScreen extends StatelessWidget {
  final PlayerStats player;
  final VoidCallback onSkillTree;
  final VoidCallback onRestart;

  const GameOverScreen({
    super.key,
    required this.player,
    required this.onSkillTree,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF1C0808), DT.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DT.red.withOpacity(0.1),
                      border: Border.all(color: DT.red.withOpacity(0.35)),
                    ),
                    child: const Icon(
                      Icons.heart_broken_rounded,
                      size: 36,
                      color: DT.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'VOCÊ CAIU',
                    style: TextStyle(
                      color: DT.red,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O calabouço não perdoa hesitação.',
                    style: TextStyle(
                      color: DT.muted,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _StatRow(
                    icon: Icons.stairs_rounded,
                    color: DT.amber,
                    label: 'Andar alcançado',
                    value: '${player.floor}',
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    icon: Icons.diamond_outlined,
                    color: DT.cyan,
                    label: 'Fragmentos desta run',
                    value: '+${player.runShards}',
                  ),
                  _StatRow(
                    icon: Icons.savings_rounded,
                    color: DT.gold,
                    label: 'Total acumulado',
                    value: '${player.shards}',
                  ),
                  _StatRow(
                    icon: Icons.trending_up_rounded,
                    color: DT.blue,
                    label: 'Checkpoint',
                    value: 'Andar ${player.checkpointFloor}',
                  ),
                  const SizedBox(height: 40),
                  _PrimaryBtn(
                    icon: Icons.account_tree_outlined,
                    label: 'GASTAR FRAGMENTOS',
                    color: DT.violet,
                    onTap: onSkillTree,
                  ),
                  const SizedBox(height: 12),
                  _PrimaryBtn(
                    icon: Icons.refresh_rounded,
                    label: 'TENTAR NOVAMENTE',
                    color: DT.red,
                    onTap: onRestart,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;

  const _StatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: DT.muted, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  VICTORY SCREEN
// ─────────────────────────────────────────────────────────────

class VictoryScreen extends StatelessWidget {
  final PlayerStats player;
  final VoidCallback onRestart;

  const VictoryScreen({super.key, required this.player, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF0F1C0A), DT.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DT.gold.withOpacity(0.1),
                      border: Border.all(color: DT.gold.withOpacity(0.4)),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 38,
                      color: DT.gold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [DT.gold, DT.goldL, DT.gold],
                    ).createShader(r),
                    child: const Text(
                      'VITÓRIA',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O calabouço foi conquistado.\nPor enquanto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DT.muted,
                      fontSize: 12,
                      letterSpacing: 0.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _StatRow(
                    icon: Icons.diamond_outlined,
                    color: DT.cyan,
                    label: 'Fragmentos ganhos',
                    value: '+${player.runShards}',
                  ),
                  _StatRow(
                    icon: Icons.savings_rounded,
                    color: DT.gold,
                    label: 'Total acumulado',
                    value: '${player.shards}',
                  ),
                  _StatRow(
                    icon: Icons.star_rounded,
                    color: DT.blue,
                    label: 'Nível',
                    value: '${player.level}',
                  ),
                  const SizedBox(height: 40),
                  _PrimaryBtn(
                    icon: Icons.arrow_downward_rounded,
                    label: 'DESCER NOVAMENTE',
                    color: DT.gold,
                    onTap: onRestart,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  WIDGET AUXILIAR
// ─────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: DT.border),
          borderRadius: BorderRadius.circular(6),
          color: DT.surface,
        ),
        child: Icon(icon, color: Colors.white54, size: 18),
      ),
    );
  }
}
