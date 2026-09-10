import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/crypto_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/price_chart.dart';

class CoinDetailScreen extends StatefulWidget {
  final String coinId;
  const CoinDetailScreen({super.key, required this.coinId});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  String _selectedTimeframe = '7D';
  final List<String> _timeframes = ['1D', '7D', '30D', '90D', '1Y'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoProvider>().fetchCoinDetail(widget.coinId);
      context.read<CryptoProvider>().fetchCoinChart(
            widget.coinId,
            _getDaysForTimeframe(_selectedTimeframe),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Details'),
        elevation: 0,
        actions: [
          Consumer<WatchlistProvider>(
            builder: (context, provider, child) {
              final coin = context.watch<CryptoProvider>().selectedCoin;
              if (coin == null) return const SizedBox();
              final isInWatchlist = provider.isInWatchlist(coin.id);
              return IconButton(
                icon: Icon(
                  isInWatchlist ? Icons.star : Icons.star_border,
                  color: isInWatchlist ? Colors.amber : null,
                ),
                onPressed: () {
                  provider.toggleWatchlist(coin);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isInWatchlist
                            ? 'Removed from watchlist'
                            : 'Added to watchlist',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CryptoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedCoin == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16, color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchCoinDetail(widget.coinId);
                      provider.fetchCoinChart(
                        widget.coinId,
                        _getDaysForTimeframe(_selectedTimeframe),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final coin = provider.selectedCoin;
          if (coin == null) {
            return Center(
              child: Text(
                'No data available',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final isPositive = coin.priceChangePercentage24h >= 0;
          final priceColor = isPositive ? Colors.green : Colors.red;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (coin.image != null)
                      Image.network(
                        coin.image!,
                        width: 50,
                        height: 50,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.currency_bitcoin,
                            size: 30,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coin.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            coin.symbol,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${NumberFormat('#,##0.00').format(coin.currentPrice)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priceColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                                color: priceColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: priceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: PriceChart(
                    coinId: widget.coinId,
                    days: _getDaysForTimeframe(_selectedTimeframe),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _timeframes.map((timeframe) {
                      final isSelected = timeframe == _selectedTimeframe;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            timeframe,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : theme.hintColor,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedTimeframe = timeframe;
                            });
                            context.read<CryptoProvider>().fetchCoinChart(
                                  widget.coinId,
                                  _getDaysForTimeframe(timeframe),
                                );
                          },
                          backgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey[200],
                          selectedColor: Colors.blue.withOpacity(0.3),
                          checkmarkColor: Colors.blue,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '📊 Statistics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.0,
                  children: [
                    _buildCompactStatCard(
                      context,
                      'Market Cap',
                      '\$${_formatLargeNumber(coin.marketCap)}',
                      Icons.account_balance,
                      Colors.blue,
                    ),
                    _buildCompactStatCard(
                      context,
                      '24h Volume',
                      '\$${_formatLargeNumber(coin.totalVolume)}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildCompactStatCard(
                      context,
                      'Circulating',
                      _formatSupply(coin.circulatingSupply),
                      Icons.circle,
                      Colors.orange,
                    ),
                    _buildCompactStatCard(
                      context,
                      'Total Supply',
                      _formatSupply(coin.totalSupply),
                      Icons.hourglass_empty,
                      Colors.purple,
                    ),
                    _buildCompactStatCard(
                      context,
                      'Max Supply',
                      _formatSupply(coin.maxSupply),
                      Icons.maximize,
                      Colors.cyan,
                    ),
                    _buildCompactStatCard(
                      context,
                      '24h Change',
                      '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                      Icons.percent,
                      priceColor,
                      isPercentage: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (coin.communityData != null) ...[
                  Text(
                    '👥 Community',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildCommunityChip(
                        context,
                        'Twitter',
                        coin.communityData?['twitter_followers'],
                        Icons.people,
                      ),
                      _buildCommunityChip(
                        context,
                        'Reddit',
                        coin.communityData?['reddit_subscribers'],
                        Icons.people_outline,
                      ),
                      _buildCommunityChip(
                        context,
                        'Telegram',
                        coin.communityData?['telegram_channel_user_count'],
                        Icons.send,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isPercentage = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPercentage ? color : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityChip(
    BuildContext context,
    String label,
    dynamic value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.hintColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value?.toString() ?? 'N/A',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDaysForTimeframe(String timeframe) {
    switch (timeframe) {
      case '1D':
        return '1';
      case '7D':
        return '7';
      case '30D':
        return '30';
      case '90D':
        return '90';
      case '1Y':
        return '365';
      default:
        return '7';
    }
  }

  String _formatLargeNumber(double num) {
    if (num >= 1e12) return '${(num / 1e12).toStringAsFixed(2)}T';
    if (num >= 1e9) return '${(num / 1e9).toStringAsFixed(2)}B';
    if (num >= 1e6) return '${(num / 1e6).toStringAsFixed(2)}M';
    return NumberFormat('#,##0').format(num);
  }

  String _formatSupply(double? supply) {
    if (supply == null) return 'N/A';
    if (supply >= 1e9) return '${(supply / 1e9).toStringAsFixed(2)}B';
    if (supply >= 1e6) return '${(supply / 1e6).toStringAsFixed(2)}M';
    return NumberFormat('#,##0').format(supply);
  }
}
