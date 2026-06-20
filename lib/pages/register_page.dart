import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scholar_chat/constants.dart';
import 'package:scholar_chat/helper/show_snack_bar.dart';
import 'package:scholar_chat/widgets/custom_buttom.dart';
import 'package:scholar_chat/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? email;

  String? password;

  bool isLoading = false;

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
            //warbed the column with form to validate the custom text field
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
                  style:
                      const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const Spacer(
                  flex: 2,
                ),
                const Text(
                  "Register",
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
                  onChanged: (data) {
                    password = data;
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
                        await registerUser();
                         Navigator.pushNamed(context, 'ChatPage');
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          showSnackBar(context, 'weak password');
                        } else if (e.code == 'email-already-in-use') {
                          showSnackBar(context, 'email already in use');
                        }
                      } catch (e) {
                        showSnackBar(context, 'there was an error');
                      }
                      isLoading = false;
                      setState(() {
                        
                      });
                     
                    } else {}
                  },
                  name: 'Register',
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'LOGIN',
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

  

  Future<void> registerUser() async {
    UserCredential user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email!, password: password!);
  }
}
