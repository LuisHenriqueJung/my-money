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
} 