import 'dart:math';
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
  int vigorLevel;
  int siphonLevel;
  int oracleLevel;
  int shieldLevel;
  bool shieldReady;

  PlayerStats({
    this.maxHp = 3,
    this.currentHp = 3,
    this.shards = 0,
    this.runShards = 0,
    this.floor = 1,
    this.vigorLevel = 0,
    this.siphonLevel = 0,
    this.oracleLevel = 0,
    this.shieldLevel = 0,
    this.shieldReady = false,
  });

  bool get hasSiphon => siphonLevel > 0;
  bool get hasOracle => oracleLevel > 0;
  bool get hasShield => shieldLevel > 0;

  void startRun() {
    currentHp = maxHp;
    floor = 1;
    runShards = 0;
    shieldReady = hasShield;
  }
}

// ─────────────────────────────────────────────────────────────
//  BANCO DE QUESTÕES
// ─────────────────────────────────────────────────────────────

class QuestionBank {
  static final List<Question> _all = [
    const Question(
      prompt: 'Quanto é 7 × 8?',
      options: ['54', '56', '63', '48'],
      correctIndex: 1,
      explanation: '7 × 8 = 56.',
      tier: 1,
    ),
    const Question(
      prompt: 'Qual é o maior planeta do Sistema Solar?',
      options: ['Saturno', 'Netuno', 'Júpiter', 'Urano'],
      correctIndex: 2,
      explanation: 'Júpiter tem massa maior que a de todos os outros planetas somados.',
      tier: 1,
    ),
    const Question(
      prompt: 'Quantos lados tem um hexágono?',
      options: ['5', '7', '8', '6'],
      correctIndex: 3,
      explanation: '"Hex" vem do grego e significa seis.',
      tier: 1,
    ),
    const Question(
      prompt: 'Em que continente fica o Egito?',
      options: ['Ásia', 'Europa', 'África', 'Oriente Médio'],
      correctIndex: 2,
      explanation: 'O Egito ocupa o nordeste do continente africano.',
      tier: 1,
    ),
    const Question(
      prompt: 'Qual é a capital do Brasil?',
      options: ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador'],
      correctIndex: 2,
      explanation: 'Brasília é capital federal desde abril de 1960.',
      tier: 1,
    ),
    const Question(
      prompt: 'Quem escreveu Dom Casmurro?',
      options: ['José de Alencar', 'Machado de Assis', 'Clarice Lispector', 'Carlos Drummond'],
      correctIndex: 1,
      explanation: 'Machado de Assis publicou Dom Casmurro em 1899.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual gás as plantas absorvem durante a fotossíntese?',
      options: ['Oxigênio', 'Nitrogênio', 'Dióxido de Carbono', 'Hidrogênio'],
      correctIndex: 2,
      explanation: 'As plantas absorvem CO₂ e liberam O₂ como subproduto.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual é o menor país do mundo em área?',
      options: ['Mônaco', 'San Marino', 'Vaticano', 'Liechtenstein'],
      correctIndex: 2,
      explanation: 'O Vaticano tem apenas 0,44 km².',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual é a fórmula química da água?',
      options: ['H₃O', 'HO₂', 'H₂O', 'OH'],
      correctIndex: 2,
      explanation: 'Dois átomos de hidrogênio e um de oxigênio formam H₂O.',
      tier: 3,
    ),
    const Question(
      prompt: 'Em que ano começou a Revolução Francesa?',
      options: ['1776', '1789', '1804', '1815'],
      correctIndex: 1,
      explanation: 'A queda da Bastilha em julho de 1789 marcou o início.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual é o elemento mais abundante no universo?',
      options: ['Oxigênio', 'Carbono', 'Hélio', 'Hidrogênio'],
      correctIndex: 3,
      explanation: 'O hidrogênio representa cerca de 75% da matéria bariônica.',
      tier: 3,
    ),
    const Question(
      prompt: 'Quantos ossos tem o esqueleto humano adulto?',
      options: ['186', '206', '256', '306'],
      correctIndex: 1,
      explanation: 'Adultos têm 206 ossos; bebês nascem com aproximadamente 270.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual é o símbolo do ouro na tabela periódica?',
      options: ['Go', 'Or', 'Ou', 'Au'],
      correctIndex: 3,
      explanation: '"Au" vem do latim Aurum, número atômico 79.',
      tier: 3,
    ),
    const Question(
      prompt: 'O que estuda a sismologia?',
      options: ['Vulcões', 'Terremotos', 'Oceanos', 'Clima'],
      correctIndex: 1,
      explanation: 'A sismologia analisa terremotos e a propagação de ondas sísmicas.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual filósofo cunhou "Penso, logo existo"?',
      options: ['Sócrates', 'Platão', 'Aristóteles', 'René Descartes'],
      correctIndex: 3,
      explanation: '"Cogito, ergo sum" aparece no Discurso do Método de 1637.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual é a velocidade aproximada da luz no vácuo?',
      options: ['300 000 km/s', '150 000 km/s', '450 000 km/s', '200 000 km/s'],
      correctIndex: 0,
      explanation: '≈ 299 792 km/s, arredondado para 300 000 km/s.',
      tier: 4,
    ),
    const Question(
      prompt: 'O que define um número primo?',
      options: [
        'Divisível apenas por 1 e por ele mesmo',
        'Divisível por 2',
        'Possui raiz quadrada exata',
        'Múltiplo de 3',
      ],
      correctIndex: 0,
      explanation: 'Números primos têm exatamente dois divisores naturais.',
      tier: 4,
    ),
    const Question(
      prompt: 'Como as estrelas produzem energia?',
      options: ['Fissão nuclear', 'Fusão nuclear', 'Combustão', 'Oxidação'],
      correctIndex: 1,
      explanation: 'Núcleos de hidrogênio se fundem em hélio, liberando enorme energia.',
      tier: 4,
    ),
    const Question(
      prompt: 'O que carrega as instruções genéticas no DNA?',
      options: ['Proteínas', 'Lipídeos', 'Sequência de bases nitrogenadas', 'Carboidratos'],
      correctIndex: 2,
      explanation: 'A ordem das bases A, T, G, C codifica todas as informações genéticas.',
      tier: 5,
    ),
    const Question(
      prompt: 'No Teorema de Pitágoras, qual relação vale para triângulos retângulos?',
      options: ['a + b = c', 'a² + b² = c²', 'a² × b² = c²', 'a³ + b³ = c³'],
      correctIndex: 1,
      explanation: 'c é a hipotenusa e a, b são os catetos. Pitágoras, séc. VI a.C.',
      tier: 5,
    ),
    const Question(
      prompt: 'Qual lei de Newton descreve que toda ação gera reação igual e oposta?',
      options: ['Primeira Lei', 'Segunda Lei', 'Terceira Lei', 'Lei da Gravitação Universal'],
      correctIndex: 2,
      explanation: 'O Princípio da Ação e Reação é a Terceira Lei de Newton.',
      tier: 5,
    ),
  ];

  static Question forFloor(int floor) {
    final maxTier = floor <= 2 ? 1 : floor <= 4 ? 3 : floor <= 7 ? 4 : 5;
    final pool = _all.where((q) => q.tier <= maxTier).toList()..shuffle();
    return pool.first;
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
    _player.shards += _player.runShards;
    setState(() => _state = GameState.gameOver);
  }

  void _onFloorCleared(int earned) {
    _player.runShards += earned;
    _player.floor++;
    if (_player.floor > 10) {
      _player.shards += _player.runShards;
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
                  // Ícone central
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
                  // Título
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
                  // Badges de upgrades ativos
                  _UpgradeBadges(player: widget.player),
                  if (widget.player.vigorLevel > 0 ||
                      widget.player.siphonLevel > 0 ||
                      widget.player.oracleLevel > 0 ||
                      widget.player.shieldLevel > 0)
                    const SizedBox(height: 24),
                  // Botões
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
                  // Rodapé de stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MiniStat(
                        icon: Icons.favorite_rounded,
                        iconColor: DT.red,
                        label: '${widget.player.maxHp} vidas',
                      ),
                      const SizedBox(width: 24),
                      _MiniStat(
                        icon: Icons.diamond_outlined,
                        iconColor: DT.cyan,
                        label: '${widget.player.shards} fragmentos',
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
//  SKILL TREE SCREEN
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

  void _buy(String id) {
    setState(() {
      switch (id) {
        case 'vigor':
          if (p.vigorLevel < 3 && p.shards >= _vigorCost) {
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
                  'Os fragmentos persistem mesmo depois da morte.',
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
                      description:
                      'Seu corpo aprende a suportar mais punições. Aumenta a vida máxima em +1.',
                      level: p.vigorLevel,
                      maxLevel: 3,
                      cost: _vigorCost,
                      canBuy: p.vigorLevel < 3 && p.shards >= _vigorCost,
                      onBuy: () => _buy('vigor'),
                    ),
                    const SizedBox(height: 10),
                    _SkillCard(
                      icon: Icons.water_drop_rounded,
                      color: DT.green,
                      name: 'Sifão de Vida',
                      description:
                      'Respostas corretas convertem o conhecimento absorvido em cura.',
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
                      description:
                      'Enxerga através das mentiras. Uma opção falsa some de cada enigma.',
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
                      description:
                      'Absorve o impacto do primeiro erro a cada descida ao calabouço.',
                      level: p.shieldLevel,
                      maxLevel: 1,
                      cost: 10,
                      canBuy: p.shieldLevel < 1 && p.shards >= 10,
                      onBuy: () => _buy('shield'),
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
  final Function(int) onFloorCleared;
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
    if (f <= 2) return DT.green;
    if (f <= 4) return DT.amber;
    if (f <= 7) return DT.red;
    return DT.violet;
  }

  IconData get _floorIcon {
    final f = p.floor;
    if (f <= 2) return Icons.forest_rounded;
    if (f <= 4) return Icons.local_fire_department_rounded;
    if (f <= 7) return Icons.warning_amber_rounded;
    return Icons.remove_red_eye_rounded;
  }

  void _answer(int idx) {
    if (_answered || _opts[idx].isEmpty) return;

    setState(() {
      _answered = true;
      final ok = idx == _q.correctIndex;

      if (ok) {
        _states[idx] = true;
        final earned = max(1, p.floor ~/ 2 + 1);
        _feedbackOk = true;
        _feedbackIcon = Icons.check_circle_rounded;
        _feedback = '+$earned fragmentos  —  Correto.';

        if (p.hasSiphon && p.currentHp < p.maxHp) {
          p.currentHp = min(p.maxHp, p.currentHp + p.siphonLevel);
          widget.onHpChanged(p.currentHp);
          _feedback += '  Vida recuperada.';
        }

        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!mounted) return;
          widget.onFloorCleared(earned);
          _entryCtrl.reset();
          setState(_load);
          _entryCtrl.forward();
        });
      } else {
        _states[idx] = false;
        _states[_q.correctIndex] = true;

        if (p.shieldReady) {
          p.shieldReady = false;
          _feedbackOk = true;
          _feedbackIcon = Icons.shield_rounded;
          _feedback = 'Escudo Arcano ativado  —  o golpe foi absorvido.';
        } else {
          p.currentHp--;
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
                // Indicador de andar
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
                // Área de jogo
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
                            // Caixa da pergunta
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
                            // Opções
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
                            // Feedback
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
          // Corações
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
          // Escudo
          if (player.hasShield)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: AnimatedOpacity(
                opacity: player.shieldReady ? 1.0 : 0.2,
                duration: const Duration(milliseconds: 400),
                child: const Icon(Icons.shield_rounded, size: 20, color: DT.violet),
              ),
            ),
          // Fragmentos da run
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