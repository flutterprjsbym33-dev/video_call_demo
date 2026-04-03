import 'package:flutter/material.dart';

class UrlTextfield extends StatelessWidget {
  TextEditingController urlController;
   UrlTextfield({super.key,required this.urlController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: urlController,
      decoration:
      InputDecoration(labelText: "Daily Room URL",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15)
          )),
    );
  }
}
