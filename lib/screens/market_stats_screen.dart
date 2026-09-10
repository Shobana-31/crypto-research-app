import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/crypto_provider.dart';

class MarketStatsScreen extends StatelessWidget {
  const MarketStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.globalData.isEmpty) {
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
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchGlobalData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = provider.globalData;
        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No market data available',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchGlobalData(),
                  child: const Text('Load Data'),
                ),
              ],
            ),
          );
        }

        final btcPercentage =
            ((data['market_cap_percentage']?['btc'] ?? 0) as num).toDouble();
        final ethPercentage =
            ((data['market_cap_percentage']?['eth'] ?? 0) as num).toDouble();
        double othersPercentage = 100.0 - btcPercentage - ethPercentage;
        if (othersPercentage < 0) othersPercentage = 0;

        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Market Statistics',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSmallOverviewCard(
                          context,
                          '💰 Total Cap',
                          _formatNumber(data['total_market_cap']?['usd'] ?? 0),
                          Icons.account_balance,
                          Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        _buildSmallOverviewCard(
                          context,
                          '📈 Volume',
                          _formatNumber(data['total_volume']?['usd'] ?? 0),
                          Icons.trending_up,
                          Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _buildSmallOverviewCard(
                          context,
                          '🪙 Coins',
                          NumberFormat('#,##0')
                              .format(data['active_cryptocurrencies'] ?? 0),
                          Icons.currency_bitcoin,
                          Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        _buildSmallOverviewCard(
                          context,
                          '🏪 Markets',
                          NumberFormat('#,##0').format(data['markets'] ?? 0),
                          Icons.storefront,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📊 24h Change',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getChangeColor(
                              data['market_cap_change_percentage_24h_usd'] ?? 0,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${(data['market_cap_change_percentage_24h_usd'] ?? 0).toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getChangeColor(
                                data['market_cap_change_percentage_24h_usd'] ??
                                    0,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🏆 Dominance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSmallDominanceCard(
                          context,
                          'BTC',
                          btcPercentage,
                          Colors.orange,
                          '₿',
                        ),
                        const SizedBox(width: 10),
                        _buildSmallDominanceCard(
                          context,
                          'ETH',
                          ethPercentage,
                          Colors.purple,
                          '⟠',
                        ),
                        const SizedBox(width: 10),
                        _buildSmallDominanceCard(
                          context,
                          'Others',
                          othersPercentage,
                          Colors.grey,
                          '●',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.coins.isNotEmpty) ...[
                    Text(
                      '🚀 Top Gainers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            _getTopGainers(provider.coins).take(5).map((coin) {
                          return _buildSmallCoinCard(
                            context,
                            coin.symbol.toUpperCase(),
                            '+${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                            Colors.green,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (provider.coins.isNotEmpty) ...[
                    Text(
                      '📉 Top Losers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            _getTopLosers(provider.coins).take(5).map((coin) {
                          return _buildSmallCoinCard(
                            context,
                            coin.symbol.toUpperCase(),
                            '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                            Colors.red,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDominanceCard(
    BuildContext context,
    String label,
    double percentage,
    Color color,
    String symbol,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            symbol,
            style: TextStyle(
              fontSize: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: theme.dividerColor,
            color: color,
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCoinCard(
    BuildContext context,
    String symbol,
    String change,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            symbol,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getTopGainers(List<dynamic> coins) {
    final gainers = coins
        .where((coin) => coin.priceChangePercentage24h > 0)
        .toList()
      ..sort((a, b) =>
          b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    return gainers;
  }

  List<dynamic> _getTopLosers(List<dynamic> coins) {
    final losers = coins
        .where((coin) => coin.priceChangePercentage24h < 0)
        .toList()
      ..sort((a, b) =>
          a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
    return losers;
  }

  String _formatNumber(num value) {
    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    return '\$${NumberFormat('#,##0').format(value)}';
  }

  Color _getChangeColor(double change) {
    return change >= 0 ? Colors.green : Colors.red;
  }
}
