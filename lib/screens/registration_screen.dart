// ignore_for_file: prefer_const_declarations, unused_local_variable, dead_code, library_private_types_in_public_api
import 'dart:convert';
import 'package:email_password_login/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final cpfEditingController = TextEditingController();

  Future<void> registerUser(
      String name, String cpf, String email, String password) async {
    final String apiUrl = "http://localhost:3333/cadastro";

    final user = {
      "name": name,
      "email": email,
      "password": password,
      "cpf": cpf,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      print(data);
      print("Usuário cadastrado com sucesso!");
    } else {
      print("Erro ao cadastrar o usuário.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstNameField = TextFormField(
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.name,
      validator: (name) {
        if (name == null || name.isEmpty) {
          return "Insira seu nome";
        }
        ;
        if (name.length < 3) {
          return "Nome de usuario muito curto";
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_circle),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Primeiro nome",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final cpfField = TextFormField(
      autofocus: false,
      controller: cpfEditingController,
      keyboardType: TextInputType.name,
      validator: (cpf) {
        if (cpf == null || cpf.isEmpty) {
          return "Insira seu CPF";
        }
        if (cpf.length < 11 || cpf.length > 11) {
          return "CPF'S válidos tem 11 caracteres";
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_circle),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "CPF ",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (email) {
        if (email == null || email.isEmpty) {
          return "Por favor, insira um e-mail ";
        } else if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailEditingController.text)) {
          return 'Por favor, digite um e-mail válido';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      validator: (password) {
        if (password == null || password.isEmpty) {
          return "Por favor, digite uma senha";
        } else if (password.length < 6) {
          return "A senha deve conter no mínimo 6 caracteres";
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Senha",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: const Color.fromARGB(255, 35, 77, 26),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          String name = nameEditingController.text;
          String cpf = cpfEditingController.text;
          String email = emailEditingController.text;
          String password = passwordEditingController.text;
          registerUser(
            name,
            cpf,
            email,
            password,
          );
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (_formKey.currentState!.validate()) {
            bool deuCerto = await registrar();
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }

            if (deuCerto = true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            } else {
              passwordEditingController.clear();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }

          return null;
        },
        child: Text(
          "Cadastre-se",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: const Color.fromARGB(255, 35, 77, 26)),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 180,
                      child: Image.asset(
                        "assets/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 45),
                    firstNameField,
                    SizedBox(height: 20),
                    cpfField,
                    SizedBox(height: 20),
                    emailField,
                    SizedBox(height: 20),
                    passwordField,
                    SizedBox(height: 20),
                    signUpButton,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> registrar() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.parse('http://localhost:3333/cadastro');
    var response = await http.post(
      url,
      body: {
        'username': emailEditingController.text,
        'password': passwordEditingController.text,
        'name': nameEditingController.text,
        'cpf': cpfEditingController.text,
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }

  final snackBar = SnackBar(
    content: Text(
      "Email ou senha são inválidos",
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.redAccent,
  );
}
