import 'dart:convert';
import 'package:email_password_login/apiDart/api_functions.dart';
import 'package:email_password_login/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required String authToken})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];
  String? authToken;

  @override
  void initState() {
    super.initState();
    fetchAuthToken().then((token) {
      if (token != null) {
        setState(() {
          authToken = token;
        });

        _fetchUsers(authToken!);
      }
    });
  }

  Future<void> _fetchUsers(String authToken) async {
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
          filteredUsers = List.from(users); // Inicialmente, ambos são iguais
        });
      } else {
        throw Exception('Falha ao buscar dados da API');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  Future<void> _updateUserRole(
      User user, int newRoleId, String? authToken) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3333/attUsers/${user.id}'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': user.name,
          'email': user.email,
          'roleId': newRoleId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          user.roleId = newRoleId;
        });
      } else {
        throw Exception('Falha na atualização da API');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  Future<void> _updateUserName(
      User user, String newName, String? authToken) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3333/attUsers/${user.id}'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': newName,
          'email': user.email,
          'roleId': user.roleId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          user.name = newName;
        });
      } else {
        throw Exception('Falha na atualização da API');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) =>
              user.name != null && user.name.toLowerCase().contains(query))
          .toList();
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) {
                _filterUsers(query.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                dataTextStyle: TextStyle(
                  fontSize: 14,
                ),
                columns: const [
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role ID')),
                  DataColumn(label: Text('ID')),
                ],
                rows: filteredUsers
                    .map(
                      (user) => DataRow(
                        cells: [
                          DataCell(
                            TextFormField(
                              initialValue: user.name ?? '',
                              style: TextStyle(fontSize: 14),
                              onChanged: (String newName) {
                                setState(() {
                                  user.name = newName;
                                });
                                _updateUserName(user, newName, authToken);
                              },
                            ),
                          ),
                          DataCell(Text(user.email)),
                          DataCell(
                            DropdownButton<int>(
                              value: int.tryParse(
                                      user.roleId?.toString() ?? '1') ??
                                  1,
                              onChanged: (int? newRoleId) {
                                if (newRoleId != null) {
                                  _updateUserRole(user, newRoleId, authToken);
                                }
                              },
                              items: [
                                DropdownMenuItem<int>(
                                  value: 1,
                                  child: Text('Cliente'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 2,
                                  child: Text('Comerciante'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 3,
                                  child: Text('Projetista'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 4,
                                  child: Text('Admin'),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(user.id.toString())),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
