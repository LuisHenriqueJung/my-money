class Transaction {
  final int id;
  final int accountId;
  final double amount;
  final String description;
  final DateTime date;
  final String type; // 'entrada' ou 'saida'
  final String category;

  Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
  });
} 