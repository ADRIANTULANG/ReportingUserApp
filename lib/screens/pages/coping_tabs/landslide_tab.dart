import 'package:flutter/material.dart';

class LandslideTab extends StatelessWidget {
  const LandslideTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: Image.asset(
          'assets/images/lndsldtps.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
