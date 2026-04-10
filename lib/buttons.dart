import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

class PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PrimaryButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
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

class IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const IconButton({
    required this.icon,
    required this.onTap,
    super.key,
  });

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

class MiniStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const MiniStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    super.key,
  });

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

class SkillCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String description;
  final int level;
  final int maxLevel;
  final int cost;
  final bool canBuy;
  final VoidCallback onBuy;

  const SkillCard({
    required this.icon,
    required this.color,
    required this.name,
    required this.description,
    required this.level,
    required this.maxLevel,
    required this.cost,
    required this.canBuy,
    required this.onBuy,
    super.key,
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
