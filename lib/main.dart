import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acuses/inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    isLoggedIn = widget.isLoggedIn;
    if (isLoggedIn) {
      _checkLoginState();
    }
  }

  void _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('is_logged_in') ?? false;

    if (loggedIn) {
      int userId = prefs.getInt('user_id') ?? 0;
      String userName = prefs.getString('user_name') ?? '';
      setState(() {
        isLoggedIn = true;
      });
      UserIdSingleton.setUserId(userId);
      UserIdSingleton.setUserName(userName);
    }
  }

  void _saveLoginState(int userId, String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('user_id', userId);
    prefs.setBool('is_logged_in', true);
    prefs.setString('user_name', userName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(
              onLogin: (userId, userName) {
                UserIdSingleton.setUserId(userId);
                UserIdSingleton.setUserName(userName);
                _saveLoginState(userId, userName);
                _checkLoginState();
              },
            ),
        '/home': (context) => isLoggedIn ? InterInicio(userName: UserIdSingleton.userName, userId: UserIdSingleton.userId) : LoginScreen(onLogin: (userId, userName) {}),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Function(int, String) onLogin;

  LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int? userId;

  bool isPasswordVisible = false;

  Future<void> _login(BuildContext context) async {
    if (userController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Por favor, completa todos los campos",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Color(0xFFAA182C),
        textColor: Colors.white,
      );
      return;
    }

    var url =
        Uri.parse('https://pruebas.septlaxcala.gob.mx/app/loginP.php');

    var data = {
      'user': userController.text,
      'pass': passwordController.text,
    };

    var response = await http.post(url, body: data);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result != null &&
          result['success'] != null &&
          result['user_id'] != null &&
          result['user_name'] != null) {
        setState(() {
          userId = result['user_id'];
          String userName = result['user_name'];
          print('User ID: $userId, User Name: $userName');
          widget.onLogin(userId!, userName);
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InterInicio(userName: result['user_name'])),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Contraseña o usuario incorrectos",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/textura.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 200.0,
                    height: 200.0,
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: "Usuario",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  ElevatedButton(
                    onPressed: () => _login(context),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Color(0xFF572772),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(
                          maxWidth: double.infinity,
                          minHeight: 50.0,
                        ),
                        child: Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 22.0),
                  // InkWell(
                  //   onTap: () {
                  //     print("Forgot Password tapped");
                  //   },
                  //   child: Text(
                  //     "¿Olvidaste tu contraseña?",
                  //     style: TextStyle(
                  //       fontSize: 18.0,
                  //       color: Color(0xFF572772),
                  //       decoration: TextDecoration.underline,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserIdSingleton {
  static int? _userId;
  static String _userName = '';

  static int? get userId => _userId;
  static String get userName => _userName;

  static setUserId(int id) {
    _userId = id;
  }

  static setUserName(String name) {
    _userName = name;
  }
}
