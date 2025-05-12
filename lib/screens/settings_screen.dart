import 'package:flutter/material.dart';
import '../api/api_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  final _apiKeyController = TextEditingController();
  bool _isDarkMode = true;
  String? _currentApiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    _currentApiKey = await _apiService.getApiKey();
    if (_currentApiKey != null) {
      _apiKeyController.text = _currentApiKey!;
    }
    setState(() {});
  }

  bool _isValidApiKey(String key) {
    return RegExp(r'^coingecko-SK[0-9a-fA-F]{32}$').hasMatch(key);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Настройки',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'CoinGecko API Key',
                    hintText: 'Введите ключ в формате coingecko-SK...',
                    border: OutlineInputBorder(),
                    errorText: _apiKeyController.text.isNotEmpty && 
                             !_isValidApiKey(_apiKeyController.text)
                        ? 'Неверный формат ключа'
                        : null,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_isValidApiKey(_apiKeyController.text)) {
                      await _apiService.setApiKey(_apiKeyController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('API ключ сохранен')),
                      );
                    }
                  },
                  child: Text('Сохранить API ключ'),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Тёмная тема'),
                value: _isDarkMode,
                onChanged: (val) {
                  setState(() => _isDarkMode = val);
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Уведомления'),
                subtitle: Text('Скоро будет доступно'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'О приложении',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                Text('Версия: 1.0.0'),
                Text('Разработчик: Crypto Checker Team'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}