import 'package:flutter/material.dart';

class FloodTab extends StatelessWidget {
  const FloodTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: Image.asset(
          'assets/images/fldtps.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
