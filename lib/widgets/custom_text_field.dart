import 'package:flutter/material.dart';

class CustomFormTextField extends StatelessWidget {
   CustomFormTextField({Key? key,  this.hintText ,this.onChanged,this.obsecureText = false}) : super(key: key) ;
String? hintText;
bool? obsecureText ;
Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
obscureText: obsecureText!,
      validator: (data) {
        if(data!.isEmpty){
          return 'field is requird';
        }
      },
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(32),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }
}