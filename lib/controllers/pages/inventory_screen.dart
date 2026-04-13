import 'package:flutter/material.dart';
import '../../constants/design_tokens.dart';
import '../models/player_stats.dart';
import '../../components/buttons.dart';

class InventoryScreen extends StatefulWidget {
  final PlayerStats player;
  final VoidCallback onBack;

  const InventoryScreen({
    super.key,
    required this.player,
    required this.onBack,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late List<Chest> _chests;
  int _shardsFromOpenedChests = 0;

  @override
  void initState() {
    super.initState();
    _chests = List.from(widget.player.inventory);
  }

  void _openChest(int index) {
    if (index >= 0 && index < _chests.length) {
      final chest = _chests[index];
      final shards = chest.shards;
      
      setState(() {
        _chests.removeAt(index);
        widget.player.inventory = _chests;
        _shardsFromOpenedChests += shards;
        widget.player.shards += shards;
      });

      showDialog(
        context: context,
        builder: (context) => ChestOpenDialog(chest: chest, shards: shards),
      ).then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1A0F2E), DT.bg],
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
                      onTap: onBack,
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.card_giftcard_rounded, color: DT.gold, size: 17),
                    const SizedBox(width: 8),
                    const Text(
                      'INVENTÁRIO',
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
                      '${widget.player.shards}',
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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Abra seus baús para obter fragmentos! Total: $_shardsFromOpenedChests',
                        style: DT.caption.copyWith(fontSize: 11),
                      ),
                    ),
                    if (widget.player.keyCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: DT.gold.withOpacity(0.15),
                            border: Border.all(color: DT.gold.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.vpn_key_rounded, size: 12, color: DT.gold),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.player.keyCount}',
                                style: const TextStyle(
                                  color: DT.gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _chests.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 48,
                        color: DT.muted.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum baú ainda',
                        style: DT.caption.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete andares para conseguir baús',
                        style: DT.caption.copyWith(fontSize: 11, color: DT.muted),
                      ),
                    ],
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _chests.length,
                  itemBuilder: (context, index) {
                    final chest = _chests[index];
                    return _ChestCard(
                      chest: chest,
                      onTap: () => _openChest(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChestCard extends StatelessWidget {
  final Chest chest;
  final VoidCallback onTap;

  const _ChestCard({required this.chest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _getChestColor();
    final icon = _getChestIcon();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DT.surface,
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              'Nível ${chest.level}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              chest.rarity,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${chest.shards} ◆',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChestColor() {
    switch (chest.rarity) {
      case 'comum':
        return const Color(0xFF8B8B9A);
      case 'rara':
        return DT.blue;
      case 'épica':
        return DT.violet;
      case 'lendária':
        return DT.gold;
      default:
        return DT.muted;
    }
  }

  IconData _getChestIcon() {
    switch (chest.rarity) {
      case 'lendária':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }
}

class ChestOpenDialog extends StatelessWidget {
  final Chest chest;
  final int shards;

  const ChestOpenDialog({required this.chest, required this.shards});

  @override
  Widget build(BuildContext context) {
    final color = _getChestColor();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: DT.surface,
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard_rounded, size: 56, color: color),
            const SizedBox(height: 16),
            Text(
              'Baú ${chest.rarity.toUpperCase()}',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nível ${chest.level}',
              style: DT.caption.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond_rounded, size: 28, color: color),
                  const SizedBox(width: 12),
                  Text(
                    '+$shards',
                    style: TextStyle(
                      color: color,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.2),
                  side: BorderSide(color: color.withOpacity(0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Coletar',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChestColor() {
    switch (chest.rarity) {
      case 'comum':
        return const Color(0xFF8B8B9A);
      case 'rara':
        return DT.blue;
      case 'épica':
        return DT.violet;
      case 'lendária':
        return DT.gold;
      default:
        return DT.muted;
    }
  }
}
