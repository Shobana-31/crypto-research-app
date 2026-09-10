import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/coin.dart';

class WatchlistProvider extends ChangeNotifier {
  List<Coin> _watchlist = [];
  List<Coin> get watchlist => _watchlist;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WatchlistProvider() {
    _loadWatchlist();
  }

  void toggleWatchlist(Coin coin) {
    if (isInWatchlist(coin.id)) {
      _watchlist.removeWhere((c) => c.id == coin.id);
    } else {
      _watchlist.add(coin);
    }
    _saveWatchlist();
    notifyListeners();
  }

  bool isInWatchlist(String coinId) {
    return _watchlist.any((coin) => coin.id == coinId);
  }

  void clearWatchlist() {
    _watchlist.clear();
    _saveWatchlist();
    notifyListeners();
  }

  Future<void> _loadWatchlist() async {
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? watchlistJson = prefs.getString('watchlist');
      if (watchlistJson != null) {
        final List<dynamic> decoded = json.decode(watchlistJson);
        _watchlist = decoded.map((json) => Coin.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading watchlist: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String watchlistJson = json.encode(
        _watchlist.map((coin) => {
          'id': coin.id,
          'symbol': coin.symbol,
          'name': coin.name,
          'image': coin.image,
          'current_price': coin.currentPrice,
          'market_cap': coin.marketCap,
          'total_volume': coin.totalVolume,
          'price_change_percentage_24h': coin.priceChangePercentage24h,
        }).toList()
      );
      await prefs.setString('watchlist', watchlistJson);
    } catch (e) {
      print('Error saving watchlist: $e');
    }
  }
}