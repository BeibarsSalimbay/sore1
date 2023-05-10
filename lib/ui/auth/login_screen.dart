import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sore_beta_1/ui/auth/signup_screen.dart';
import 'package:sore_beta_1/ui/main_pages/post_screen.dart';
import 'package:sore_beta_1/utills/utills.dart';
import 'package:sore_beta_1/widgets/round_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  static const Color color1 = Color(0xFF3A4E5F);
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void login(){
    setState(() {
      loading = true;
    });
    _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text.toString()).then((value) {
          Utills().toastMessage(value.user!.email.toString());
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=> PostScreen())
          );
          setState(() {
            loading = false;
          });
    }).onError((error, stackTrace){
      debugPrint(error.toString());
      Utills().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children:[
             Image(image: AssetImage('assets/images/logo.png'),height: 200.0, width: 200.0,),
             Form(
                 key: _formKey,
                 child: Column(
                   children: [
                     TextFormField(
                       keyboardType: TextInputType.emailAddress,
                       controller: emailController,
                       decoration: const InputDecoration(
                           hintText: 'Email-ды еңгізіңіз',
                           prefixIcon: Icon(Icons.alternate_email)
                       ),
                       validator: (value){
                         if(value!.isEmpty){
                           return 'Email еңгізіңіз';
                         }
                         return null;
                       },
                     ),
                     const SizedBox(height: 10,),
                     TextFormField(
                       keyboardType: TextInputType.text,
                       controller: passwordController,
                       obscureText: true,
                       decoration: const InputDecoration(
                           hintText: 'Құпия сөз еңгізіңіз',
                           prefixIcon: Icon(Icons.lock_open)
                       ),
                       validator: (value){
                         if(value!.isEmpty){
                           return 'Password еңгізіңіз';
                         }
                         return null;
                       },
                     ),
                   ],
                 )),
             const SizedBox(height: 50,),
              RoundButton(
                  title: 'Кіру',
                  loading: loading,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
              ),
             const SizedBox(height: 50,),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text("Аккаунтыңыз жоқ па?"),
                 TextButton(onPressed: (){
                   Navigator.push(context,
                       MaterialPageRoute(
                           builder: (context)=> SignUpScreen())
                   );
                 },
                     child: Text('Тіркелу'))
               ],
             )
           ],
        ),
      ),
      ),
    );
  }
}
