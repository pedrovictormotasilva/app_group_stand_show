import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final String cpf;
  int? roleId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.cpf,
    this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      cpf: json['cpf'],
      roleId: json['roleId'],
    );
  }

  get isActive => null;
}


Future<void> updateUserRole(User user, String roleId, String? authToken) async {
  try {
    final response = await http.put(
      Uri.parse(
          'http://localhost:3333/attUsers'), 
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'roleId': roleId,
      }),
    );

    if (response.statusCode == 200) {
      user.roleId = roleId as int?;
    } else {
      throw Exception('Falha na atualização da API');
    }
  } catch (error) {
    print('Erro: $error');
  }
}

Future<String?> fetchAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString("accessToken");
  print("AuthToken: $authToken"); 
  return authToken;
}

