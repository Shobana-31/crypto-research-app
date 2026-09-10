import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/coin_card.dart';
import '../widgets/loading_states.dart';
import 'coin_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.watchlist.isEmpty) {
          return EmptyState(
            title: 'Your watchlist is empty',
            subtitle: 'Tap the ⭐ star icon on any coin to add it',
            icon: Icons.star_border,
            onAction: () {
              Navigator.pop(context);
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.watchlist.length,
          itemBuilder: (context, index) {
            final coin = provider.watchlist[index];
            return CoinCard(
              coin: coin,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoinDetailScreen(coinId: coin.id),
                ),
              ),
              onWatchlistToggle: () {
                provider.toggleWatchlist(coin);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${coin.name} from watchlist'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => provider.toggleWatchlist(coin),
                    ),
                  ),
                );
              },
              isInWatchlist: true,
            );
          },
        );
      },
    );
  }
}
