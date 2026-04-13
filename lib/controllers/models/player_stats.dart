class Chest {
  final int level;
  final int shards;
  final String rarity;

  Chest({required this.level, required this.shards, required this.rarity});

  factory Chest.common(int level) => Chest(
    level: level,
    shards: 15 + (level * 5),
    rarity: 'comum',
  );

  factory Chest.rare(int level) => Chest(
    level: level,
    shards: 35 + (level * 8),
    rarity: 'rara',
  );

  factory Chest.epic(int level) => Chest(
    level: level,
    shards: 60 + (level * 12),
    rarity: 'épica',
  );

  factory Chest.legendary(int level) => Chest(
    level: level,
    shards: 100 + (level * 20),
    rarity: 'lendária',
  );
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
  List<Chest> inventory;
  int keyCount;
  Set<int> usedQuestionThisRun;
  int milestoneLevelReached;

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
    this.inventory = const [],
    this.keyCount = 0,
    this.usedQuestionusedQuestionThisRun = const {},
    this.milestoneLevelReached = 0,
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
    floor = (checkpointFloor > 0) ? checkpointFloor : 1;
    runShards = 0;
    shieldReady = hasShield;
    usedQuestionusedQuestionThisRun = <int>{};
    milestoneLevelReached = 0;
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
    
    final milestone = (level ~/ 10);
    if (milestone > milestoneLevelReached) {
      milestoneLevelReached = milestone;
    }
  }

  void addChestToInventory(Chest chest) {
    inventory = [...inventory, chest];
  }

  int openChest(int index) {
    if (index >= 0 && index < inventory.length) {
      final chest = inventory[index];
      inventory = inventory..removeAt(index);
      return chest.shards;
    }
    return 0;
  }

  void addKey() {
    keyCount++;
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
    'keyCount': keyCount,
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
    keyCount: json['keyCount'] ?? 0,
  );
}
