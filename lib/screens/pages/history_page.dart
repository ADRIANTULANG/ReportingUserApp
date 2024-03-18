import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responder/screens/pages/report_details_page.dart';
import 'package:responder/widgets/loading_dialog.dart';
import 'package:responder/widgets/text_widget.dart';
import 'package:sizer/sizer.dart';

import '../../model/report_history_model.dart';

class HistoryReportTab extends StatefulWidget {
  const HistoryReportTab({super.key});

  @override
  State<HistoryReportTab> createState() => _HistoryReportTabState();
}

class _HistoryReportTabState extends State<HistoryReportTab> {
  List<ReportHistory> historyReport = <ReportHistory>[];
  getHistory() async {
    LoadingDialog.showLoadingDialog(context: context);
    try {
      var res = await FirebaseFirestore.instance
          .collection('Reports')
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('status', isEqualTo: "Done")
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
      setState(() {
        historyReport = reportHistoryFromJson(jsonEncode(data));
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      getHistory();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextWidget(
          text: 'MY HISTORY',
          fontSize: 18,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
        child: historyReport.isEmpty
            ? const Center(
                child: Text("No available data."),
              )
            : ListView.builder(
                itemCount: historyReport.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: SizedBox(
                        width: 100.w,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ReportDetails(
                                      reportDetails: historyReport[index],
                                    )));
                          },
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 2.w, top: 2.w, right: 2.w, bottom: 1.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        historyReport[index].type,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp),
                                      ),
                                      Text(
                                        "${DateFormat.yMMMMd().format(historyReport[index].dateTime)} ${DateFormat.jm().format(historyReport[index].dateTime)}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    historyReport[index].status,
                                    style: TextStyle(
                                        color: historyReport[index].status ==
                                                "Pending"
                                            ? Colors.orange
                                            : historyReport[index].status ==
                                                    "Accepted"
                                                ? Colors.blue
                                                : historyReport[index].status ==
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
                                    historyReport[index].caption,
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
    );
  }
}
