import 'package:flutter/material.dart';
import 'package:my_money_gestao_financeira/screens/all_transactions_screen.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:provider/provider.dart';
import 'providers/account_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/all_transactions_full_screen.dart';
import 'screens/accounts_screen.dart';
import 'widgets/main_bottom_app_bar.dart';
import 'screens/transaction_edit_screen.dart';
import 'screens/metrics_screen.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Gestão Financeira',
        theme: ThemeData(
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF43A047), // verde folha moderno
            onPrimary: Colors.white,
            secondary: Color(0xFFB2DFDB), // verde água/mint
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.white,
            background: Color(0xFFF6FFF6),
            onBackground: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF43A047),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF43A047),
            foregroundColor: Colors.white,
            shape: StadiumBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43A047))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43A047))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43A047), width: 2)),
            labelStyle: const TextStyle(color: Color(0xFF43A047)),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            shadowColor: Colors.black12,
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all(const Color(0xFF43A047)),
            trackColor: MaterialStateProperty.all(const Color(0xFFB2DFDB)),
          ),
          drawerTheme: const DrawerThemeData(
            backgroundColor: Color(0xFFF6FFF6),
          ),
          scaffoldBackgroundColor: const Color(0xFFF6FFF6),
          fontFamily: 'Roboto',
        ),
        home: NotificationListenerWidget(child: const MainNavigationScreen()),
        routes: {
          '/add-receita': (context) => TransactionEditScreen(initialType: 'entrada'),
          '/add-despesa': (context) => TransactionEditScreen(initialType: 'saida'),
        },
      ),
    );
  }
}

// NOVO WIDGET DE NAVEGAÇÃO PRINCIPAL
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFabOpen = false;
  late AnimationController _fabController;
  late Animation<Offset> _receitaOffsetAnimation;
  late Animation<Offset> _despesaOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _receitaOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut));
    _despesaOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 2.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const AllTransactionsScreen(),
      const AllTransactionsFullScreen(),
      const MetricsScreen(),
      const AccountsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          // FABs expansíveis
          if (_isFabOpen)
            Positioned(
              bottom: 50,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SlideTransition(
                        position: _receitaOffsetAnimation,
                        child: FloatingActionButton.extended(
                          heroTag: 'fab_receita',
                          backgroundColor: const Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text('Receita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            _toggleFab();
                            Navigator.pushNamed(context, '/add-receita');
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SlideTransition(
                        position: _despesaOffsetAnimation,
                        child: FloatingActionButton.extended(
                          heroTag: 'fab_despesa',
                          backgroundColor: Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                          label: const Text('Despesa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            _toggleFab();
                            Navigator.pushNamed(context, '/add-despesa');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: MainBottomAppBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
            _isFabOpen = false;
          });
        },
        showMetrics: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _fabController.value * 0.50 * 3.141, // ~135 graus
            child: FloatingActionButton(
              heroTag: 'fab_main',
              backgroundColor: _isFabOpen ? Colors.white : const Color(0xFF43A047),
              foregroundColor: _isFabOpen ? const Color(0xFF43A047) : Colors.white,
              onPressed: _toggleFab,
              child: _isFabOpen
                  ? const Icon(Icons.close, color: Color(0xFF43A047), size: 24)
                  : const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          );
        },
      ),
    );
  }
}

class NotificationListenerWidget extends StatefulWidget {
  final Widget child;
  const NotificationListenerWidget({required this.child, Key? key}) : super(key: key);

  @override
  State<NotificationListenerWidget> createState() => _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget> {
  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    final granted = await NotificationListenerService.isPermissionGranted();
    if (!granted) {
      await NotificationListenerService.requestPermission();
    }
    NotificationListenerService.notificationsStream.listen(_onNotificationReceived);
  }

  void _onNotificationReceived(ServiceNotificationEvent event) async {
    if (event.packageName == 'com.google.android.apps.walletnfcrel') {
      final String? text = event.content;
      if (text != null && _isDespesa(text)) {
        final valor = _extractValor(text);
        final descricao = _extractDescricao(text);
        if (valor != null) {
          // Espera o contexto estar montado
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Nova despesa detectada'),
              content: Text('Descrição: $descricao\nValor: R\$ ${valor.toStringAsFixed(2)}\nDeseja adicionar como despesa?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Adicionar')),
              ],
            ),
          );
          if (confirmed == true) {
            final accountProvider = Provider.of<AccountProvider>(context, listen: false);
            final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
            final account = accountProvider.accounts.firstWhere((a) => a.active, orElse: () => accountProvider.accounts.first);
            await transactionProvider.addTransaction(
              account.id,
              valor,
              descricao,
              DateTime.now(),
              'saida',
              'Outros',
            );
          }
        }
      }
    }
  }

  bool _isDespesa(String text) {
    // Ajuste este filtro conforme o padrão das notificações do Google Carteira
    return text.contains('compra') || text.contains('pagamento') || text.contains('R\$');
  }

  double? _extractValor(String text) {
    final regex = RegExp(r'R\$\s*([\d.,]+)');
    final match = regex.firstMatch(text);
    if (match != null) {
      final valorStr = match.group(1)?.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(valorStr ?? '');
    }
    return null;
  }

  String _extractDescricao(String text) {
    // Tenta extrair uma descrição curta
    final partes = text.split(' ');
    if (partes.length > 2) {
      return partes.sublist(0, 4).join(' ');
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
