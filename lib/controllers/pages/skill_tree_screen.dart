import 'package:flutter/material.dart';
import '../../constants/design_tokens.dart';
import '../../models/player_stats.dart';
import '../../components/buttons.dart';

class SkillTreeScreen extends StatefulWidget {
  final PlayerStats player;
  final VoidCallback onBack;

  const SkillTreeScreen({super.key, required this.player, required this.onBack});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  PlayerStats get p => widget.player;

  int get _vigorCost  => (p.vigorLevel  + 1) * 4;
  int get _siphonCost => (p.siphonLevel + 1) * 5;
  int get _armorCost  => (p.armorLevel + 1) * 6;
  int get _focusCost  => (p.focusLevel + 1) * 8;
  int get _wealthCost => (p.wealthLevel + 1) * 10;

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
          if (p.oracleLevel < 1 && p.shards >= 12) {
            p.shards -= 12;
            p.oracleLevel = 1;
          }
        case 'shield':
          if (p.shieldLevel < 1 && p.shards >= 15) {
            p.shards -= 15;
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
                    IconButtonStyled(
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
                  'Upgrade para ficar mais forte. Preços aumentam por nível!',
                  style: DT.caption.copyWith(fontSize: 11),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    SkillCard(
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
                    SkillCard(
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
                    SkillCard(
                      icon: Icons.visibility_rounded,
                      color: DT.amber,
                      name: 'Visão do Oráculo',
                      description: 'Uma opção falsa some de cada enigma.',
                      level: p.oracleLevel,
                      maxLevel: 1,
                      cost: 12,
                      canBuy: p.oracleLevel < 1 && p.shards >= 12,
                      onBuy: () => _buy('oracle'),
                    ),
                    const SizedBox(height: 10),
                    SkillCard(
                      icon: Icons.shield_rounded,
                      color: DT.violet,
                      name: 'Escudo Arcano',
                      description: 'Absorve o primeiro erro a cada descida.',
                      level: p.shieldLevel,
                      maxLevel: 1,
                      cost: 15,
                      canBuy: p.shieldLevel < 1 && p.shards >= 15,
                      onBuy: () => _buy('shield'),
                    ),
                    const SizedBox(height: 10),
                    SkillCard(
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
                    SkillCard(
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
                    SkillCard(
                      icon: Icons.attach_money_rounded,
                      color: DT.gold,
                      name: 'Ganância do Tesouro',
                      description: 'Aumenta fragmentos ganhos em 30% por nível.',
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
