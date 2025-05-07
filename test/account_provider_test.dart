import 'package:flutter_test/flutter_test.dart';
import 'package:my_money_gestao_financeira/providers/account_provider.dart';

void main() {
  group('AccountProvider', () {
    test('adiciona uma nova conta corretamente', () {
      final provider = AccountProvider();
      expect(provider.accounts.length, 0);
      provider.addAccount('Conta Teste', 'Poupança', 100.0);
      expect(provider.accounts.length, 1);
      final account = provider.accounts.first;
      expect(account.name, 'Conta Teste');
      expect(account.type, 'Poupança');
      expect(account.initialBalance, 100.0);
      expect(account.id, 1);
    });
  });
} 