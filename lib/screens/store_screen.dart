import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _assetsFuture;
  final Map<String, List<FlSpot>> _priceData = {};
  final Map<String, double> _latestPrices = {};

  @override
  void initState() {
    super.initState();
    _assetsFuture = _apiService.fetchAssets();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Widget _buildPriceChart(String coinId, List<dynamic> sparklineData) {
    final spots = sparklineData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();

    return Container(
      height: 100,
      padding: EdgeInsets.only(right: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final price = NumberFormat.currency(symbol: '\$').format(touchedSpot.y);
                  return LineTooltipItem(
                    price,
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск криптовалюты',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _assetsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Ошибка загрузки данных'),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _assetsFuture = _apiService.fetchAssets();
                          });
                        },
                        child: Text('Попробовать снова'),
                      ),
                    ],
                  ),
                );
              } else {
                final assets = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _assetsFuture = _apiService.fetchAssets();
                    });
                  },
                  child: ListView.builder(
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      final isFavorite = favoritesProvider.isFavorite(asset['id']);
                      final priceChange = asset['price_change_percentage_24h'] ?? 0.0;
                      final isPositive = priceChange >= 0;
                      final sparklineData = asset['sparkline_in_7d']['price'] as List<dynamic>;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Image.network(asset['image'], width: 40),
                              title: Text(
                                asset['name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(asset['symbol'].toString().toUpperCase()),
                                  Text(
                                    '\$${asset['current_price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isPositive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${priceChange.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: isPositive ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite ? Icons.star : Icons.star_border,
                                      color: isFavorite ? Colors.amber : Colors.grey,
                                    ),
                                    onPressed: () {
                                      favoritesProvider.toggleFavorite(asset['id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            _buildPriceChart(asset['id'], sparklineData),
                            StreamBuilder(
                              stream: _apiService.subscribeToPrice(asset['id']),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final data = snapshot.data as Map<String, dynamic>;
                                  final price = double.parse(data[asset['id']].toString());
                                  final previousPrice = _latestPrices[asset['id']] ?? price;
                                  _latestPrices[asset['id']] = price;
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Live: \$${price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: price > previousPrice ? Colors.green : 
                                                  price < previousPrice ? Colors.red : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          price > previousPrice ? Icons.arrow_upward : 
                                          price < previousPrice ? Icons.arrow_downward : Icons.remove,
                                          color: price > previousPrice ? Colors.green : 
                                                price < previousPrice ? Colors.red : Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}