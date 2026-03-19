import 'package:flutter/material.dart';

class ScrollableText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ScrollableText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
