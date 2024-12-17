import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/stock_service.dart';
import 'dart:convert';
import 'stock_list_widget.dart';

class TabsSection extends StatefulWidget {
  @override
  _TabsSectionState createState() => _TabsSectionState();
}

class _TabsSectionState extends State<TabsSection>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final StockService _stockService =
  StockService(baseUrl: 'YOUR_BASE_URL_HERE');
  Map<String, List<Stock>>? stockData;
  bool isLoading = true;
  String? error;
  static const String _selectedTabKey = 'selected_tab_index';
  static const String _stockDataKey = 'stockData';
  static const String _timestampKey = 'stockData_timestamp';

  // Market hours constants (assuming US Eastern Time)
  static const int marketOpenHour = 9;  // 9:30 AM ET
  static const int marketCloseHour = 16; // 4:00 PM ET

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadStockData();
  }

  Future<void> _initializeTabController() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_selectedTabKey) ?? 0;

    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: savedIndex,
    );

    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        _saveSelectedTab(_tabController!.index);
      }
    });

    setState(() {});
  }

  Future<void> _saveSelectedTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedTabKey, index);
  }

  bool _isMarketOpen() {
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 4)); // Convert to ET
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return false;
    }
    return now.hour >= marketOpenHour && now.hour < marketCloseHour;
  }

  Future<bool> _isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return false;

    final storedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final currentTime = DateTime.now();

    // If market is closed, cache is valid until next market open
    if (!_isMarketOpen()) {
      final nextMarketOpen = _getNextMarketOpen(currentTime);
      return currentTime.isBefore(nextMarketOpen);
    }

    // During market hours, cache for 1 minute
    return currentTime.difference(storedTime).inMinutes < 1;
  }

  DateTime _getNextMarketOpen(DateTime currentTime) {
    var nextOpen = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      marketOpenHour,
      30,
    );

    // If we're past today's market open, move to next business day
    if (currentTime.hour >= marketOpenHour) {
      nextOpen = nextOpen.add(const Duration(days: 1));
    }

    // Skip weekends
    while (nextOpen.weekday == DateTime.saturday || nextOpen.weekday == DateTime.sunday) {
      nextOpen = nextOpen.add(const Duration(days: 1));
    }

    return nextOpen;
  }

  Future<void> _loadStockData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Check if cached data exists and is valid
      if (await _isCacheValid()) {
        final storedData = prefs.getString(_stockDataKey);
        if (storedData != null) {
          stockData = Map<String, List<Stock>>.from(
            json.decode(storedData).map((key, value) => MapEntry(
                key,
                (value as List)
                    .map((e) => Stock.fromJson(e as Map<String, dynamic>))
                    .toList())),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      // Fetch fresh data from API
      final mostActive = await _stockService.fetchStocks('most-active');
      final trending = await _stockService.fetchStocks('trending');
      final gainers = await _stockService.fetchStocks('gainers');
      final losers = await _stockService.fetchStocks('losers');

      stockData = {
        'Most Active': mostActive,
        'Trending': trending,
        'Gainers': gainers,
        'Losers': losers,
      };

      // Store data with timestamp
      await prefs.setString(
        _stockDataKey,
        json.encode(
          stockData!.map((key, value) =>
              MapEntry(key, value.map((e) => e.toJson()).toList())),
        ),
      );
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _clearExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await _isCacheValid()) {
      await prefs.remove(_stockDataKey);
      await prefs.remove(_timestampKey);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _clearExpiredCache();
    super.dispose();
  }

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load stock data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadStockData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading stocks...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildError();
    }

    if (stockData == null || stockData!.isEmpty) {
      return Center(
        child: Text(
          'No stock data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        StockList(
          stocks: stockData!['Most Active'] ?? [],
          onRefresh: _loadStockData,
        ),
        StockList(
          stocks: stockData!['Trending'] ?? [],
          onRefresh: _loadStockData,
        ),
        StockList(
          stocks: stockData!['Gainers'] ?? [],
          onRefresh: _loadStockData,
        ),
        StockList(
          stocks: stockData!['Losers'] ?? [],
          onRefresh: _loadStockData,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          height: 81,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelPadding: const EdgeInsets.symmetric(vertical: 12),
            tabs: [
              _buildTab(Icons.local_fire_department_outlined, 'Most Active'),
              _buildTab(Icons.trending_up, 'Trending'),
              _buildTab(Icons.arrow_upward_sharp, 'Gainers'),
              _buildTab(Icons.arrow_downward_sharp, 'Losers'),
            ],
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildTab(IconData icon, String tooltip) {
    return Tab(
      height: 64,
      child: Tooltip(
        message: tooltip,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              tooltip,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}