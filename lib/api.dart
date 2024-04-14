import 'dart:io';
import 'dart:convert';
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

enum TicketStatus {
  waitingOCR,
  waitingValidation,
  waitingApproval,
  closed,
  rejected,
}

class TicketInLsit {
  final String id;
  final String image;
  final String shopName;
  final String address;
  final TicketStatus status;
  final int createdAt;
  int? updatedAt;

  TicketInLsit({
    required this.id,
    required this.image,
    required this.shopName,
    required this.address,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory TicketInLsit.fromJson(Map<String, dynamic> json) {
    return TicketInLsit(
      id: json['id'],
      image: json['imageUrl'],
      shopName: json['shopName'],
      address: json['shopAddress'],
      status: TicketStatus.values[json['status']],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Profile {
  final String phone;
  final String lastName;
  final String firstName;
  final String middleName;

  Profile({
    required this.phone,
    required this.lastName,
    required this.firstName,
    required this.middleName,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      phone: json['phone'],
      lastName: json['lastName'],
      firstName: json['firstName'],
      middleName: json['middleName'],
    );
  }
}

class TicketView {
  final String id;
  final String image;
  final String shopName;
  final String address;
  final TicketStatus status;
  final int createdAt;
  int? updatedAt;
  String? reason;

  String? itemName;
  String? itemPrice;

  TicketView({
    required this.id,
    required this.image,
    required this.shopName,
    required this.address,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.reason,
    this.itemName,
    this.itemPrice
  });

  factory TicketView.fromJson(Map<String, dynamic> json) {
    return TicketView(
      id: json['id'],
      image: json['imageUrl'],
      shopName: json['shopName'],
      address: json['shopAddress'],
      status: TicketStatus.values[json['status']],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      reason: json['reason'],
      itemName: json['item']?['name'],
      itemPrice: json['item']?['price'],
    );
  }
}

class ApiClient {
  static const String _baseUrl =
      'http://77.221.158.75:8080/api'; // Замените на ваш базовый URL

  static Future<Profile> fetchProfile() async {
    var response = await _get('v1/profile');

    return Profile.fromJson(response['data']);
  }

  static Future<List<TradePoint>> fetchTradePoints(
      double longitude, double latitude, int count) async {
    final response =
        await _get('v1/suggestions?lon=$longitude&lat=$latitude&count=$count');
    List<dynamic> data = response['data'];
    return data.map((json) => TradePoint.fromJson(json)).toList();
  }

  static Future<List<TicketInLsit>> fetchTicketList() async {
    final result = await _get('v1/user/tickets/?limit=1000&offset=0');

    var tickets = List<Map<String, dynamic>>.from(result['data'])
        .map((json) => TicketInLsit.fromJson(json))
        .toList();
    return tickets;
  }

  
  static Future<TicketView> fetchTicket(String id) async {
    final response = await _get('v1/tickets/$id');

    return TicketView.fromJson(response['data']);
  }
  

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return await _post('v1/auth/sign-in',
        data: {'phone': email, 'password': password});
  }

  static Future<Map<String, dynamic>> register(String phone, String password,
      String lastName, String firstName, String middleName) async {
    return await _post('v1/auth/sign-up', data: {
      'phone': phone,
      'password': password,
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName
    });
  }

  static Future<Map<String, dynamic>> refreshToken(String token) async {
    return await _post('v1/auth/refresh', data: {'refreshToken': token});
  }

  static Future<dynamic> createTicket(
      File pricetagImage, String address, String shopName) async {
    Map<String, dynamic> data = {
      'address': address,
      'pricetag': pricetagImage,
      'shopName': shopName,
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
    return _handleResponse(response, endpoint,
        data: data, isPost: true, isMultipart: true);
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
