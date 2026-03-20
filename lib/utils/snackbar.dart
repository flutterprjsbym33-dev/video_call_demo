import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SnackBarType{
  Success,
  Error,
}

void ShowSnacBar({
  required BuildContext context,
  required String discrip,
  required SnackBarType type
}){

  switch(type)
  {
    case SnackBarType.Success : CherryToast.success(
      toastDuration: Duration(milliseconds: 2000),
      height: 100,
      toastPosition: Position.top,
      shadowColor: Colors.white.withAlpha(40),
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
      backgroundColor: Colors.green.withAlpha(40),
      description: Text(discrip,style: TextStyle(color: Colors.green),
      ),
      title: Text("Success",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
    ).show(context);
    break;

    case SnackBarType.Error : CherryToast.error(
      toastDuration: Duration(milliseconds: 2000),
      height: 70,
      toastPosition: Position.top,
      shadowColor: Colors.black,
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
      backgroundColor: Colors.green.withAlpha(40),
      description: Text(discrip,style: TextStyle(color: Colors.green),
      ),
      title: Text("Error",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
    ).show(context);
    break;


  }


}