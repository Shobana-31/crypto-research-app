import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/crypto_provider.dart';
import '../providers/watchlist_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/coin_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/loading_states.dart';
import 'coin_detail_screen.dart';
import 'market_stats_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CoinListScreen(),
    const WatchlistScreen(),
    const MarketStatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoProvider>().fetchCoins();
      context.read<CryptoProvider>().fetchGlobalData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _showSortDialog() {
    final Map<String, String> sortOptions = {
      'market_cap_desc': 'Market Cap (High to Low)',
      'market_cap_asc': 'Market Cap (Low to High)',
      'price_desc': 'Price (High to Low)',
      'price_asc': 'Price (Low to High)',
      'change_desc': '24h Change (Best)',
      'change_asc': '24h Change (Worst)',
      'volume_desc': 'Volume (High to Low)',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortOptions.entries.map((entry) => ListTile(
                  title: Text(entry.value),
                  leading: Radio<String>(
                    value: entry.key,
                    groupValue: context.watch<CryptoProvider>().sortOrder,
                    onChanged: (value) {
                      context.read<CryptoProvider>().updateSort(value!);
                      Navigator.pop(context);
                    },
                  ),
                  trailing:
                      context.watch<CryptoProvider>().sortOrder == entry.key
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crypto Research'),
          centerTitle: false,
          scrolledUnderElevation: 0,
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                    color: themeProvider.isDark ? Colors.amber : Colors.blue,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  tooltip: 'Toggle Theme',
                );
              },
            ),
            if (_selectedIndex == 0)
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: _showSortDialog,
                tooltip: 'Sort',
              ),
            if (_selectedIndex == 0)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<CryptoProvider>().fetchCoins();
                },
                tooltip: 'Refresh',
              ),
          ],
        ),
        body: Column(
          children: [
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomSearchBar(
                  onSearch: (query) {
                    context.read<CryptoProvider>().searchCoins(query);
                  },
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.currency_bitcoin),
              label: 'Coins',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}

class CoinListScreen extends StatefulWidget {
  const CoinListScreen({super.key});

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  final RefreshController _refreshController = RefreshController();

  Future<void> _onRefresh() async {
    await context.read<CryptoProvider>().fetchCoins();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.coins.isEmpty) {
          return const LoadingShimmer();
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
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchCoins(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final displayedCoins = provider.searchResults;

        if (displayedCoins.isEmpty) {
          return EmptyState(
            title: 'No coins available',
            subtitle: 'Try refreshing the page',
            icon: Icons.currency_bitcoin,
            onAction: () => provider.fetchCoins(),
          );
        }

        return SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayedCoins.length,
            itemBuilder: (context, index) {
              final coin = displayedCoins[index];
              return CoinCard(
                coin: coin,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoinDetailScreen(coinId: coin.id),
                  ),
                ),
                onWatchlistToggle: () {
                  context.read<WatchlistProvider>().toggleWatchlist(coin);
                },
                isInWatchlist:
                    context.watch<WatchlistProvider>().isInWatchlist(coin.id),
              );
            },
          ),
        );
      },
    );
  }
}
