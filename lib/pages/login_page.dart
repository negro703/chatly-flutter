import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scholar_chat/constants.dart';
import 'package:scholar_chat/helper/show_snack_bar.dart';
import 'package:scholar_chat/widgets/custom_buttom.dart';
import 'package:scholar_chat/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
   LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
    String? email;

  String? password;

  GlobalKey<FormState> formkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(
                  flex: 1,
                ),
                const Text(
                  "Privet Chat",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const Spacer(
                  flex: 2,
                ),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomFormTextField(
                  onChanged: (data) {
                    email = data;
                  },
                  hintText: 'Email',
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomFormTextField(
                  obsecureText: true,
                  onChanged: (data) {
                    password=data;
                  },
                  hintText: 'Password',
                ),
                const SizedBox(
                  height: 100,
                ),
                CustomButtom(
                  onTap: () async {
                    if (formkey.currentState!.validate()) {
                      isLoading = true;
                      setState(() {
                        
                      });
                      try {
                        await loginUser();
                         Navigator.pushNamed(context, 'ChatPage',arguments: email);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          showSnackBar(context, 'user not found');
                        } else if (e.code == 'wrong-password') {
                          showSnackBar(context, 'wrong password');
                        }
                      } catch (e) {
                        print(e);
                        showSnackBar(context, 'there was an error');
                      }
                      isLoading = false;
                      setState(() {
                        
                      });
                     
                    } else {}
                  },
                  name: 'Login',
                ),
                const SizedBox(
                  height: 15,
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('don\'t have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'RegisterPage');
                      },
                      child: const Text(
                        'SIGN UP',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const Spacer(
                  flex: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  

  Future<void> loginUser() async {
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email!, password: password!);
  }
}
