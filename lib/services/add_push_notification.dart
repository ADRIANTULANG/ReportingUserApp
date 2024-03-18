import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

Future sendNotif({
  required String message,
}) async {
  var res = await FirebaseFirestore.instance
      .collection('Users')
      .where('type', isEqualTo: "Responder")
      .get();
  for (var i = 0; i < res.docs.length; i++) {
    if (res.docs[i]['fcmToken'].isNotEmpty || res.docs[i]['fcmToken'] != "") {
      var body = jsonEncode({
        "to": res.docs[i]['fcmToken'],
        "notification": {
          "body": message,
          "title": "Report Notification",
          "subtitle": "",
        }
      });
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            "Authorization":
                "key=AAAAomtn0Yk:APA91bH2B8WQvFaTv0K7pcqcdTM8PX_V28b5JgfMRasrWaM4Cw8j6JgXmc1xEk1457mnKN3nJ_RBJBiV_T46_pvTD4c7EiEQNDGl4KiPUlbtyU_TbzpiHh0s0YH6GXBD-z4Yz7S7HDTb",
            "Content-Type": "application/json"
          },
          body: body);
    }
  }
}
