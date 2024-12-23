import 'package:flutter/material.dart';
import '../services/stock_service.dart';
import '../screens/stock_details_page.dart';
class StockList extends StatefulWidget {
  final Map<String, dynamic>? userData;

  final List<Stock> stocks;
  final Future<void> Function() onRefresh; // Callback for refreshing data

  const StockList({
    Key? key,
    required this.stocks,
    required this.onRefresh,
    required this.userData,
  }) : super(key: key);

  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  late List<Stock> _currentStocks;

  @override
  void initState() {
    super.initState();
    _currentStocks = widget.stocks;
  }

  @override
  void didUpdateWidget(covariant StockList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateStocks(widget.stocks);
  }

  void _updateStocks(List<Stock> newStocks) {
    bool hasChanged = false;
    for (int i = 0; i < newStocks.length; i++) {
      if (i >= _currentStocks.length || _currentStocks[i] != newStocks[i]) {
        hasChanged = true;
        break;
      }
    }

    if (hasChanged) {
      setState(() {
        _currentStocks = newStocks;
      });
    }
  }

  Color _getChangeColor(String? change) {
    if (change != null) {
      final parsedChange = double.tryParse(change);
      if (parsedChange != null && parsedChange >= 0) {
        return Colors.green.withOpacity(0.1);
      } else if (parsedChange != null) {
        return Colors.red.withOpacity(0.1);
      }
    }
    return Colors.grey.withOpacity(0.1);
  }

  IconData _getChangeDirectionIcon(String? change) {
    if (change != null) {
      final parsedChange = double.tryParse(change);
      if (parsedChange != null && parsedChange >= 0) {
        return Icons.arrow_upward;
      } else if (parsedChange != null) {
        return Icons.arrow_downward;
      }
    }
    return Icons.remove;
  }

  String _formatChange(String? change) {
    if (change == null) return '0.00';
    final parsedChange = double.tryParse(change);
    if (parsedChange != null) {
      return parsedChange.toStringAsFixed(2).padRight(5).substring(0, 5);
    }
    return change.length > 5 ? change.substring(0, 5) : change;
  }

  Color _getChangeIconColor(String? change) {
    if (change != null) {
      final parsedChange = double.tryParse(change);
      if (parsedChange != null && parsedChange >= 0) {
        return Colors.green[700]!;
      } else if (parsedChange != null) {
        return Colors.red[700]!;
      }
    }
    return Colors.grey[700]!;
  }

  Widget _buildInfoTag(String label, dynamic value) {
    return Text(
      '$label: ${value ?? ''}',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh, // Use the passed callback
      child: ListView.builder(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: _currentStocks.length,
        itemBuilder: (context, index) {
          final stock = _currentStocks[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Card(
              key: ValueKey(stock.symbol), // Unique key for each stock
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockDetailPage(
                        symbol: stock.symbol ?? '',
                        userData: widget.userData,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  stock.symbol ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      (stock.name?.length ?? 0) > 20
                                          ? '${stock.name?.substring(0, 20) ?? ''}...'
                                          : stock.name ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                        Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildInfoTag('Vol', stock.volume),
                                const SizedBox(width: 12),
                                _buildDot(),
                                const SizedBox(width: 12),
                                _buildInfoTag('P/E', stock.peRatio),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${stock.price ?? ''}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getChangeColor(stock.change),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getChangeDirectionIcon(stock.change),
                                    size: 14,
                                    color: _getChangeIconColor(stock.change),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatChange(stock.change) ?? ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _getChangeIconColor(stock.change),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}