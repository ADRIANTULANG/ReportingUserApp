import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:responder/screens/pages/add_report_page.dart';
import 'package:responder/screens/pages/coping_main_page.dart';
import 'package:responder/screens/pages/first_aid_page.dart';
import 'package:responder/screens/pages/notif_page.dart';
// import 'package:responder/screens/pages/notif_page.dart';
import 'package:responder/screens/pages/tracking_tab.dart';
import 'package:responder/screens/pages/weather_page.dart';
import 'package:responder/widgets/drawer_widget.dart';

import '../widgets/text_widget.dart';
import 'pages/history_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      updateFcmToken();
    });
    super.initState();
  }

  updateFcmToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"fcmToken": token});
      log("token updated");
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(251, 128, 222, 243).withOpacity(0.5),
        title: TextWidget(
          text: 'HOME',
          fontSize: 18,
          color: const Color.fromARGB(255, 7, 7, 7),
          fontFamily: 'Bold',
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 10),
            child: Badge(
              label: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Notifs')
                      .where('status', isEqualTo: 'Pending')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print('error');
                      return const Center(child: Text('Error'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        )),
                      );
                    }

                    final data = snapshot.requireData;
                    return TextWidget(
                      text: data.docs.length.toString(),
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    );
                  }),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const NotifPage()));
                },
                icon: const Icon(
                  Icons.notifications,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AddReportPage()));
                },
                child: card('REPORT ACCIDENT', Icons.report)),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HistoryReportTab()));
                },
                child: card('HISTORY REPORT', Icons.history)),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CopingMainScreen()));
                },
                child: card('DISASTER COPING TIPS', Icons.warning)),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FirstAidScreen()));
                },
                child: card('LEARN FIRSTAID', Icons.medical_information)),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const WeatherScreen()));
                },
                child: card('WEATHER ALERTS', Icons.sunny)),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const TrackingTab()));
                },
                child: card('TRACKING', Icons.map_outlined)),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Image.asset(
                'assets/images/image 1.png',
                width: 80,
                //alignment: Alignment.bottomLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget card(String title, IconData icon) {
    return Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(251, 128, 222, 243).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ListTile(
          leading: Icon(
            icon,
            color: const Color.fromARGB(255, 10, 10, 10),
          ),
          title: TextWidget(
            text: title,
            fontSize: 18,
            color: const Color.fromARGB(255, 5, 5, 5),
            fontFamily: 'Bold',
          ),
        ),
      ),
    );
  }
}
