import 'package:flutter/material.dart';

class FireTab extends StatelessWidget {
  const FireTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: Image.asset(
          'assets/images/frtps.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
