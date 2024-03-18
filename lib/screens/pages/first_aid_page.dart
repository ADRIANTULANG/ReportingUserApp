import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../widgets/text_widget.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  List images = [
    'burn 1.png',
    'blood-droplet 1.png',
    'injury 1.png',
    'antibacterial 1.png',
    'heart-attack 1.png',
    'shock-sign 1.png'
  ];

  List names = [
    'BURN',
    'BLEEDING',
    'INJURY',
    'ALLERGIES',
    'HEART ATTACK',
    'SHOCK'
  ];

  List links = [
    'https://www.verywellhealth.com/first-aid-for-burns-5208710',
    'https://www.verywellhealth.com/how-to-control-bleeding-1298304',
    'https://www.verywellhealth.com/sports-injuries-4013926',
    'https://www.verywellhealth.com/how-food-allergy-is-treated-4773095',
    'https://www.verywellhealth.com/heart-attack-7229012',
    'https://www.verywellhealth.com/types-of-shock-4018329'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(251, 128, 222, 243).withOpacity(0.5),
          title: TextWidget(
            text: 'FIRST AID TIPS',
            fontSize: 18,
            color: const Color.fromARGB(255, 8, 8, 8),
            fontFamily: 'Bold',
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: GridView.builder(
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                await launchUrlString(links[index]);
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  elevation: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130, // Adjust the width as needed
                        height: 130, // Adjust the height as needed
                        child: Image.asset(
                          'assets/images/${images[index]}',
                          fit: BoxFit.cover, // Adjust the BoxFit as needed
                        ),
                      ),
                      TextWidget(
                        text: names[index],
                        fontSize: 18,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
