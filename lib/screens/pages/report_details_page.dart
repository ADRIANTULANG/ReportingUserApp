import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responder/model/report_history_model.dart';
import 'package:responder/model/responder_details_model.dart';
import 'package:responder/screens/pages/chat_page.dart';
import 'package:responder/widgets/loading_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetails extends StatefulWidget {
  const ReportDetails({super.key, required this.reportDetails});
  final ReportHistory reportDetails;
  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  ResponderDetails? responderDetails;
  Set<Marker> markers = {};
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController? mapController;
  LatLngBounds? bounds;
  CameraPosition? kGooglePlex;
  bool isShowContainer = true;
  TextEditingController remarks = TextEditingController();
  StreamSubscription<dynamic>? locationListener;
  Stream? locationStreamer;
  String distance = '';
  String time = '';

  getResponderDetails() async {
    try {
      if (widget.reportDetails.responder != "" ||
          widget.reportDetails.responder.isNotEmpty) {
        var responder = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.reportDetails.responder)
            .get();
        if (responder.exists) {
          var responderDetail = responder.data();
          log(jsonEncode(responderDetail));
          setState(() {
            responderDetails =
                responderDetailsFromJson(jsonEncode(responderDetail));
          });
        }
      }
    } catch (_) {
      log(_.toString());
    }
  }

  updateRemarks({required String message}) async {
    try {
      LoadingDialog.showLoadingDialog(context: context);
      await FirebaseFirestore.instance
          .collection('Reports')
          .doc(widget.reportDetails.documentId)
          .update({"remarks": message});
      setState(() {
        widget.reportDetails.remarks = message;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (_) {}
  }

  callResponder() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: responderDetails!.contactnumber,
    );
    await launchUrl(launchUri);
  }

  showDialogAddRemarks({required String message}) {
    remarks.text = message;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Remarks",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
            content: SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 15.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all()),
                      child: TextField(
                        maxLines: 5,
                        controller: remarks,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(top: .5.h, left: 2.w),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    SizedBox(
                      height: 6.h,
                      width: 100.w,
                      child: ElevatedButton(
                          onPressed: () {
                            if (remarks.text.isNotEmpty) {
                              Navigator.pop(context);
                              updateRemarks(message: remarks.text);
                            }
                          },
                          child: const Text("ADD")),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  initializedData() async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      LoadingDialog.showLoadingDialog(context: context);
      await getResponderDetails();
      await listenToLocationOfResponder();
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }

  listenToLocationOfResponder() async {
    try {
      locationStreamer = FirebaseFirestore.instance
          .collection('Reports')
          .doc(widget.reportDetails.documentId)
          .snapshots();

      locationListener = locationStreamer!.listen((event) async {
        Map data = event.data();
        if (data.containsKey('responderLat')) {
          var distanceAndTime = await fetchDistanceAndTime(
              LatLng(widget.reportDetails.lat, widget.reportDetails.long),
              LatLng(data['responderLat'], data['responderLong']));
          log(distanceAndTime.toString());
          time = distanceAndTime['durationText'];
          distance = distanceAndTime['distanceText'];
        }
        setState(() {
          markers.clear();
          markers.add(Marker(
            markerId: MarkerId(widget.reportDetails.name),
            icon: BitmapDescriptor.defaultMarker,
            position:
                LatLng(widget.reportDetails.lat, widget.reportDetails.long),
            infoWindow: InfoWindow(
              title: widget.reportDetails.caption,
              snippet: 'Status: ${widget.reportDetails.status}',
            ),
          ));
          if (data.containsKey('responderLat')) {
            LatLng location1 = LatLng(widget.reportDetails.lat,
                widget.reportDetails.long); // Location 1
            LatLng location2 = LatLng(
                data['responderLat'], data['responderLong']); // Location 2

            bounds = LatLngBounds(
              southwest: LatLng(
                location1.latitude < location2.latitude
                    ? location1.latitude
                    : location2.latitude,
                location1.longitude < location2.longitude
                    ? location1.longitude
                    : location2.longitude,
              ),
              northeast: LatLng(
                location1.latitude > location2.latitude
                    ? location1.latitude
                    : location2.latitude,
                location1.longitude > location2.longitude
                    ? location1.longitude
                    : location2.longitude,
              ),
            );
            markers.add(Marker(
              markerId: const MarkerId("ResponderLocation"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position: LatLng(data['responderLat'], data['responderLong']),
              infoWindow: InfoWindow(
                title: "Responder",
                snippet: "${data['name']} ($distance - $time)",
              ),
            ));
            mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds!, 50),
            );
          }
        });
      });
    } catch (_) {
      log("ERROR (listenToLocationOfResponder): $_");
    }
  }

  Future<Map<String, dynamic>> fetchDistanceAndTime(
      LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyDdXaMN5htLGHo8BkCfefPpuTauwHGXItU';
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final legs = data['routes'][0]['legs'][0];
        final distanceText = legs['distance']['text'];
        final distanceValue = legs['distance']['value'];
        final durationText = legs['duration']['text'];
        final durationValue = legs['duration']['value'];

        return {
          'distanceText': distanceText,
          'distanceValue': distanceValue,
          'durationText': durationText,
          'durationValue': durationValue,
        };
      }
    }

    throw Exception('Failed to fetch distance and time');
  }

  @override
  void initState() {
    super.initState();
    kGooglePlex = CameraPosition(
      target: LatLng(widget.reportDetails.lat, widget.reportDetails.long),
      zoom: 14.4746,
    );
    initializedData();
  }

  @override
  void dispose() {
    if (locationListener != null) {
      locationListener!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: kGooglePlex == null
            ? const SizedBox()
            : SizedBox(
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    SizedBox(
                      height: 100.h,
                      width: 100.w,
                      child: GoogleMap(
                        markers: markers,
                        mapType: MapType.normal,
                        initialCameraPosition: kGooglePlex!,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          mapController = controller;
                        },
                      ),
                    ),
                    isShowContainer
                        ? Container(
                            width: 100.w,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 4,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 0), // changes x,y position of shadow
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 5.w, right: 5.w, top: 2.h, bottom: 2.h),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              widget.reportDetails.type,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                            Text(
                                              " (${widget.reportDetails.status})",
                                              style: TextStyle(
                                                color: widget.reportDetails
                                                            .status ==
                                                        "Pending"
                                                    ? Colors.orange
                                                    : Colors.green,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 13.5.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isShowContainer =
                                                    isShowContainer
                                                        ? false
                                                        : true;
                                              });
                                            },
                                            child: const Icon(Icons.clear)),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Text(
                                      widget.reportDetails.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    Text(
                                      widget.reportDetails.contactnumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Text(
                                      widget.reportDetails.address,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Text(
                                      "${DateFormat.yMMMMd().format(widget.reportDetails.dateTime)} ${DateFormat.jm().format(widget.reportDetails.dateTime)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.sp),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Text(
                                      widget.reportDetails.caption,
                                      maxLines: 3,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.sp,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    widget.reportDetails.imageUrl == ""
                                        ? const SizedBox()
                                        : Container(
                                            height: 15.h,
                                            width: 100.w,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(widget
                                                        .reportDetails
                                                        .imageUrl))),
                                          ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    responderDetails != null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Responder Details",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                responderDetails!.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                              Text(
                                                responderDetails!.address,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              Text(
                                                responderDetails!.contactnumber,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(
                                            height: 6.h,
                                            child: Center(
                                              child: Text(
                                                "This report has not yet been responded to by responders.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    widget.reportDetails.status != "Done"
                                        ? const SizedBox()
                                        : widget.reportDetails.remarks.isEmpty
                                            ? SizedBox(
                                                height: 6.h,
                                                width: 100.w,
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialogAddRemarks(
                                                          message: widget
                                                              .reportDetails
                                                              .remarks);
                                                    },
                                                    child: const Text(
                                                        "ADD REMARKS")),
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Remarks",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13.sp,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                          onTap: () {
                                                            showDialogAddRemarks(
                                                                message: widget
                                                                    .reportDetails
                                                                    .remarks);
                                                          },
                                                          child: const Icon(
                                                              Icons.edit))
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                                  Text(
                                                    widget
                                                        .reportDetails.remarks,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ],
                                              )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 9.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 4,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 0), // changes x,y position of shadow
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isShowContainer =
                                        isShowContainer ? false : true;
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 5.w,
                                  backgroundColor: Colors.black,
                                  child: const Icon(
                                    Icons.arrow_upward_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    Positioned(
                        top: 5.h,
                        left: 5.w,
                        child: SizedBox(
                          width: 90.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 7.h,
                                  width: 12.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 4,
                                        blurRadius: 5,
                                        offset: const Offset(0,
                                            0), // changes x,y position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                              responderDetails != null
                                  ? Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            callResponder();
                                          },
                                          child: Container(
                                            height: 7.h,
                                            width: 12.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 4,
                                                  blurRadius: 5,
                                                  offset: const Offset(0,
                                                      0), // changes x,y position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.call,
                                                size: 14.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3.w,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPage(
                                                          reportID: widget
                                                              .reportDetails
                                                              .documentId,
                                                        )));
                                          },
                                          child: Container(
                                            height: 7.h,
                                            width: 12.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 4,
                                                  blurRadius: 5,
                                                  offset: const Offset(0,
                                                      0), // changes x,y position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.message,
                                                size: 14.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ))
                  ],
                ),
              ));
  }
}
