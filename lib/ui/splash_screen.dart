import 'package:flutter/material.dart';
import 'package:sore_beta_1/firebase_services/splash_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  SplashServices splashScreen = SplashServices();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splashScreen.isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(image: AssetImage('assets/images/logo.png'),height: 300.0,
              width: 300.0,),
            const SizedBox(height: 50,),
            Text('Powered by Beibars',
                style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, color: Colors.black26))
          ],
        ),
      ));
  }
}
