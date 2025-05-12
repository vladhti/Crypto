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
    return FutureBuilder<List<dynamic>>(
      future: _assetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки данных'));
        } else {
          final assets = snapshot.data!;
          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              final isFavorite = favoritesProvider.isFavorite(asset['id']);
              return ListTile(
                leading: Image.network(asset['image'], width: 32),
                title: Text(asset['name']),
                subtitle: Text('\$${asset['current_price']}'),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    favoritesProvider.toggleFavorite(asset['id']);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
