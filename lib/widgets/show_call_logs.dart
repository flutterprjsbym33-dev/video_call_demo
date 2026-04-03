import 'package:flutter/material.dart';

class ShowCallLogs extends StatelessWidget {
  List<String> timeLine;
   ShowCallLogs({super.key,required this.timeLine});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            timeLine.map((t) => Text(t,
          style: const TextStyle(
              fontSize: 12, color: Colors.white),
        ))
            .toList(),
      ),
    );
  }
}
