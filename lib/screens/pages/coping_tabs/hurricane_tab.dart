import 'package:flutter/material.dart';

class HurricaneTab extends StatelessWidget {
  const HurricaneTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: Image.asset(
          'assets/images/hrrcntps.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
