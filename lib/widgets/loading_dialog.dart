import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LoadingDialog {
  static showLoadingDialog({required BuildContext context}) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                    height: 8.h,
                    width: 60.w,
                    color: Colors.white,
                    child: Column(
                      children: [
                        const Center(child: CircularProgressIndicator()),
                        SizedBox(
                          height: 1.h,
                        ),
                        InkWell(
                            onTap: () {},
                            child: Text(
                              "Loading...",
                              style: TextStyle(
                                fontSize: 11.sp,
                              ),
                            ))
                      ],
                    )),
              ),
            ),
          );
        },
        barrierDismissible: false);
  }
}
