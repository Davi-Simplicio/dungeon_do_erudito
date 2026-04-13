import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/design_tokens.dart';
import '../../models/player_stats.dart';
import '../../models/question.dart';

class DungeonScreen extends StatefulWidget {
  final PlayerStats player;
  final VoidCallback onDied;
  final Function(int, int, Chest?, bool) onFloorCleared;
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
    _q = QuestionBank.forFloor(widget.player.floor, widget.player.usedQuestionsThisRun);
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
    int base = max(1, p.floor ~/ 3);
    if (p.wealthLevel > 0) {
      base = (base * (1 + 0.30 * p.wealthLevel)).toInt();
    }
    return max(1, base);
  }

  int _calculateExp() {
    int base = 15 * p.floor;
    if (p.focusLevel > 0) {
      base = (base * (1 + 0.25 * p.focusLevel)).toInt();
    }
    return base;
  }

  Chest? _getChestReward() {
    final roll = Random().nextDouble();
    final floor = p.floor;

    if (roll < 0.15) {
      return Chest.legendary(floor);
    } else if (roll < 0.35) {
      return Chest.epic(floor);
    } else if (roll < 0.60) {
      return Chest.rare(floor);
    } else if (roll < 0.85) {
      return Chest.common(floor);
    }
    return null;
  }

  bool _getMilestoneKey() {
    return (p.floor % 10 == 0);
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
        final chest = _getChestReward();
        final keyEarned = _getMilestoneKey();
        
        _feedbackOk = true;
        _feedbackIcon = Icons.check_circle_rounded;
        _feedback = '+$earned fragmentos  +$exp XP  —  Correto.';

        if (chest != null) {
          _feedback += '  Baú ${chest.rarity}!';
        }

        if (keyEarned) {
          _feedback += '  🔑 CHAVE OBTIDA!';
        }

        if (p.hasSiphon && p.currentHp < p.maxHp) {
          p.currentHp = min(p.maxHp, p.currentHp + p.siphonLevel);
          widget.onHpChanged(p.currentHp);
          _feedback += '  Vida recuperada.';
        }

        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!mounted) return;
          widget.onFloorCleared(earned, exp, chest, keyEarned);
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