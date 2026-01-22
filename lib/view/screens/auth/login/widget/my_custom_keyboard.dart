import 'package:flutter/material.dart';

class MyCustomKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onDone;

  const MyCustomKeyboard({
    super.key,
    required this.controller,
    this.onDone,
  });

  @override
  State<MyCustomKeyboard> createState() => _MyCustomKeyboardState();
}

class _MyCustomKeyboardState extends State<MyCustomKeyboard> {
  bool isUpperCase = false;
  bool isSymbol = false;

  final List<String> letters = [
    'q','w','e','r','t','y','u','i','o','p',
    'a','s','d','f','g','h','j','k','l',
    'z','x','c','v','b','n','m',
  ];

  final List<String> numbers = ['1','2','3','4','5','6','7','8','9','0'];

  final List<String> symbols = [
    '@','.','-','_','!','?','/','\\',
    '#','\$','%','&','*','(',')',
    '[',']','{','}','+','=','\'','"',
    ':',';','<','>',','
  ];

  void _addText(String value) {
    widget.controller.text += value;
  }

  void _delete() {
    if (widget.controller.text.isNotEmpty) {
      widget.controller.text =
          widget.controller.text.substring(0, widget.controller.text.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = isSymbol ? symbols : letters;

    return Container(
      height: 360,
      padding: const EdgeInsets.all(6),
      color: Colors.grey.shade300,
      child: Column(
        children: [
          // NUMBERS
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: numbers.map(_keyButton).toList(),
          ),

          const SizedBox(height: 8),

          // LETTERS / SYMBOLS
          Expanded(
            child: GridView.count(
              crossAxisCount: 8,
              childAspectRatio: 1.2,
              children: keys.map((e) {
                final value = isUpperCase ? e.toUpperCase() : e;
                return _keyButton(value);
              }).toList(),
            ),
          ),

          // ACTIONS
          Row(
            children: [
              _actionKey('SHIFT', () {
                setState(() => isUpperCase = !isUpperCase);
              }),
              _actionKey(isSymbol ? 'ABC' : '?123', () {
                setState(() => isSymbol = !isSymbol);
              }),
              _actionKey('SPACE', () => _addText(' '), flex: 2),
              _actionKey('DEL', _delete),
              _actionKey(
                'DONE',
                () {
                  Navigator.pop(context);
                  widget.onDone?.call();
                },
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyButton(String text) {
    return GestureDetector(
      onTap: () => _addText(text),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _actionKey(
    String text,
    VoidCallback onTap, {
    int flex = 1,
    Color color = Colors.black87,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
