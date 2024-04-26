import 'package:flutter/material.dart';

class SuffocateTab extends StatelessWidget {
  const SuffocateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: Image.asset(
          'assets/images/suffocate.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
