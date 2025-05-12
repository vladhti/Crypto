import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/store_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/hotshot_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/alerts_screen.dart';
import 'providers/favorites_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/alerts_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..loadFavorites(),
        ),
        ChangeNotifierProvider(
          create: (_) => PortfolioProvider()..loadPortfolio(),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertsProvider()..loadAlerts(),
        ),
      ],
      child: CryptoCheckerApp(),
    ),
  );
}

class CryptoCheckerApp extends StatefulWidget {
  @override
  _CryptoCheckerAppState createState() => _CryptoCheckerAppState();
}

class _CryptoCheckerAppState extends State<CryptoCheckerApp> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    StoreScreen(),
    FavoritesScreen(),
    PortfolioScreen(),
    AlertsScreen(),
    HotshotScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Checker',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: Text('Crypto Checker')),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Магазин'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Избранное'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Портфель'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Оповещения'),
            BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: '🔥Hot'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
          ],
        ),
      ),
    );
  }
}