import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sentiment Analysis\n'
          'Developed with Flutter\n'
          'Data Mining course - Group 1 final project'),
    );
  }
}
