class Account {
  final int id;
  final String name;
  final String type;
  final double initialBalance;
  final bool active;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    this.active = true,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'name': name,
      'type': type,
      'initialBalance': initialBalance,
      'active': active ? 1 : 0,
    };
    if (includeId && id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      initialBalance: map['initialBalance'],
      active: map['active'] == 1,
    );
  }
} 