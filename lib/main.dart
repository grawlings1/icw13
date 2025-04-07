import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
    
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: MyHomePage(title: 'Firebase Auth Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: RegisterEmailSection(auth: FirebaseAuth.instance),
      ),
    );
  }
}

class RegisterEmailSection extends StatefulWidget {
  final FirebaseAuth auth;
  const RegisterEmailSection({Key? key, required this.auth}) : super(key: key);
    
  @override
  _RegisterEmailSectionState createState() => _RegisterEmailSectionState();
}
    
class _RegisterEmailSectionState extends State<RegisterEmailSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = false;
  bool _initialState = true;
  String? _userEmail;
    
  void _register() async {
    try {
      await widget.auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        _success = true;
        _userEmail = _emailController.text.trim();
        _initialState = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.message}')),
      );
      print('Registration error: ${e.code} - ${e.message}');
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Register',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter an email';
                if (!value.contains('@'))
                  return 'Enter a valid email';
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password (min 6 characters)'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter a password';
                if (value.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _register();
                }
              },
              child: Text('Register'),
            ),
            SizedBox(height: 10),
            if (!_initialState)
              Text(
                _success ? 'Registered as $_userEmail' : 'Registration failed',
                style: TextStyle(color: _success ? Colors.green : Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
