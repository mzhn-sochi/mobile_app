import 'dart:io';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile_app/auth.dart';
import 'package:mime/mime.dart';

class TokenRefreshException implements Exception {
  final String message;
  TokenRefreshException([this.message = "Token refresh failed"]);

  @override
  String toString() => "TokenRefreshException: $message";
}

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
  String? title;
  final String address;
  final int status;
  final int createdAt;

  TicketInLsit({
    required this.uuid,
    required this.image,
    // required this.title,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  factory TicketInLsit.fromJson(Map<String, dynamic> json) {
    return TicketInLsit(
      uuid: json['id'],
      image: json['imageUrl'],
      address: json['shopAddress'],
      status: json['status'],
      createdAt: json['createdAt'],
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

  static Future<List<TicketInLsit>> fetchTicketList() async {
    final result = await _get('v1/user/tickets/?limit=1000&offset=0');

    var tickets = List<Map<String, dynamic>>.from(result['data'])
        .map((json) => TicketInLsit.fromJson(json))
        .toList();
    return tickets;
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return await _post('v1/auth/sign-in',
        data: {'phone': email, 'password': password});
  }

  static Future<Map<String, dynamic>> register(
      String phone, String password) async {
    return await _post('v1/auth/sign-up',
        data: {'phone': phone, 'password': password});
  }

  static Future<Map<String, dynamic>> refreshToken(String token) async {
    return await _post('v1/auth/refresh', data: {'refreshToken': token});
  }

  static Future<dynamic> createTicket(
      File pricetagImage, String address) async {
    Map<String, dynamic> data = {
      'address': address,
      'pricetag': pricetagImage,
    };

    return await _postForm('v1/tickets', data: data);
  }

  static Future<dynamic> _get(String endpoint) async {
    final token = await AuthClass.jwtToken;
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // Pass 'endpoint' to handle potential retry
    return _handleResponse(response, endpoint);
  }

  static Future<dynamic> _post(String endpoint,
      {required Map<String, dynamic> data}) async {
    final token = await AuthClass.jwtToken;
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    // Pass 'endpoint', 'data', and indicate this is a POST request to handle potential retry
    return _handleResponse(response, endpoint, data: data, isPost: true);
  }

  static Future<dynamic> _postForm(String endpoint,
      {required Map<String, dynamic> data}) async {
    final token = await AuthClass.jwtToken;
    final uri = Uri.parse('$_baseUrl/$endpoint');

    // Create a new multipart request
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Content-Type'] = 'multipart/form-data';

    // Add fields to the request
    data.forEach((key, value) {
      if (value is File) {
        // Determine the MIME type of the file
        final mimeTypeData = lookupMimeType(value.path)?.split('/');
        final mediaType = mimeTypeData != null && mimeTypeData.length == 2
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : MediaType('application',
                'octet-stream'); // Default MIME type if unable to detect

        // Add the file as a file part
        request.files.add(
          http.MultipartFile(
            key,
            value.readAsBytes().asStream(),
            value.lengthSync(),
            filename: value.path.split('/').last,
            contentType: mediaType,
          ),
        );
      } else {
        // Otherwise, add it as a field
        request.fields[key] = value.toString();
      }
    });

    // Send the request and wait for the response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Pass 'endpoint', 'data', and indicate this is a POST request to handle potential retry
    return _handleResponse(response, endpoint, data: data, isPost: true, isMultipart: true);
  }

  static dynamic _handleResponse(http.Response response, String endpoint,
      {Map<String, dynamic>? data,
      bool isPost = false,
      bool isMultipart = false}) async {
    if (response.statusCode == 401) {
      // Assuming 401 means token expired
      final refreshTokenSuccess = await AuthClass.refreshToken();
      if (refreshTokenSuccess) {
        if (isPost) {
          if (isMultipart) {
            // Retry multipart form data post
            return _postForm(endpoint, data: data!);
          } else {
            // Retry regular JSON body post
            return _post(endpoint, data: data!);
          }
        } else {
          // Retry get request
          return _get(endpoint);
        }
      } else {
        throw TokenRefreshException();
      }
    } else if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
