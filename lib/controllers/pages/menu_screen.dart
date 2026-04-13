import 'package:flutter/material.dart';
import '../../constants/design_tokens.dart';
import '../../models/player_stats.dart';
import '../../components/buttons.dart';

class MenuScreen extends StatefulWidget {
  final PlayerStats player;
  final VoidCallback onStart;
  final VoidCallback? onSkillTree;
  final VoidCallback onInventory;

  const MenuScreen({
    super.key,
    required this.player,
    required this.onStart,
    this.onSkillTree,
    required this.onInventory,
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
                  PrimaryButton(
                    icon: Icons.arrow_downward_rounded,
                    label: 'DESCER AO CALABOUÇO',
                    color: DT.gold,
                    onTap: widget.onStart,
                  ),
                  if (widget.onSkillTree != null) ...[
                    const SizedBox(height: 12),
                    PrimaryButton(
                      icon: Icons.account_tree_outlined,
                      label: 'ÁRVORE DE HABILIDADES',
                      color: DT.violet,
                      onTap: widget.onSkillTree!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  PrimaryButton(
                    icon: Icons.card_giftcard_rounded,
                    label: 'INVENTÁRIO (${widget.player.inventory.length})',
                    color: DT.blue,
                    onTap: widget.onInventory,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MiniStat(
                        icon: Icons.favorite_rounded,
                        iconColor: DT.red,
                        label: '${widget.player.maxHp} vidas',
                      ),
                      const SizedBox(width: 12),
                      MiniStat(
                        icon: Icons.diamond_outlined,
                        iconColor: DT.cyan,
                        label: '${widget.player.shards}',
                      ),
                      const SizedBox(width: 12),
                      MiniStat(
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
