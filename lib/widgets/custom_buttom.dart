import 'package:flutter/material.dart';

class CustomButtom extends StatelessWidget {
   CustomButtom({required this.name , this.onTap}) ;
   
  VoidCallback? onTap;
  String name;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(32),
        ),
        child:  Center(
          child:Text(name ,
            style:    const TextStyle(color: Colors.white),
          ),
        ),
        width: double.infinity,
        height: 60,
      ),
    );
  }
}
