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
          filteredUsers = List.from(users);
        });
      } else {
        throw Exception('Falha ao buscar dados da API');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  Future<void> _updateUser(
    User user,
    String newName,
    String newEmail,
    int newRoleId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3333/attUsers/${user.id}'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': newName,
          'email': newEmail,
          'roleId': newRoleId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          user.name = newName;
          user.email = newEmail;
          user.roleId = newRoleId;
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

  void _editUser(User user) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserDialog(
          user: user,
          updateUser: _updateUser,
        );
      },
    );
  }

  String _getRoleName(int roleId) {
    switch (roleId) {
      case 1:
        return 'Cliente';
      case 2:
        return 'Comerciante';
      case 3:
        return 'Projetista';
      case 4:
        return 'Admin';
      default:
        return '';
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
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  title: Text(user.name ?? ''),
                  subtitle: Text(_getRoleName(user.roleId!)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _editUser(user);
                    },
                    child: Text('Editar'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final User user;
  final Function(User, String, String, int) updateUser;

  const EditUserDialog({
    Key? key,
    required this.user,
    required this.updateUser,
  }) : super(key: key);

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  String newName = '';
  String newEmail = '';
  int newRoleId = 1; 
  @override
  void initState() {
    super.initState();
    newName = widget.user.name ?? '';
    newEmail = widget.user.email ?? '';
    newRoleId = widget.user.roleId!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Usuário'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              initialValue: newName,
              onChanged: (value) {
                setState(() {
                  newName = value;
                });
              },
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextFormField(
              initialValue: newEmail,
              onChanged: (value) {
                setState(() {
                  newEmail = value;
                });
              },
              decoration: InputDecoration(labelText: 'Email'),
            ),
            DropdownButton<int>(
              value: newRoleId,
              onChanged: (value) {
                setState(() {
                  newRoleId = value!;
                });
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
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.updateUser(widget.user, newName, newEmail, newRoleId);

            Navigator.of(context).pop();
          },
          child: Text('Salvar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
      ],
    );
  }
}
