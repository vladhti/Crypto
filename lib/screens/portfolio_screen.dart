import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../api/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        return FutureBuilder<List<dynamic>>(
          future: _apiService.fetchAssets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки портфеля'));
            }

            final assets = snapshot.data!;
            double totalValue = 0;
            Map<String, double> distribution = {};

            for (var asset in assets) {
              final portfolioItem = portfolioProvider.portfolio[asset['id']];
              if (portfolioItem != null) {
                final currentValue = portfolioItem.amount * asset['current_price'];
                totalValue += currentValue;
                distribution[asset['name']] = currentValue;
              }
            }

            return Column(
              children: [
                Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Общая стоимость портфеля',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$${totalValue.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: distribution.entries.map((entry) {
                                return PieChartSectionData(
                                  value: entry.value,
                                  title: '${entry.key}\n${(entry.value / totalValue * 100).toStringAsFixed(1)}%',
                                  radius: 100,
                                  titleStyle: TextStyle(fontSize: 12),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      final portfolioItem = portfolioProvider.portfolio[asset['id']];
                      
                      if (portfolioItem == null) return SizedBox.shrink();

                      final currentValue = portfolioItem.amount * asset['current_price'];
                      final profitLoss = currentValue - (portfolioItem.amount * portfolioItem.buyPrice);
                      final profitLossPercentage = (profitLoss / (portfolioItem.amount * portfolioItem.buyPrice) * 100);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Image.network(asset['image'], width: 32),
                          title: Text(asset['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Количество: ${portfolioItem.amount}'),
                              Text(
                                'P&L: ${profitLoss.toStringAsFixed(2)} (${profitLossPercentage.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: profitLoss >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '\$${currentValue.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}