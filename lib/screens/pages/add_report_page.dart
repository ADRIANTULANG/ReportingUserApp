import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:responder/screens/home_screen.dart';
import 'package:responder/services/add_report.dart';
import 'package:responder/widgets/button_widget.dart';
import 'package:responder/widgets/textfield_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:responder/widgets/toast_widget.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import '../../widgets/text_widget.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

Position? currentPosition;

class _AddReportPageState extends State<AddReportPage> {
  @override
  void initState() {
    super.initState();
    determinePosition();
    addMarker();
  }

  final contactnumberController = TextEditingController();
  final addressController = TextEditingController();
  final captionController = TextEditingController();
  final nameController = TextEditingController();
  double lat = 0;
  double long = 0;
  bool hasLoaded = false;

  addMarker() {
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        lat = position.latitude;
        long = position.longitude;

        hasLoaded = true;
      });
    }).catchError((error) {
      print('Error getting location: $error');
    });
  }

  late String idFileName = '';

  late File idImageFile;

  late String idImageURL = '';

  Future<void> uploadImage(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
      ))!;

      idFileName = path.basename(pickedImage.path);
      idImageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
              title: Row(
                children: [
                  CircularProgressIndicator(
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Loading . . .',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Document/$idFileName')
            .putFile(idImageFile);
        idImageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Document/$idFileName')
            .getDownloadURL();

        Navigator.of(context).pop();
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }

    setState(() {});
  }

  List<String> addressList = [
    "PUROK 1",
    "PUROK 2A",
    "PUROK 2B",
    "PUROK 3A-1",
    "PUROK 3A-2",
    "PUROK 3B",
    "PUROK 4A",
    "PUROK 4B",
    "PUROK 5",
    "PUROK 6"
  ];
  String addressSelected = 'PUROK 1';

  List<String> type1 = [
    'Fire',
    'Hurricane',
    'Flood',
    'Earthquake',
    'Landslide',
    'Others'
  ];
  String selected = 'Fire';

  bool validateFields() {
    return nameController.text.isNotEmpty &&
        contactnumberController.text.isNotEmpty &&
        captionController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(251, 128, 222, 243).withOpacity(0.5),
        centerTitle: true,
        title: TextWidget(
          text: 'REPORT ACCIDENT',
          fontSize: 18,
          color: Colors.black,
          fontFamily: 'Bold',
        ),
      ),
      body: hasLoaded
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextFieldWidget(
                      label: 'Name',
                      controller: nameController,
                      allowOnlyLetters: true,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFieldWidget(
                      height: 75,
                      isNumber: true,
                      inputType: TextInputType.phone,
                      label: 'Contact Number',
                      controller: contactnumberController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.w, bottom: 5.w),
                      child: SizedBox(
                        width: 100.w,
                        child: TextWidget(
                          text: 'Address',
                          fontSize: 14,
                          color: Colors.black,
                          isBold: true,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        value: addressSelected,
                        items: addressList.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Center(
                              child: SizedBox(
                                width: 300,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'QRegular',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            addressSelected = newValue.toString();
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.w, bottom: 5.w),
                      child: SizedBox(
                        width: 100.w,
                        child: TextWidget(
                          text: 'Incident Type',
                          fontSize: 14,
                          color: Colors.black,
                          isBold: true,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        value: selected,
                        items: type1.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Center(
                              child: SizedBox(
                                width: 300,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'QRegular',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selected = newValue.toString();
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFieldWidget(
                      label: 'Description',
                      controller: captionController,
                      // allowOnlyLetters: true,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.w, right: 5.w),
                      child: GestureDetector(
                        onTap: () {
                          uploadImage('gallery');
                        },
                        child: Container(
                          height: 15.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            image: idImageURL.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(idImageURL),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ButtonWidget(
                      label: 'Continue',
                      onPressed: () {
                        if (validateFields()) {
                          previewDialog();
                        } else {
                          showToast('Please complete all required fields!');
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  // final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
  //     .collection('Users')
  //     .doc(FirebaseAuth.instance.currentUser!.uid)
  //     .snapshots();
  // bool hasNumbers(String input) {
  //   // Define a regular expression to match any digit
  //   RegExp digitRegExp = RegExp(r'\d');
  //   // Use the hasMatch method to check if the string contains any digits
  //   return digitRegExp.hasMatch(input);
  // }

  previewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Preview:',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 1.h,
              ),
              TextFieldWidget(
                label: 'Name',
                controller: nameController,
              ),
              SizedBox(
                height: 1.h,
              ),
              TextFieldWidget(
                label: 'Contact Number',
                controller: contactnumberController,
              ),

              SizedBox(
                height: 1.h,
              ),
              TextFieldWidget(
                label: 'Description',
                controller: captionController,
              ),
              SizedBox(
                height: 2.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Address:',
                    fontSize: 14,
                    isBold: true,
                  ),
                  TextWidget(
                    text: ' $addressSelected',
                    fontSize: 14,
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Incident Type:',
                    fontSize: 14,
                    isBold: true,
                  ),
                  TextWidget(
                    text: ' $selected',
                    fontSize: 14,
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              // Display the image only if it's available
              Container(
                height: 15.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  image: idImageURL.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(idImageURL),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: idImageURL.isEmpty
                    ? const Icon(
                        Icons.add,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: TextWidget(
                text: 'Close',
                fontSize: 14.sp,
              ),
            ),
            TextButton(
              onPressed: () {
                addReport(
                  nameController.text,
                  contactnumberController.text,
                  addressSelected,
                  captionController.text,
                  idImageURL,
                  lat,
                  long,
                  selected,
                );
                showToast('Reported successfully!');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              child: TextWidget(
                text: 'Send',
                fontSize: 14.sp,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    currentPosition = await Geolocator.getCurrentPosition();
    return await Geolocator.getCurrentPosition();
  }
}
