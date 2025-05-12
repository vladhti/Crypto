import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alerts_provider.dart';
import '../api/api_service.dart';

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiService _apiService = ApiService();
  final _priceController = TextEditingController();
  String? _selectedAssetId;
  bool _isAbove = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, alertsProvider, child) {
        return Column(
          children: [
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Добавить оповещение',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<List<dynamic>>(
                      future: _apiService.fetchAssets(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedAssetId,
                          items: snapshot.data!.map<DropdownMenuItem<String>>((asset) {
                            return DropdownMenuItem<String>(
                              value: asset['id'] as String,
                              child: Text(asset['name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedAssetId = value);
                          },
                          decoration: InputDecoration(
                            labelText: 'Выберите криптовалюту',
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Целевая цена',
                        prefixText: '\$',
                      ),
                    ),
                    SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Выше'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Ниже'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                      ],
                      selected: {_isAbove},
                      onSelectionChanged: (Set<bool> selected) {
                        setState(() => _isAbove = selected.first);
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedAssetId != null && _priceController.text.isNotEmpty) {
                          alertsProvider.addAlert(
                            _selectedAssetId!,
                            double.parse(_priceController.text),
                            _isAbove,
                          );
                          _priceController.clear();
                          setState(() => _selectedAssetId = null);
                        }
                      },
                      child: Text('Добавить оповещение'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _apiService.fetchAssets(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final assets = Map.fromEntries(
                    snapshot.data!.map((asset) => MapEntry(asset['id'], asset)),
                  );

                  return ListView.builder(
                    itemCount: alertsProvider.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alertsProvider.alerts[index];
                      final asset = assets[alert.assetId];
                      if (asset == null) return SizedBox.shrink();

                      final currentPrice = asset['current_price'];
                      final isTriggered = alert.isAbove
                          ? currentPrice >= alert.targetPrice
                          : currentPrice <= alert.targetPrice;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Image.network(asset['image'], width: 32),
                          title: Text(asset['name']),
                          subtitle: Text(
                            '${alert.isAbove ? 'Выше' : 'Ниже'} \$${alert.targetPrice}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isTriggered ? Icons.notifications_active : Icons.notifications,
                                color: isTriggered ? Colors.amber : Colors.grey,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => alertsProvider.removeAlert(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}