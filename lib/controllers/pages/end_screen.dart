import 'package:flutter/material.dart';
import '../../constants/design_tokens.dart';
import '../../models/player_stats.dart';
import '../../components/buttons.dart';

// ─────────────────────────────────────────────────────────────
//  GAME OVER SCREEN
// ─────────────────────────────────────────────────────────────

class GameOverScreen extends StatelessWidget {
  final PlayerStats player;
  final VoidCallback onSkillTree;
  final VoidCallback onInventory;
  final VoidCallback onRestart;

  const GameOverScreen({
    super.key,
    required this.player,
    required this.onSkillTree,
    required this.onInventory,
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
                  _StatRow(
                    icon: Icons.card_giftcard_rounded,
                    color: DT.purple,
                    label: 'Baús coletados',
                    value: '${player.inventory.length}',
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    icon: Icons.account_tree_outlined,
                    label: 'GASTAR FRAGMENTOS',
                    color: DT.violet,
                    onTap: onSkillTree,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    icon: Icons.card_giftcard_rounded,
                    label: 'INVENTÁRIO',
                    color: DT.blue,
                    onTap: onInventory,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
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
  final String label;
  final String value;

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
                  _StatRow(
                    icon: Icons.card_giftcard_rounded,
                    color: DT.purple,
                    label: 'Baús coletados',
                    value: '${player.inventory.length}',
                  ),
                  _StatRow(
                    icon: Icons.vpn_key_rounded,
                    color: DT.gold,
                    label: 'Chaves obtidas',
                    value: '${player.keyCount}',
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
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
