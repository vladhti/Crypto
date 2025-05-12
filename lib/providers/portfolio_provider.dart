import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PortfolioItem {
  final String id;
  final double amount;
  final double buyPrice;

  PortfolioItem({
    required this.id,
    required this.amount,
    required this.buyPrice,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'buyPrice': buyPrice,
  };

  factory PortfolioItem.fromJson(Map<String, dynamic> json) => PortfolioItem(
    id: json['id'],
    amount: json['amount'],
    buyPrice: json['buyPrice'],
  );
}

class PortfolioProvider extends ChangeNotifier {
  Map<String, PortfolioItem> _portfolio = {};
  
  Map<String, PortfolioItem> get portfolio => _portfolio;

  Future<void> loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final portfolioJson = prefs.getString('portfolio');
    if (portfolioJson != null) {
      final Map<String, dynamic> decoded = json.decode(portfolioJson);
      _portfolio = decoded.map((key, value) => MapEntry(
        key,
        PortfolioItem.fromJson(value as Map<String, dynamic>),
      ));
      notifyListeners();
    }
  }

  Future<void> addToPortfolio(String id, double amount, double buyPrice) async {
    _portfolio[id] = PortfolioItem(
      id: id,
      amount: amount,
      buyPrice: buyPrice,
    );
    await _savePortfolio();
  }

  Future<void> _savePortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final portfolioJson = json.encode(
      _portfolio.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString('portfolio', portfolioJson);
    notifyListeners();
  }
}