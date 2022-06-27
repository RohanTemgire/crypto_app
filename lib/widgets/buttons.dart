import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final String buttonText;
  final Color color;
  final Icon icon;
  final VoidCallback function;
  const Buttons(
      {Key? key,
      required this.buttonText,
      this.color = const Color.fromARGB(246, 23, 126, 228),
      required this.icon,
      required this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03,
      ),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          icon,
          TextButton(
            onPressed: function,
            child: Text(buttonText),
            style: TextButton.styleFrom(
                primary: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
        ],
      ),
    );
  }
}
