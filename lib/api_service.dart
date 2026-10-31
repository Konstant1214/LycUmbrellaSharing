import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Адрес сервера (на компьютере)
  static const String baseUrl = 'http://localhost:3000/api';

  // Регистрация
  static Future<Map<String, dynamic>> register({
    required String name,
    required String login,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'login': login,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': 'Ошибка соединения с сервером'};
    }
  }

  // Авторизация
  static Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': 'Ошибка соединения с сервером'};
    }
  }

  // Получить профиль
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Ошибка загрузки профиля'};
      }
    } catch (e) {
      return {'error': 'Ошибка соединения с сервером'};
    }
  }

  // Получить все терминалы
  static Future<List<dynamic>> getTerminals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/terminals'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Создать аренду
  static Future<Map<String, dynamic>> createRental({
    required int userId,
    required int terminalId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rentals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'terminalId': terminalId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': 'Ошибка соединения с сервером'};
    }
  }

  // Завершить аренду
  static Future<Map<String, dynamic>> endRental(int rentalId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rentals/$rentalId/end'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Ошибка завершения аренды'};
      }
    } catch (e) {
      return {'error': 'Ошибка соединения с сервером'};
    }
  }

  // Получить активную аренду
  static Future<Map<String, dynamic>?> getActiveRental(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rentals/active/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
