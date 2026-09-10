import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/api_service.dart';

class CryptoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Coin> _coins = [];
  List<Coin> _searchResults = [];
  CoinDetail? _selectedCoin;
  List<double>? _chartData;
  Map<String, dynamic> _globalData = {};
  bool _isLoading = false;
  String? _error;
  String _sortOrder = 'market_cap_desc';

  List<Coin> get coins => _coins;
  List<Coin> get searchResults => _searchResults;
  CoinDetail? get selectedCoin => _selectedCoin;
  List<double>? get chartData => _chartData;
  Map<String, dynamic> get globalData => _globalData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortOrder => _sortOrder;

  Future<void> fetchCoins() async {
    _setLoading(true);
    _error = null;

    try {
      _coins = await _apiService.getCoins();
      _searchResults = _coins;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchCoinDetail(String coinId) async {
    _setLoading(true);
    _error = null;

    try {
      _selectedCoin = await _apiService.getCoinDetail(coinId);
      _chartData = _selectedCoin?.sparkline;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchCoinChart(String coinId, String days) async {
    _setLoading(true);
    _error = null;

    try {
      final chartData = await _apiService.getCoinChart(coinId, days: days);
      _chartData = chartData.prices;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchGlobalData() async {
    _setLoading(true);
    _error = null;

    try {
      _globalData = await _apiService.getGlobalData();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  void searchCoins(String query) {
    if (query.isEmpty) {
      _searchResults = _coins;
    } else {
      _searchResults = _coins
          .where((coin) =>
              coin.name.toLowerCase().contains(query.toLowerCase()) ||
              coin.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void updateSort(String order) {
    _sortOrder = order;
    _sortCoins();
    notifyListeners();
  }

  void _sortCoins() {
    switch (_sortOrder) {
      case 'market_cap_desc':
        _coins.sort((a, b) => b.marketCap.compareTo(a.marketCap));
        break;
      case 'market_cap_asc':
        _coins.sort((a, b) => a.marketCap.compareTo(b.marketCap));
        break;
      case 'price_desc':
        _coins.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case 'price_asc':
        _coins.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case 'change_desc':
        _coins.sort((a, b) =>
            b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
        break;
      case 'change_asc':
        _coins.sort((a, b) =>
            a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
        break;
      case 'volume_desc':
        _coins.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
        break;
      default:
        break;
    }
    _searchResults = _coins;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
