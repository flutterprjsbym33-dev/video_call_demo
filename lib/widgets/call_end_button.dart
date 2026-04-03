import 'package:flutter/material.dart';
class CallEndButton extends StatelessWidget {

  VoidCallback onTap;
   CallEndButton({super.key,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, minimumSize: Size.fromHeight(50)),
      child: const Icon(Icons.call_end),
    );
  }
}
