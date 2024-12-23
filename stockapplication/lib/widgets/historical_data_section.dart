import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class HistoricalDataSection extends StatefulWidget {
  final String symbol;

  const HistoricalDataSection({super.key, required this.symbol});

  @override
  State<HistoricalDataSection> createState() => _HistoricalDataSectionState();
}

class _HistoricalDataSectionState extends State<HistoricalDataSection> {
  final List<_TimeRangeOption> _timeRanges = [
    _TimeRangeOption(label: '1M', months: 1),
    _TimeRangeOption(label: '6M', months: 6),
    _TimeRangeOption(label: '1Y', years: 1),
    _TimeRangeOption(label: '10Y', years: 10),
  ];

  _TimeRangeOption _selectedTimeRange = _TimeRangeOption(label: '1M', months: 1);

  String get _startDate {
    final now = DateTime.now();
    DateTime start;
    if (_selectedTimeRange.months != null) {
      start = DateTime(now.year, now.month - _selectedTimeRange.months!, now.day);
    } else if (_selectedTimeRange.years != null) {
      start = DateTime(now.year - _selectedTimeRange.years!, now.month, now.day);
    } else {
      start = now;
    }

    return DateFormat('yyyy-MM-dd').format(start);
  }

  String get _endDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static const String historicalDataQuery = r'''
    query historicalData($symbol: String!, $startDate: String!, $endDate: String!) {
      historicalData(symbol: $symbol, startDate: $startDate, endDate: $endDate) {
        date
        open
        high
        low
        close
        adjClose
        volume
      }
    }
  ''';

  ChartData? _selectedDataPoint;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date range selection row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _timeRanges.map((range) {
                  final bool isSelected = range == _selectedTimeRange;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        range.label,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.amber[400],
                      backgroundColor: Colors.grey[700],
                      onSelected: (selected) {
                        setState(() {
                          _selectedTimeRange = range;
                          _selectedDataPoint = null; // Clear selection when range changes
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // GraphQL Query to fetch data
            Query(
              options: QueryOptions(
                document: gql(historicalDataQuery),
                variables: {
                  'symbol': widget.symbol,
                  'startDate': _startDate,
                  'endDate': _endDate,
                },
              ),
              builder: (QueryResult result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (result.hasException) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'Error fetching historical data:\n${result.exception}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                }

                final historicalData = result.data?['historicalData'];
                if (historicalData == null || (historicalData as List).isEmpty) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'No Historical Data',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                // Parse date using a custom format since the returned date is like "Jan 11, 2024"
                final dateFormatter = DateFormat('MMM d, yyyy');

                List<ChartData> chartData = (historicalData as List).map<ChartData>((data) {
                  final dateString = data['date'];
                  final dateTime = dateFormatter.parse(dateString);
                  return ChartData(
                    date: dateTime,
                    close: double.tryParse(data['close'].toString()) ?? 0.0,
                  );
                }).toList();

                // Sort the data by date to ensure it goes from past (left) to present (right)
                chartData.sort((a, b) => a.date.compareTo(b.date));

                return Stack(
                  children: [
                    GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        _tapPosition = details.localPosition;
                      },
                      child: SizedBox(
                        height: 300,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          zoomPanBehavior: ZoomPanBehavior(
                            enablePanning: true,
                            enablePinching: true,
                          ),
                          primaryXAxis: DateTimeAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            labelStyle: const TextStyle(color: Colors.white70),
                            axisLine: const AxisLine(color: Colors.white54),
                            dateFormat: DateFormat.yMd(),
                          ),
                          primaryYAxis: NumericAxis(
                            majorGridLines: MajorGridLines(
                              dashArray: [5, 5],
                              color: Colors.white24,
                            ),
                            labelStyle: const TextStyle(color: Colors.white70),
                            axisLine: const AxisLine(color: Colors.white54),
                          ),
                          backgroundColor: Colors.transparent,
                          series: <ChartSeries>[
                            LineSeries<ChartData, DateTime>(
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.date,
                              yValueMapper: (ChartData data, _) => data.close,
                              color: Colors.amber[400],
                              width: 2,
                              onPointTap: (ChartPointDetails details) {
                                setState(() {
                                  final tappedIndex = details.pointIndex!;
                                  _selectedDataPoint = chartData[tappedIndex];
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    if (_selectedDataPoint != null)
                      Positioned(
                        top: 50,
                        left: 50,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDataPoint!.date)}\nClose: ${_selectedDataPoint!.close}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final double close;

  ChartData({required this.date, required this.close});
}

class _TimeRangeOption {
  final String label;
  final int? months;
  final int? years;

  const _TimeRangeOption({required this.label, this.months, this.years});
}
