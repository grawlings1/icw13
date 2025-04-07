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
      routes: {
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);
    
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
    
class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RegisterEmailSection(auth: _auth),
              SizedBox(height: 20),
              EmailPasswordForm(auth: _auth),
            ],
          ),
        ),
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
      Navigator.pushReplacementNamed(context, '/profile');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already in use. Please use the login form.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.message}')),
        );
      }
      print('Registration error: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
      print('Registration error: $e');
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
              decoration: InputDecoration(
                labelText: 'Password (min 6 characters)',
              ),
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

class EmailPasswordForm extends StatefulWidget {
  final FirebaseAuth auth;
  const EmailPasswordForm({Key? key, required this.auth}) : super(key: key);
    
  @override
  _EmailPasswordFormState createState() => _EmailPasswordFormState();
}
    
class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = false;
  bool _initialState = true;
  String _userEmail = '';
    
  void _signIn() async {
    try {
      await widget.auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        _success = true;
        _userEmail = _emailController.text.trim();
        _initialState = false;
      });
      Navigator.pushReplacementNamed(context, '/profile');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.message}')),
      );
      print('Sign in error: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
      print('Sign in error: $e');
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
              'Sign In',
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
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter a password';
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signIn();
                }
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 10),
            if (!_initialState)
              Text(
                _success ? 'Signed in as $_userEmail' : 'Sign in failed',
                style: TextStyle(color: _success ? Colors.green : Colors.red),
              )
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
    
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
    
class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
    
  Future<void> _changePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password change failed: $e')),
        );
      }
    }
  }
    
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Enter new password"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_newPasswordController.text.trim().length >= 6) {
                  _changePassword(_newPasswordController.text.trim());
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password must be at least 6 characters')),
                  );
                }
              },
              child: Text("Change"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
    
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Firebase Auth Demo')),
    );
  }
    
  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String email = user?.email ?? 'No Email';
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showChangePasswordDialog,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
