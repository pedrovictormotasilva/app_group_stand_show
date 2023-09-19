import 'package:flutter/material.dart';
import 'package:email_password_login/apiDart/api_functions.dart';
import 'package:email_password_login/screens/dashboard_screen.dart';
import 'package:email_password_login/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? authToken;
  String? userName;
  String? userEmail;
  int? userRoleId; 

  Future<User> getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3333/Usuarios'),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> userDataList = json.decode(response.body);
        if (userDataList.isNotEmpty) {
          final Map<String, dynamic> userData = userDataList[0];
          return User.fromJson(userData);
        } else {
          throw Exception('Nenhum usuário encontrado na resposta da API');
        }
      } else {
        throw Exception('Falha ao buscar informações do usuário');
      }
    } catch (error) {
      throw Exception('Erro na solicitação HTTP: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAuthToken().then((token) {
      if (token != null) {
        setState(() {
          authToken = token;
        });
        fetchUserInfo(token);
      }
    });
  }

  Future<void> fetchUserInfo(String token) async {
    try {
      final user = await getUserInfo(token);

      setState(() {
        userName = user.name;
        userEmail = user.email;
        userRoleId = user.roleId; 
      });
    } catch (error) {
      print('Erro ao buscar informações do usuário: $error');
    }
  }

  Future<void> handleLogout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bem-vindo"),
        centerTitle: true,
        actions: [
          if (userName != null)
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Informações do Usuário'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nome: $userName'),
                          Text('Email: $userEmail'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            handleLogout();
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 150,
                child: Image.asset("assets/logo.png", fit: BoxFit.contain),
              ),
              const Text(
                "Bem-vindo de volta!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              userRoleId == 4
                  ? ActionChip(
                      label: Text("Painel Administrativo"),
                      onPressed: () async {
                        final authToken = await fetchAuthToken();
                        if (authToken != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DashboardScreen(authToken: authToken),
                            ),
                          );
                        }
                      },
                    )
                  : Container(), 
            ],
          ),
        ),
      ),
    );
  }
}
