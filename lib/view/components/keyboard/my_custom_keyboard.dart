import 'package:flutter/material.dart';

class MyCustomKeyboard extends StatelessWidget {
  final TextEditingController controller;

  const MyCustomKeyboard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.grey[200],
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(12, (index) {
          String value;
          if (index < 9) {
            value = '${index + 1}';
          } else if (index == 9) {
            value = 'C'; // Clear
          } else if (index == 10) {
            value = '0';
          } else {
            value = '<'; // Delete
          }
          return GestureDetector(
            onTap: () {
              if (value == 'C') {
                controller.clear();
              } else if (value == '<') {
                if (controller.text.isNotEmpty) {
                  controller.text =
                      controller.text.substring(0, controller.text.length - 1);
                }
              } else {
                controller.text += value;
              }
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2)
                ],
              ),
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
