import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmController = TextEditingController();
  static const Color color1 = Color(0xFF3A4E5F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: color1,
          title: const Text('Тіркелу беті'),
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(image: AssetImage('assets/images/logo.png'),height: 200.0, width: 200.0,),
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Атыңызды еңгізіңіз',
                          prefixIcon: Icon(Icons.person)
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email-ды еңгізіңіз',
                          prefixIcon: Icon(Icons.alternate_email)
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Құпиясөз еңгізіңіз',
                          prefixIcon: Icon(Icons.lock_open)
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Құпиясөзді растаңыз',
                          prefixIcon: Icon(Icons.lock_open)
                      ),
                    ),
                    const SizedBox(height: 30,),
                    ElevatedButton(
                        onPressed: () async {
                          var fullName = fullNameController.text.trim();
                          var email = emailController.text.trim();
                          var password = passwordController.text.trim();
                          var confirmPass = confirmController.text.trim();

                          if (fullName.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty ||
                              confirmPass.isEmpty) {


                            Fluttertoast.showToast(msg: 'Барлық мәліметтреді толтырыңыз');
                            return;
                          }

                          if (password.length < 6) {
                            Fluttertoast.showToast(msg: 'Құпия сөз әлсіз, кемінде 6 таңба қажет');
                            return;
                          }

                          if (password != confirmPass) {
                            Fluttertoast.showToast(msg: 'Құпия сөздер сәйкес келмейді');
                            return;
                          }

                          ProgressDialog progressDialog = ProgressDialog(
                            context,
                            title: const  Text('Тіркелу'),
                            message: const Text('Күте тұрыңыз'),
                          );

                          progressDialog.show();
                          try {

                            FirebaseAuth auth = FirebaseAuth.instance;

                            UserCredential userCredential =
                            await auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                            if (userCredential.user != null) {

                              DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users');
                              String uid = userCredential.user!.uid;
                              int dt = DateTime.now().millisecondsSinceEpoch;

                              await userRef.child(uid).set({
                                'fullName': fullName,
                                'email': email,
                                'uid': uid,
                                'dt': dt,
                                'profileImage': ''
                              });

                              Fluttertoast.showToast(msg: 'Сәтті тіркелді');
                              Navigator.of(context).pop();
                            } else {
                              Fluttertoast.showToast(msg: 'Қате');
                            }

                            progressDialog.dismiss();

                          } on FirebaseAuthException catch (e) {
                            progressDialog.dismiss();
                            if (e.code == 'email-already-in-use') {
                              Fluttertoast.showToast(msg: 'Электрондық пошта қолданыста');
                            } else if (e.code == 'weak-password') {
                              Fluttertoast.showToast(msg: 'Құпия сөз әлсіз');
                            }
                          } catch (e) {
                            progressDialog.dismiss();
                            Fluttertoast.showToast(msg: 'Бірдеңе дұрыс болмады');
                          }
                          },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Тіркелу',
                              style: TextStyle(fontSize: 20)),
                        ),
                      style:
                      ElevatedButton.styleFrom(primary: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}