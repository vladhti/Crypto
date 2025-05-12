import 'package:flutter/material.dart';
import '../api/api_service.dart';

class HotshotScreen extends StatelessWidget {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _apiService.fetchAssets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки'));
        } else {
          final assets = snapshot.data!;
          assets.sort((a, b) =>
              (b['price_change_percentage_24h'] ?? 0).compareTo(
                  a['price_change_percentage_24h'] ?? 0));
          final topAssets = assets.take(10).toList();
          return ListView.builder(
            itemCount: topAssets.length,
            itemBuilder: (context, index) {
              final asset = topAssets[index];
              return ListTile(
                leading: Image.network(asset['image'], width: 32),
                title: Text(asset['name']),
                subtitle: Text(
                    '\$${asset['current_price']} (${asset['price_change_percentage_24h']?.toStringAsFixed(2)}%)'),
              );
            },
          );
        }
      },
    );
  }
}
