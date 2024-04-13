import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TradePoint {
  final String title;
  final String subtitle;
  final String distance;

  TradePoint({
    required this.title,
    required this.subtitle,
    required this.distance,
  });

  factory TradePoint.fromJson(Map<String, dynamic> json) {
    return TradePoint(
      title: json['title'],
      subtitle: json['subtitle'],
      distance: json['distance'],
    );
  }
}

class TicketInLsit {
  final String uuid;
  final String image;
  final String title;
  final String address;
  final String status;
  final String date;

  TicketInLsit({
    required this.uuid,
    required this.image,
    required this.title,
    required this.address,
    required this.status,
    required this.date,
  });

  factory TicketInLsit.fromJson(Map<String, dynamic> json) {
    return TicketInLsit(
      uuid: json['uuid'],
      image: json['image'],
      title: json['title'],
      address: json['address'],
      status: json['status'],
      date: json['date'],
    );
  }
}

class ApiClient {
  static const String _baseUrl =
      'http://77.221.158.75:8080/api'; // Замените на ваш базовый URL

  static Future<List<TradePoint>> fetchTradePoints(Position pos, int limit) {
    // Здесь вы можете создать mock-данные или использовать фиктивные данные
    final List<Map<String, dynamic>> mockData = [
      {
        "title": "Магазин 1",
        "subtitle": "Адрес магазина 1",
        "distance": "2.5 км",
      },
      {
        "title": "Магазин 2",
        "subtitle": "Адрес магазина 2",
        "distance": "5 км",
      },
      // Добавьте больше магазинов по мере необходимости
    ];

    return Future.value(
      mockData.map((json) => TradePoint.fromJson(json)).toList(),
    );
  }

  static Future<List<TicketInLsit>> fetchTicketList() {
    final List<Map<String, dynamic>> mockData = [
      {
        'uuid': '',
        'image':
            'https://download.slipenko.com/mzhn-team-sochi/train_dataset_dnr-train/Пример%20ценников%20с%20соц%20ценой/IMG_20240329_095208778~2.jpg',
        'title': 'Супермаркет "Молоко"',
        'address': 'г. Макеевка ул. Ленина, 78',
        'status': 'Обработка',
        'date': '12.02.04'
      },
      {
        'uuid': '',
        'image':
            'https://download.slipenko.com/mzhn-team-sochi/train_dataset_dnr-train/Пример%20ценников%20с%20соц%20ценой/IMG_20240329_095208778~2.jpg',
        'title': 'Супермаркет "Молоко"',
        'address': 'г. Макеевка ул. Ленина, 78',
        'status': 'Обработка',
        'date': '12.02.04'
      },
      // Добавьте больше магазинов по мере необходимости
    ];

    return Future.value(
      mockData.map((json) => TicketInLsit.fromJson(json)).toList(),
    );
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return await _post('v1/auth/sign-in', data: {'phone': email, 'password': password});
  }

  static Future<Map<String, dynamic>> register(
      String phone, String password) async {
    return await _post('v1/auth/sign-up', data: {'phone': phone, 'password': password});
  }

  static Future<Map<String, dynamic>> refreshToken(String token) async {
    return await _post('v1/auth/refresh', data: {'refresh_token': token});
  }

  static Future<dynamic> _get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  static Future<dynamic> _post(String endpoint,
      {required Map<String, dynamic> data}) async {
        print('$_baseUrl/$endpoint');
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
