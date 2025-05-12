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
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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

  Widget _buildPriceChart(String coinId, List<dynamic> sparklineData, bool isPositive) {
    final spots = sparklineData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();

    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: isPositive ? Colors.green.shade400 : Colors.red.shade400,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    isPositive ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.grey.shade900.withOpacity(0.8),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    currencyFormat.format(touchedSpot.y),
                    TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Поиск криптовалюты',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildCryptoCard(dynamic asset, bool isFavorite, BuildContext context) {
    final priceChange = asset['price_change_percentage_24h'] ?? 0.0;
    final isPositive = priceChange >= 0;
    final sparklineData = asset['sparkline_in_7d']['price'] as List<dynamic>;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(asset['image'], width: 32, height: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        asset['symbol'].toString().toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    Provider.of<FavoritesProvider>(context, listen: false)
                        .toggleFavorite(asset['id']);
                  },
                ),
              ],
            ),
          ),
          _buildPriceChart(asset['id'], sparklineData, isPositive),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Цена',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      currencyFormat.format(asset['current_price']),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${priceChange.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: _apiService.subscribeToPrice(asset['id']),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data as Map<String, dynamic>;
                final price = double.parse(data[asset['id']].toString());
                final previousPrice = _latestPrices[asset['id']] ?? price;
                _latestPrices[asset['id']] = price;
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.green,
                        size: 12,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Live: ${currencyFormat.format(price)}',
                        style: TextStyle(
                          color: price > previousPrice ? Colors.green : 
                                price < previousPrice ? Colors.red : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _assetsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки данных',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _assetsFuture = _apiService.fetchAssets();
                          });
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Попробовать снова'),
                      ),
                    ],
                  ),
                );
              }

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
                    final isFavorite = Provider.of<FavoritesProvider>(context)
                        .isFavorite(asset['id']);
                    return _buildCryptoCard(asset, isFavorite, context);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}