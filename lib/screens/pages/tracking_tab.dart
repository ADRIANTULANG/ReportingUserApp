import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responder/model/report_history_model.dart';
import 'package:intl/intl.dart';
import 'package:responder/screens/pages/report_details_page.dart';
import 'package:responder/widgets/loading_dialog.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/text_widget.dart';

class TrackingTab extends StatefulWidget {
  const TrackingTab({super.key});

  @override
  State<TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends State<TrackingTab> {
  List<ReportHistory> reportList = <ReportHistory>[];

  getOngoingReport() async {
    LoadingDialog.showLoadingDialog(context: context);
    try {
      var res = await FirebaseFirestore.instance
          .collection('Reports')
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where(Filter.or(
            Filter("status", isEqualTo: 'Pending'),
            Filter("status", isEqualTo: 'Accepted'),
          ))
          .orderBy('dateTime', descending: true)
          .get();
      List data = [];
      var reports = res.docs;
      for (var i = 0; i < reports.length; i++) {
        Map mapdata = reports[i].data();
        mapdata['documentID'] = reports[i].id;
        mapdata['dateTime'] = mapdata['dateTime'].toDate().toString();
        data.add(mapdata);
      }
      log(jsonEncode(data));
      setState(() {
        reportList = reportHistoryFromJson(jsonEncode(data));
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (_) {
      log(_.toString());
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      getOngoingReport();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextWidget(
          text: 'REPORT TRACKING',
          fontSize: 18,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => getOngoingReport(),
        child: Padding(
          padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
          child: reportList.isEmpty
              ? const Center(
                  child: Text("No available data."),
                )
              : ListView.builder(
                  itemCount: reportList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: SizedBox(
                          width: 100.w,
                          child: GestureDetector(
                            onTap: () {
                              // if (reportList[index].responder.isNotEmpty) {
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => MapTab(
                              //           id: reportList[index].documentId,
                              //           docId: reportList[index].responder,
                              //         )));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ReportDetails(
                                        reportDetails: reportList[index],
                                      )));
                              // } else {
                              //   MessageDialog.showMessageDialog(
                              //       context: context,
                              //       message:
                              //           "This report has not yet been acted upon. wait for a responder to be assigned here, thank you.");
                              // }
                            },
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 2.w,
                                    top: 2.w,
                                    right: 2.w,
                                    bottom: 1.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          reportList[index].type,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.sp),
                                        ),
                                        Text(
                                          "${DateFormat.yMMMMd().format(reportList[index].dateTime)} ${DateFormat.jm().format(reportList[index].dateTime)}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      reportList[index].status,
                                      style: TextStyle(
                                          color: reportList[index].status ==
                                                  "Pending"
                                              ? Colors.orange
                                              : reportList[index].status ==
                                                      "Accepted"
                                                  ? Colors.blue
                                                  : reportList[index].status ==
                                                          "Done"
                                                      ? Colors.green
                                                      : Colors.red,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.sp),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Text(
                                      reportList[index].caption,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
