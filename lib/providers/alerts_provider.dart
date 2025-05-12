import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PriceAlert {
  final String assetId;
  final double targetPrice;
  final bool isAbove;

  PriceAlert({
    required this.assetId,
    required this.targetPrice,
    required this.isAbove,
  });

  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'targetPrice': targetPrice,
    'isAbove': isAbove,
  };

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
    assetId: json['assetId'],
    targetPrice: json['targetPrice'],
    isAbove: json['isAbove'],
  );
}

class AlertsProvider extends ChangeNotifier {
  List<PriceAlert> _alerts = [];
  
  List<PriceAlert> get alerts => _alerts;

  Future<void> loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getString('price_alerts');
    if (alertsJson != null) {
      final List<dynamic> decoded = json.decode(alertsJson);
      _alerts = decoded.map((item) => PriceAlert.fromJson(item as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> addAlert(String assetId, double targetPrice, bool isAbove) async {
    _alerts.add(PriceAlert(
      assetId: assetId,
      targetPrice: targetPrice,
      isAbove: isAbove,
    ));
    await _saveAlerts();
  }

  Future<void> removeAlert(int index) async {
    _alerts.removeAt(index);
    await _saveAlerts();
  }

  Future<void> _saveAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('price_alerts', json.encode(_alerts.map((e) => e.toJson()).toList()));
    notifyListeners();
  }
}