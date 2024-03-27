// To parse this JSON data, do
//
//     final reportHistory = reportHistoryFromJson(jsonString);

import 'dart:convert';

List<ReportHistory> reportHistoryFromJson(String str) =>
    List<ReportHistory>.from(
        json.decode(str).map((x) => ReportHistory.fromJson(x)));

String reportHistoryToJson(List<ReportHistory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReportHistory {
  DateTime dateTime;
  String address;
  String contactnumber;
  int year;
  String responder;
  String caption;
  String type;
  String userId;
  double long;
  int month;
  String imageUrl;
  String name;
  int day;
  double lat;
  String status;
  String remarks;
  String documentId;
  String? level;
  String? responderRemarks;

  ReportHistory(
      {required this.dateTime,
      required this.address,
      required this.contactnumber,
      required this.year,
      required this.responder,
      required this.caption,
      required this.type,
      required this.remarks,
      required this.userId,
      required this.long,
      required this.month,
      required this.imageUrl,
      required this.name,
      required this.day,
      required this.lat,
      required this.status,
      required this.documentId,
      this.responderRemarks,
      this.level});

  factory ReportHistory.fromJson(Map<String, dynamic> json) => ReportHistory(
        dateTime: DateTime.parse(json["dateTime"]),
        address: json["address"],
        contactnumber: json["contactnumber"],
        year: json["year"],
        remarks: json["remarks"],
        responder: json["responder"],
        caption: json["caption"],
        type: json["type"],
        userId: json["userId"],
        long: json["long"]?.toDouble(),
        month: json["month"],
        imageUrl: json["imageURL"],
        name: json["name"],
        day: json["day"],
        lat: json["lat"]?.toDouble(),
        status: json["status"],
        documentId: json["documentID"],
        responderRemarks: json["responderRemarks"],
        level: json["level"],
      );

  Map<String, dynamic> toJson() => {
        "dateTime": dateTime.toIso8601String(),
        "address": address,
        "contactnumber": contactnumber,
        "remarks": remarks,
        "year": year,
        "responder": responder,
        "caption": caption,
        "type": type,
        "userId": userId,
        "long": long,
        "month": month,
        "imageURL": imageUrl,
        "name": name,
        "day": day,
        "lat": lat,
        "status": status,
        "documentID": documentId,
        "level": level,
        "responderRemarks": responderRemarks,
      };
}
