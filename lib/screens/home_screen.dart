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
  Future<User> getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3333/Usuarios'), // Substitua pela URL correta da API.
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> userDataList = json.decode(response.body);
        if (userDataList.isNotEmpty) {
          final Map<String, dynamic> userData =
              userDataList[0]; // Acesse o primeiro usuário na lista.
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
      });
    } catch (error) {
      print('Erro ao buscar informações do usuário: $error');
    }
  }

  Future<void> handleLogout() async {
    // Implemente a lógica de logout aqui, se necessário
    // Por exemplo, remova o token JWT e redirecione para a tela de login
    // Aqui você pode usar a função removeAuthToken() se tiver sido definida
    // para remover o token JWT do SharedPreferences.
    // Exemplo:
    // await removeAuthToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bem vindo"),
        centerTitle: true,
        actions: [
          if (userName != null)
            IconButton(
              icon: Icon(Icons.person), // Ícone de usuário
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
                "Bem vindo de volta!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  ActionChip(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
