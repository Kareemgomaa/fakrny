import 'package:flutter/material.dart';
import 'package:zakrny_app/screens/onBoardingScreen/onBoardingScreens.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate some loading process
    Future.delayed(Duration(seconds: 3), () {
      // After the loading process is complete, navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => nextScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your splash screen logo or animation here
            Image.asset('assets/Logo.png'),
            SizedBox(height: 16.0),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class nextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingScreen()
    );
  }
}
