class Coin {
  final String id;
  final String symbol;
  final String name;
  final String? image;
  final double currentPrice;
  final double marketCap;
  final double totalVolume;
  final double priceChangePercentage24h;
  final double priceChangePercentage1h;
  final double priceChangePercentage7d;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.totalVolume,
    required this.priceChangePercentage24h,
    required this.priceChangePercentage1h,
    required this.priceChangePercentage7d,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] ?? '',
      symbol: json['symbol']?.toUpperCase() ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      totalVolume: (json['total_volume'] ?? 0).toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] ?? 0).toDouble(),
      priceChangePercentage1h:
          (json['price_change_percentage_1h'] ?? 0).toDouble(),
      priceChangePercentage7d:
          (json['price_change_percentage_7d'] ?? 0).toDouble(),
      circulatingSupply: json['circulating_supply']?.toDouble(),
      totalSupply: json['total_supply']?.toDouble(),
      maxSupply: json['max_supply']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'total_volume': totalVolume,
      'price_change_percentage_24h': priceChangePercentage24h,
      'price_change_percentage_1h': priceChangePercentage1h,
      'price_change_percentage_7d': priceChangePercentage7d,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'max_supply': maxSupply,
    };
  }
}

class CoinDetail extends Coin {
  final Map<String, dynamic>? marketData;
  final Map<String, dynamic>? communityData;
  final List<double>? sparkline;

  CoinDetail({
    required super.id,
    required super.symbol,
    required super.name,
    super.image,
    required super.currentPrice,
    required super.marketCap,
    required super.totalVolume,
    required super.priceChangePercentage24h,
    required super.priceChangePercentage1h,
    required super.priceChangePercentage7d,
    super.circulatingSupply,
    super.totalSupply,
    super.maxSupply,
    this.marketData,
    this.communityData,
    this.sparkline,
  });

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    final marketData = json['market_data'] as Map<String, dynamic>?;
    final currentPrice =
        marketData?['current_price']?['usd']?.toDouble() ?? 0.0;
    final marketCap = marketData?['market_cap']?['usd']?.toDouble() ?? 0.0;
    final totalVolume = marketData?['total_volume']?['usd']?.toDouble() ?? 0.0;

    return CoinDetail(
      id: json['id'] ?? '',
      symbol: json['symbol']?.toUpperCase() ?? '',
      name: json['name'] ?? '',
      image: json['image']?['large'],
      currentPrice: currentPrice,
      marketCap: marketCap,
      totalVolume: totalVolume,
      priceChangePercentage24h:
          marketData?['price_change_percentage_24h']?.toDouble() ?? 0.0,
      priceChangePercentage1h:
          marketData?['price_change_percentage_1h']?.toDouble() ?? 0.0,
      priceChangePercentage7d:
          marketData?['price_change_percentage_7d']?.toDouble() ?? 0.0,
      circulatingSupply: marketData?['circulating_supply']?.toDouble(),
      totalSupply: marketData?['total_supply']?.toDouble(),
      maxSupply: marketData?['max_supply']?.toDouble(),
      marketData: marketData,
      communityData: json['community_data'] as Map<String, dynamic>?,
      sparkline: (json['sparkline_7d']?['price'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class PriceHistory {
  final List<double> prices;
  final List<double> marketCaps;
  final List<double> totalVolumes;

  PriceHistory({
    required this.prices,
    required this.marketCaps,
    required this.totalVolumes,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    final prices = (json['prices'] as List?)
            ?.map((e) => (e[1] as num).toDouble())
            .toList() ??
        [];
    final marketCaps = (json['market_caps'] as List?)
            ?.map((e) => (e[1] as num).toDouble())
            .toList() ??
        [];
    final totalVolumes = (json['total_volumes'] as List?)
            ?.map((e) => (e[1] as num).toDouble())
            .toList() ??
        [];

    return PriceHistory(
      prices: prices,
      marketCaps: marketCaps,
      totalVolumes: totalVolumes,
    );
  }
}
