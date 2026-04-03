import 'package:flutter/material.dart';

class JoinButton extends StatelessWidget {

  VoidCallback onTap;
  String hint;
   JoinButton({super.key,required this.onTap,required this.hint});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          )
      ),
      onPressed:onTap,
      child:
          Text(hint,style: TextStyle(color: Colors.white),),
    );
  }
}
