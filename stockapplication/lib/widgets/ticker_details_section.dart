import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import '../models/stock_detail_model.dart';

class TickerDetailsSection extends StatelessWidget {
  final String symbol;
  final Map<String, dynamic>? offlineData;
  final bool Function() isMarketOpen;
  final Future<void> Function(Map<String, dynamic>) storeOfflineData;
  final Widget historicalDataWidget;
  final Widget playGameWidget; // New parameter

  const TickerDetailsSection({
    Key? key,
    required this.symbol,
    required this.offlineData,
    required this.isMarketOpen,
    required this.storeOfflineData,
    required this.historicalDataWidget,
    required this.playGameWidget,
  }) : super(key: key);

  static const String getTickerDetailsQuery = r'''
    query getTickerDetails($symbol: String!) {
      getTickerDetails(symbol: $symbol) {
        previousClose
        openPrice
        bid {
          price
          size
        }
        ask {
          price
          size
        }
        daysRange {
          low
          high
        }
        weekRange {
          low
          high
        }
        volume
        avgVolume
        marketCap
        beta
        peRatio
        eps
        earningsDate {
          startDate
          endDate
        }
        dividendYield
        exDividendDate
        targetEstimate
      }
    }
  ''';

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Center( // Center for horizontal and vertical centering
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
            height: 2,  // Adjust the line height; 1.5 is an example multiplier
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({required List<Widget> children}) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value, {IconData? icon}) {
    final textTheme = Theme.of(context).textTheme;
    final displayValue = (value == null || value.isEmpty) ? '—' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final volumeFormat = NumberFormat.compact();

    String formatCurrency(String? value) {
      final parsed = double.tryParse(value ?? '');
      if (parsed == null) return '—';
      return numberFormat.format(parsed);
    }

    String formatVolume(String? value) {
      final parsed = double.tryParse(value ?? '');
      if (parsed == null) return '—';
      return volumeFormat.format(parsed);
    }

    return Query(
      options: QueryOptions(
        document: gql(getTickerDetailsQuery),
        variables: {'symbol': symbol},
      ),
      builder: (QueryResult result, {fetchMore, refetch}) {
        if (result.isLoading && offlineData == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (result.hasException && offlineData == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Sorry, an error occurred while fetching data.\n${result.exception.toString()}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        final stockDetailData = result.data?['getTickerDetails'] ?? offlineData;
        if (stockDetailData == null) {
          return const Center(
            child: Text(
              'No Data Available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final stockDetail = StockDetail.fromJson(stockDetailData);

        // Store data offline if market is closed and we have fresh fetched data
        if (!result.isLoading && result.data != null && !isMarketOpen()) {
          storeOfflineData(result.data!['getTickerDetails']);
        }

        return RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.purpleAccent,
          onRefresh: () async => await refetch?.call(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 16),

              _buildSectionHeader(context, 'Historical Data'),
              // Ensure historicalDataWidget has bounded height
              SizedBox(
                height: 445, // Adjust the height as needed
                child: historicalDataWidget,
              ),

              _buildSectionHeader(context, 'Play Game'),
              // Ensure playGameWidget has bounded height
              SizedBox(
                height: 300, // Adjust the height as needed
                child: playGameWidget,
              ),

              _buildSectionHeader(context, 'Price Information'),
              _buildCardSection(
                children: [
                  const SizedBox(height: 5),
                  _buildDetailRow(context, 'Previous Close', formatCurrency(stockDetail.previousClose), icon: Icons.attach_money),
                  _buildDetailRow(context, 'Open', formatCurrency(stockDetail.openPrice), icon: Icons.open_in_new),
                  if (stockDetail.bid != null)
                    _buildDetailRow(
                      context,
                      'Bid',
                      '${formatCurrency(stockDetail.bid?.price)} x ${stockDetail.bid?.size ?? '—'}',
                      icon: Icons.arrow_circle_down,
                    ),
                  if (stockDetail.ask != null)
                    _buildDetailRow(
                      context,
                      'Ask',
                      '${formatCurrency(stockDetail.ask?.price)} x ${stockDetail.ask?.size ?? '—'}',
                      icon: Icons.arrow_circle_up,
                    ),
                  if (stockDetail.daysRange != null)
                    _buildDetailRow(
                      context,
                      'Day\'s Range',
                      '${formatCurrency(stockDetail.daysRange?.low)} - ${formatCurrency(stockDetail.daysRange?.high)}',
                      icon: Icons.calendar_today,
                    ),
                  if (stockDetail.weekRange != null)
                    _buildDetailRow(
                      context,
                      '52 Week Range',
                      '${formatCurrency(stockDetail.weekRange?.low)} - ${formatCurrency(stockDetail.weekRange?.high)}',
                      icon: Icons.date_range,
                    ),
                  const SizedBox(height: 5),
                ],
              ),
              _buildCardSection(
                children: [
                  const SizedBox(height: 5),
                  _buildDetailRow(context, 'Volume', formatVolume(stockDetail.volume), icon: Icons.bar_chart),
                  _buildDetailRow(context, 'Avg Volume', formatVolume(stockDetail.avgVolume), icon: Icons.show_chart),
                  _buildDetailRow(context, 'Market Cap', stockDetail.marketCap ?? '—', icon: Icons.business),
                  _buildDetailRow(context, 'Beta', stockDetail.beta ?? '—', icon: Icons.trending_up),
                  _buildDetailRow(context, 'PE Ratio', stockDetail.peRatio ?? '—', icon: Icons.calculate),
                  _buildDetailRow(context, 'EPS', stockDetail.eps ?? '—', icon: Icons.paid),
                  const SizedBox(height: 5),
                ],
              ),

              _buildCardSection(
                children: [
                  const SizedBox(height: 5),
                  if (stockDetail.earningsDate != null)
                    _buildDetailRow(
                      context,
                      'Earnings Date',
                      '${stockDetail.earningsDate?.startDate ?? '—'} - ${stockDetail.earningsDate?.endDate ?? '—'}',
                      icon: Icons.event,
                    ),
                  _buildDetailRow(context, 'Dividend Yield', stockDetail.dividendYield ?? '—', icon: Icons.savings),
                  _buildDetailRow(context, 'Ex-Dividend Date', stockDetail.exDividendDate ?? '—', icon: Icons.date_range),
                  _buildDetailRow(context, '1y Target Est', formatCurrency(stockDetail.targetEstimate), icon: Icons.flag),
                  const SizedBox(height: 5),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
