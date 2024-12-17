import 'dart:convert';
import 'package:http/http.dart' as http;

class Stock {
  final String? symbol;
  final String? name;
  final String? price;
  final String? change;
  final String? changePercent;
  final String? volume;
  final String? avgVolume;
  final String? marketCap;
  final String? peRatio;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.avgVolume,
    required this.marketCap,
    required this.peRatio,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      change: json['change']?.toString() ?? '',
      changePercent: json['changePercent']?.toString() ?? '',
      volume: json['volume']?.toString() ?? '',
      avgVolume: json['avgVolume']?.toString() ?? '',
      marketCap: json['marketCap']?.toString() ?? '',
      peRatio: json['peRatio']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'volume': volume,
      'avgVolume': avgVolume,
      'marketCap': marketCap,
      'peRatio': peRatio,
    };
  }

  @override
  String toString() {
    return 'Stock{symbol: $symbol, name: $name, price: \$$price, '
        'change: $change, changePercent: $changePercent%, '
        'volume: $volume, avgVolume: $avgVolume, '
        'marketCap: $marketCap, peRatio: $peRatio}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Stock &&
        other.symbol == symbol &&
        other.name == name &&
        other.price == price &&
        other.change == change &&
        other.changePercent == changePercent &&
        other.volume == volume &&
        other.avgVolume == avgVolume &&
        other.marketCap == marketCap &&
        other.peRatio == peRatio;
  }

  @override
  int get hashCode {
    return symbol.hashCode ^
    name.hashCode ^
    price.hashCode ^
    change.hashCode ^
    changePercent.hashCode ^
    volume.hashCode ^
    avgVolume.hashCode ^
    marketCap.hashCode ^
    peRatio.hashCode;
  }
}


class StockService {
  final String baseUrl;
  final Map<String, String> headers;

  StockService({
    required this.baseUrl,
    Map<String, String>? headers,
  }) : headers = headers ?? {
    'Content-Type': 'application/json;charset=UTF-8',
    'Charset': 'utf-8',
  };

  Future<List<Stock>> fetchStocks(String endpoint) async {
    try {
      final url = Uri.parse('http://192.168.40.86/api/stocks/$endpoint');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = json.decode(responseBody) as List<dynamic>;

        final List<Stock> stocks = jsonList
            .map((json) => Stock.fromJson(json as Map<String, dynamic>))
            .toList();

        return stocks;
      } else {
        throw HttpException('Failed to load stocks. Status code: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      print('Error parsing JSON data: $e');
      throw StockServiceException('Invalid data format received from server');
    } on HttpException catch (e) {
      print('HTTP error occurred: $e');
      throw StockServiceException(e.message);
    } catch (e) {
      print('Unexpected error occurred: $e');
      throw StockServiceException('An unexpected error occurred while fetching stocks');
    }
  }

  Future<Stock> fetchStockBySymbol(String symbol) async {
    try {
      final url = Uri.parse('$baseUrl/api/stocks/symbol/$symbol');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonMap = json.decode(responseBody) as Map<String, dynamic>;
        return Stock.fromJson(jsonMap);
      } else if (response.statusCode == 404) {
        throw StockServiceException('Stock with symbol $symbol not found');
      } else {
        throw HttpException('Failed to load stock. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stock by symbol: $e');
      rethrow;
    }
  }
}

class StockServiceException implements Exception {
  final String message;
  StockServiceException(this.message);

  @override
  String toString() => 'StockServiceException: $message';
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}