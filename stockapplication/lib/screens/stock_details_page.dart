import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_detail_model.dart';
import '../widgets/historical_data_section.dart';
import '../widgets/ticker_details_section.dart';
import '../widgets/play_game.dart'; // Import the PlayGame widget


class StockDetailPage extends StatelessWidget {
  final String symbol;
  final Map<String, dynamic>? userData;

  const StockDetailPage({
    Key? key,
    required this.symbol,
    required this.userData,
  }) : super(key: key);

  bool _isMarketOpen() {
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    final openingTime = DateTime(now.year, now.month, now.day, 9, 30);
    final closingTime = DateTime(now.year, now.month, now.day, 16, 0);

    if (now.weekday >= 1 && now.weekday <= 5) {
      return now.isAfter(openingTime) && now.isBefore(closingTime);
    } else {
      return false; // Weekend
    }
  }

  Future<void> storeOfflineData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stockDetail_$symbol', jsonEncode(data));
    await prefs.setString('stockDetail_${symbol}_timestamp', DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>?> getOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('stockDetail_$symbol');
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          symbol.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: true,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: getOfflineData(),
            builder: (context, snapshot) {
              final offlineData = snapshot.data;

              return TickerDetailsSection(
                symbol: symbol,
                offlineData: offlineData,
                isMarketOpen: _isMarketOpen,
                storeOfflineData: storeOfflineData,
                playGameWidget: PlayGame(symbol: symbol, userData: userData),
                historicalDataWidget: HistoricalDataSection(symbol: symbol),
              );
            },
          ),
        ),
      ),
    );
  }
}
