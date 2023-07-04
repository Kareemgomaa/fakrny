import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstNameController.text);
    await prefs.setString('lastName', _lastNameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('phone', _phoneController.text);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 50,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'انشاء حساب',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                )
              ]),
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'الاسم الأول',
            ),
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'اسم العائلة',
            ),
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
            ),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              suffixIcon: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    _passwordController.text = _passwordController.text.isEmpty
                        ? ''
                        : _passwordController.text.substring(0, 1);
                  });
                },
              ),
            ),
            obscureText: _passwordController.text.isEmpty,
          ),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveData();
              Navigator.pushNamed(context, '/login');
            },
            child: Text('تسجيل'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text('تمتلك حساب؟ تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    if (_emailController.text == savedEmail &&
        _passwordController.text == savedPassword) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('خطأ في تسجيل الدخول'),
          content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('موافق'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            children: [
              Image.asset('assets/Logo.png'),
              Text(
                'مرحبا بك مرة اخرى',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
            ),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              suffixIcon: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    _passwordController.text = _passwordController.text.isEmpty
                        ? ''
                        : _passwordController.text.substring(0, 1);
                  });
                },
              ),
            ),
            obscureText: _passwordController.text.isEmpty,
          ),
          ElevatedButton(
            onPressed: _login,
            child: Text('تسجيل الدخول'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/reset-password');
            },
            child: Text('هل نسيت كلمة المرور؟'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: Text('ليس لديك حساب؟ إنشاء حساب جديد'),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    if (_emailController.text == savedEmail) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('إعادة تعيين كلمة المرور'),
          content: Text(
              'تم إرسال رابط إعادة تعيين كلمة المرور إلى البريد الإلكتروني المُدخل.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('موافق'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('خطأ في إعادة تعيين كلمة المرور'),
          content: Text('البريد الإلكتروني غير صحيح.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('موافق'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 150,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'اعادة تعيين كلمة السر',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ],
          ),
          SizedBox(
            height: 60,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
            ),
          ),
          ElevatedButton(
            onPressed: _resetPassword,
            child: Text('إعادة تعيين كلمة المرور'),
          ),
        ],
      ),
    );
  }
}
