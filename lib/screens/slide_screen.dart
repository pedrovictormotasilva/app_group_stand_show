import 'package:email_password_login/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:email_password_login/screens/registration_screen.dart';

class SlideScreen extends StatefulWidget {
  const SlideScreen({Key? key}) : super(key: key);

  @override
  _SlideScreenState createState() => _SlideScreenState();
}

class _SlideScreenState extends State<SlideScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 400.0,
              child: PageView(
                controller: _controller,
                children: <Widget>[
                  Slide("Bem-vindo ao App", "Este é um aplicativo incrível!",
                      Icons.star),
                  Slide(
                      "Recursos Incríveis",
                      "Descubra todos os recursos emocionantes",
                      Icons.access_alarm),
                  Slide("Comece Agora",
                      "Registre-se ou faça login para começar", Icons.check),
                ],
              ),
            ),
            _currentPage == _numPages - 1
                ? Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 35, 77, 26),
                        ),
                        child: Text("Sou novo aqui",
                            style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 35, 77, 26),
                        ),
                        child: Text("Já sou cliente",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

class Slide extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  Slide(this.title, this.description, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 100.0,
            color: const Color.fromARGB(255, 35, 77, 26),
          ),
          SizedBox(height: 16.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
