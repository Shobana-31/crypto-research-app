import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/crypto_provider.dart';

class PriceChart extends StatefulWidget {
  final String coinId;

  const PriceChart({super.key, required this.coinId});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoProvider>().fetchCoinChart(widget.coinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        if (provider.isChartLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final chartData = provider.chartData;
        if (chartData == null || chartData.isEmpty) {
          return const Center(
            child: Text(
              'No chart data available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final prices = chartData;
        final minPrice = prices.reduce((a, b) => a < b ? a : b);
        final maxPrice = prices.reduce((a, b) => a > b ? a : b);
        final isPositive = prices.first < prices.last;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7 Day Performance',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${((prices.last - prices.first) / prices.first * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${prices.first.toStringAsFixed(2)} → \$${prices.last.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: prices.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value;
                        final x = index / (prices.length - 1);
                        final y = (value - minPrice) / (maxPrice - minPrice);
                        return FlSpot(x, y);
                      }).toList(),
                      isCurved: true,
                      color: isPositive ? Colors.green : Colors.red,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (isPositive ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: 1,
                  minY: 0,
                  maxY: 1,
                ),
                duration: Duration.zero,
              ),
            ),
          ],
        );
      },
    );
  }
}
