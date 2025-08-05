import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 59490
class ApiService {
  static const String baseUrl = 'https://mantri.onrender.com';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    print('Token: $token');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('Headers: $headers');
    return headers;
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['access_token']);
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/me'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get user data');
    }
  }

  static Future<Map<String, dynamic>> createGang({
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final headers = await _getHeaders();
    print(
      'Creating gang with data: name=$name, description=$description, isPublic=$isPublic',
    );
    print('Request URL: $baseUrl/gangs');
    print('Headers: $headers');

    final requestBody = {
      'name': name,
      'description': description,
      'is_public': isPublic,
    };
    print('Request body: ${json.encode(requestBody)}');

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/gangs'),
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to create gang');
        } catch (e) {
          print('Error parsing response: $e');
          throw Exception('Failed to create gang: ${response.body}');
        }
      }
    } catch (e) {
      print('Network error: $e');
      if (e.toString().contains('Connection reset by peer') ||
          e.toString().contains('SocketException')) {
        throw Exception('Connection timeout. Please try again.');
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getGang(String gangId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gangs/$gangId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gang not found');
    }
  }

  static Future<void> joinGang(String gangId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/gangs/$gangId/join'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to join gang');
    }
  }

  static Future<Map<String, dynamic>> getGangHome(String gangId) async {
    final headers = await _getHeaders();
    print('Making request to: $baseUrl/gangs/$gangId/home');
    print('Headers: $headers');

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/gangs/$gangId/home'), headers: headers)
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        try {
          final error = json.decode(response.body);
          print('Error response: $error');
          throw Exception(error['detail'] ?? 'Failed to get gang data');
        } catch (e) {
          print('Error parsing response: $e');
          print('Raw response body: ${response.body}');
          throw Exception('Server error: ${response.body}');
        }
      }
    } catch (e) {
      print('Network error: $e');
      if (e.toString().contains('Connection reset by peer') ||
          e.toString().contains('SocketException')) {
        throw Exception('Connection timeout. Please try again.');
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<void> saveToday(String gangId, bool saved) async {
    final headers = await _getHeaders();
    print('Saving today: $saved for gang: $gangId');
    final response = await http.post(
      Uri.parse('$baseUrl/gangs/$gangId/save'),
      headers: headers,
      body: json.encode({'saved': saved}),
    );

    print('Save response status: ${response.statusCode}');
    print('Save response body: ${response.body}');

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      print('Save error: $error');
      throw Exception(error['detail'] ?? 'Failed to save');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserGangs() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/gangs'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get user gangs');
    }
  }

  static Future<List<Map<String, dynamic>>> getChatMessages(
    String gangId,
  ) async {
    final headers = await _getHeaders();
    print('Getting chat messages for gang: $gangId');
    print('Request URL: $baseUrl/gangs/$gangId/chat');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse('$baseUrl/gangs/$gangId/chat'),
      headers: headers,
    );

    print('Chat response status: ${response.statusCode}');
    print('Chat response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Chat messages count: ${data.length}');
      return data.cast<Map<String, dynamic>>();
    } else {
      final error = json.decode(response.body);
      print('Chat error: $error');
      throw Exception(error['detail'] ?? 'Failed to get chat messages');
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
    String gangId,
    String message,
  ) async {
    final headers = await _getHeaders();
    print('Sending message to gang: $gangId, message: $message');
    print('Request URL: $baseUrl/gangs/$gangId/chat');
    print('Headers: $headers');

    final response = await http.post(
      Uri.parse('$baseUrl/gangs/$gangId/chat'),
      headers: headers,
      body: json.encode({'message': message}),
    );

    print('Send message response status: ${response.statusCode}');
    print('Send message response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      print('Send message error: $error');
      throw Exception(error['detail'] ?? 'Failed to send message');
    }
  }

  static Future<List<Map<String, dynamic>>> getGangMembers(
    String gangId,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/gangs/$gangId/members'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to get gang members');
    }
  }

  static Future<void> removeMember(String gangId, int userId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/gangs/$gangId/members/$userId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to remove member');
    }
  }

  static Future<void> leaveGang(String gangId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/gangs/$gangId/leave'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to leave gang');
    }
  }

  static Future<Map<String, dynamic>> getMonthlyLeaderboard(
    String gangId,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/gangs/$gangId/monthly-leaderboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to get monthly leaderboard');
    }
  }

  static Future<void> clearChat(String gangId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/gangs/$gangId/chat'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to clear chat');
    }
  }

  static Future<void> updateProfile(String username) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: headers,
      body: json.encode({'username': username}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update profile');
    }
  }

  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/users/change-password'),
      headers: headers,
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to change password');
    }
  }

  static Future<void> deleteAccount() async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/users/account'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to delete account');
    }
  }

  static Future<List<Map<String, dynamic>>> getGangActivity(
    String gangId,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/gangs/$gangId/activity'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['activities'] ?? []);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to get gang activity');
    }
  }
}
