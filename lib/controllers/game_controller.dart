import 'package:flutter/material.dart';
import 'models/player_stats.dart';
import 'pages/menu_screen.dart';
import 'pages/skill_tree_screen.dart';
import 'pages/inventory_screen.dart';
import 'pages/dungeon_screen.dart';
import 'pages/end_screen.dart';

enum GameState { menu, skillTree, dungeon, gameOver, victory, inventory }

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

  void _openInventory() => setState(() => _state = GameState.inventory);

  void _onDied() {
    if (_player.floor > _player.checkpointFloor) {
      _player.checkpointFloor = _player.floor;
    }
    _player.shards += _player.runShards;
    setState(() => _state = GameState.gameOver);
  }

  void _onFloorCleared(int earned, int expEarned, Chest? chest, bool keyEarned) {
    _player.runShards += earned;
    _player.gainExp(expEarned);

    if (chest != null) {
      _player.addChestToInventory(chest);
    }

    if (keyEarned) {
      _player.addKey();
    }

    if (_player.floor > _player.highestFloor) {
      _player.highestFloor = _player.floor;
    }

    _player.floor++;
    if (_player.floor > 25) {
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
      onInventory: _openInventory,
    ),
    GameState.skillTree => SkillTreeScreen(
      player: _player,
      onBack: () => setState(() => _state = GameState.menu),
    ),
    GameState.inventory => InventoryScreen(
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
      onInventory: _openInventory,
      onRestart: _startRun,
    ),
    GameState.victory => VictoryScreen(
      player: _player,
      onRestart: _startRun,
    ),
  };
}