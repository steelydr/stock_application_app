import 'dart:convert'; // Remove if not needed
import 'package:intl/intl.dart'; // Remove if not needed

class PriceSize {
  final String price;
  final int size;

  PriceSize({
    required this.price,
    required this.size,
  });

  factory PriceSize.fromJson(Map<String, dynamic> json) {
    return PriceSize(
      price: json['price']?.toString() ?? '',
      size: json['size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'price': price,
    'size': size,
  };
}

class Range {
  final String low;
  final String high;

  Range({
    required this.low,
    required this.high,
  });

  factory Range.fromJson(Map<String, dynamic> json) {
    return Range(
      low: json['low']?.toString() ?? '',
      high: json['high']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'low': low,
    'high': high,
  };
}

class EarningsDate {
  final String startDate;
  final String endDate;

  EarningsDate({
    required this.startDate,
    required this.endDate,
  });

  factory EarningsDate.fromJson(Map<String, dynamic> json) {
    return EarningsDate(
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'startDate': startDate,
    'endDate': endDate,
  };
}

class StockDetail {
  final String? previousClose;
  final String? openPrice;
  final PriceSize? bid;
  final PriceSize? ask;
  final Range? daysRange;
  final Range? weekRange;
  final String? volume;
  final String? avgVolume;
  final String? marketCap;
  final String? beta;
  final String? peRatio;
  final String? eps;
  final EarningsDate? earningsDate;
  final String? dividendYield;
  final String? exDividendDate;
  final String? targetEstimate;

  StockDetail({
    required this.previousClose,
    required this.openPrice,
    required this.bid,
    required this.ask,
    required this.daysRange,
    required this.weekRange,
    required this.volume,
    required this.avgVolume,
    required this.marketCap,
    required this.beta,
    required this.peRatio,
    required this.eps,
    required this.earningsDate,
    required this.dividendYield,
    required this.exDividendDate,
    required this.targetEstimate,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      previousClose: json['previousClose']?.toString(),
      openPrice: json['openPrice']?.toString(),
      bid: json['bid'] != null ? PriceSize.fromJson(json['bid']) : null,
      ask: json['ask'] != null ? PriceSize.fromJson(json['ask']) : null,
      daysRange: json['daysRange'] != null ? Range.fromJson(json['daysRange']) : null,
      weekRange: json['weekRange'] != null ? Range.fromJson(json['weekRange']) : null,
      volume: json['volume']?.toString(),
      avgVolume: json['avgVolume']?.toString(),
      marketCap: json['marketCap']?.toString(),
      beta: json['beta']?.toString(),
      peRatio: json['peRatio']?.toString(),
      eps: json['eps']?.toString(),
      earningsDate: json['earningsDate'] != null ? EarningsDate.fromJson(json['earningsDate']) : null,
      dividendYield: json['dividendYield']?.toString(),
      exDividendDate: json['exDividendDate']?.toString(),
      targetEstimate: json['targetEstimate']?.toString(),
    );
  }
}
