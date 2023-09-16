import 'package:email_password_login/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<User> users = [];
  late String authToken;

  @override
  void initState() {
    super.initState();

    fetchAuthToken().then((token) {
      if (token != null) {
        setState(() {
          authToken = token;
        });

        fetchUsers();
      }
    });
  }

  Future<String?> fetchAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    return token;
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3333/Usuarios'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          users = responseData.map((data) => User.fromJson(data)).toList();
        });
      } else {
        throw Exception('Falha ao buscar dados da API');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  Future<void> updateUserRole(User user, String roleId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3333/Usuarios'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'roleId': roleId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          user.roleId = roleId;
        });
      } else {
        throw Exception('Falha na atualização da API');
      }
    } catch (error) {
      
      print('Erro: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role ID')),
              DataColumn(label: Text('Ativo')),
            ],
            rows: users
                .map(
                  (user) => DataRow(
                    cells: [
                      DataCell(Text(user.id)),
                      DataCell(Text(user.email)),
                      DataCell(Text(user.roleId)),
                      DataCell(Text(user.isActive ? 'Sim' : 'Não')),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            updateUserRole(user, 'NovoRoleIdAqui');
                          },
                          child: Text('Editar'),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class User {
  final String id;
  final String email;
  String roleId;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.roleId,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      roleId: json['roleId'],
      isActive: json['isActive'],
    );
  }
}
