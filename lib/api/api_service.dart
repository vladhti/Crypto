import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String _apiKeyPref = 'coingecko_api_key';
  WebSocketChannel? _channel;

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
  }

  Future<List<dynamic>> fetchAssets() async {
    final apiKey = await getApiKey();
    final response = await _dio.get(
      'https://api.coingecko.com/api/v3/coins/markets',
      queryParameters: {
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': 20,
        'page': 1,
        'sparkline': true,
        'x_cg_demo_api_key': apiKey,
      },
    );
    return response.data;
  }

  Future<List<dynamic>> fetchCoinChart(String coinId, int days) async {
    final apiKey = await getApiKey();
    final response = await _dio.get(
      'https://api.coingecko.com/api/v3/coins/$coinId/market_chart',
      queryParameters: {
        'vs_currency': 'usd',
        'days': days,
        'interval': 'hourly',
        'x_cg_demo_api_key': apiKey,
      },
    );
    return response.data['prices'];
  }

  Stream<dynamic> subscribeToPrice(String coinId) {
    _channel?.sink.close();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.coincap.io/prices?assets=$coinId'),
    );
    return _channel!.stream;
  }

  void dispose() {
    _channel?.sink.close();
  }
}