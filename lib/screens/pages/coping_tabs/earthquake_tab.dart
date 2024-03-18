import 'package:flutter/material.dart';

class EarthquakeTab extends StatelessWidget {
  const EarthquakeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: Image.asset(
          'assets/images/erthqktps.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
