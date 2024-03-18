import 'package:flutter/material.dart';
import 'package:responder/screens/pages/coping_tabs/earthquake_tab.dart';
import 'package:responder/screens/pages/coping_tabs/fire_tab.dart';
import 'package:responder/screens/pages/coping_tabs/flood_tab.dart';
import 'package:responder/screens/pages/coping_tabs/hurricane_tab.dart';
import 'package:responder/screens/pages/coping_tabs/landslide_tab.dart';
import '../../widgets/text_widget.dart';

class CopingMainScreen extends StatelessWidget {
  const CopingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(251, 128, 222, 243).withOpacity(0.5),
        title: TextWidget(
          text: 'COPING TIPS',
          fontSize: 18,
          color: const Color.fromARGB(255, 8, 8, 8),
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const HurricaneTab()));
                      },
                      child:
                          cardWidget('assets/images/image 2.png', 'Hurricane')),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const FloodTab()));
                      },
                      child: cardWidget('assets/images/flood.png', 'Flood')),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const EarthquakeTab()));
                      },
                      child: cardWidget(
                          'assets/images/earthquake.png', 'Earthquake')),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const FireTab()));
                      },
                      child: cardWidget('assets/images/fire 1.png', 'Fire')),

                  //
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LandslideTab()));
                    },
                    child: SizedBox(
                        width: 200,
                        child: cardWidget(
                            'assets/images/landslide.png', 'Landslide')),
                  )
                ],
              ),
            ],
          )),
    );
  }

  Widget card(String title, IconData icon) {
    return Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.white,
          ),
          title: TextWidget(
            text: title,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget cardWidget(String path, String number) {
    return Container(
      width: 160,
      height: 170,
      decoration: BoxDecoration(
        color: Color.fromARGB(248, 188, 190, 190).withOpacity(0.5),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              path,
              height: 90,
            ),
            const SizedBox(
              height: 10,
            ),
            TextWidget(
              text: number,
              fontSize: 24,
              fontFamily: 'Bold',
            ),
          ],
        ),
      ),
    );
  }
}
