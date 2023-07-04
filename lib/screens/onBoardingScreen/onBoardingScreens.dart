import 'package:flutter/material.dart';
import '../authScreens/signUpScreen.dart';
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<String> _imagePaths = [
    'assets/onBoarding1.png',
    'assets/onBoarding2.png',
    'assets/onBoarding3.png',
    'assets/onBoarding4.png',
  ];
  List<String> _imageTitles = [
    'تطبيق فكرني ',
    'هو معاد الدوا امتي؟ ',
    'هو انا فين؟ ',
    'هو مين ده؟',
  ];
  List<String> _imageDescriptions = [
    'لمساعدة المرضي المصابين بالزهايمر في رحلتهم الشاقة ',
    'احنا بنساعدك تفتكر كل المواعيد الهامة بتاعتك من غير متشغل بالك  (مواعيد الادوية - مواعيد المقابلات- مواعيد دفع الاشتراكات ...) ',
    'لو انت تايه و مش عارف انت فين او لو انت عايز تروح لمكان معين و مش عارف فاحنا بنساعدك في كل ده متشلتش هم',
    'احنا بنساعدك تفتكر كل الناس اللي حواليك  وكمان نعرفك بيانتهم في جدول سهل و بسيط عشان متشلش هم حاجة',
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildPageIndicator() {
    List<Widget> indicators = [];

    for (int i = 0; i < _imagePaths.length; i++) {
      indicators.add(
        i == _currentPage ? _buildIndicator(true) : _buildIndicator(false),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators,
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: _imagePaths.length,
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    return ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _imagePaths[index],
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              _imageTitles[index],
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              _imageDescriptions[index],
                              style: TextStyle(fontSize: 16.0),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 32.0),
              _buildPageIndicator(),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(), // Replace NextScreen with your desired screen
                    ),
                  );
                },
                child: Text('تسجيل دخول'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(), // Replace NextScreen with your desired screen
                    ),
                  );
                },
                child: Text('انشاء حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
