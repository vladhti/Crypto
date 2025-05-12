import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _assetsFuture;

  @override
  void initState() {
    super.initState();
    _assetsFuture = _apiService.fetchAssets();
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

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
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