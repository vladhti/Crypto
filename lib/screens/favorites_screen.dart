import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../api/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
          return Center(child: Text('Ошибка загрузки'));
        } else {
          final assets = snapshot.data!;
          final favoriteAssets = assets
              .where((asset) => favoritesProvider.isFavorite(asset['id']))
              .toList();
          return ListView.builder(
            itemCount: favoriteAssets.length,
            itemBuilder: (context, index) {
              final asset = favoriteAssets[index];
              return ListTile(
                leading: Image.network(asset['image'], width: 32),
                title: Text(asset['name']),
                subtitle: Text('\$${asset['current_price']}'),
                trailing: IconButton(
                  icon: Icon(Icons.star, color: Colors.amber),
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
