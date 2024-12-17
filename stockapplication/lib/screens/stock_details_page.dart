import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class StockDetailPage extends StatelessWidget {
  final String symbol;

  const StockDetailPage({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  // Define the GraphQL query
  static const String getTickerDetailsQuery = r'''
    query getTickerDetails($symbol: String!) {
      getTickerDetails(symbol: $symbol) {
        previousClose
        openPrice
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getTickerDetailsQuery),
          variables: {'symbol': symbol},
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          // Handle loading state
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (result.hasException) {
            return Center(
              child: Text(
                'Error: ${result.exception.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Extract data
          final stockData = result.data?['getTickerDetails'];

          if (stockData == null) {
            return const Center(
              child: Text(
                'No Data Available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Safely parse numeric values
          final previousClose = double.tryParse(stockData['previousClose']?.toString() ?? '') ?? 0.0;
          final openPrice = double.tryParse(stockData['openPrice']?.toString() ?? '') ?? 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              await refetch?.call();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Symbol: $symbol',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Previous Close: ${numberFormat.format(previousClose)}',
                        style: const TextStyle(fontSize: 22),
                      ),
                      Text(
                        'Open Price: ${numberFormat.format(openPrice)}',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
