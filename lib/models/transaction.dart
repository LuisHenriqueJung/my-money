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

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'accountId': accountId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
    };
    if (includeId && id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      category: map['category'],
    );
  }
} 