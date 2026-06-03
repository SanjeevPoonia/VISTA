
import 'package:flutter/material.dart';
import 'package:vista/utils/app_theme.dart';


class APIDialog
{
  static Future<void> showAlertDialog(BuildContext context,String dialogText) async {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.themeColor),
          ),
          Container(margin: EdgeInsets.only(left: 9), child: Text(dialogText,maxLines:2,style: TextStyle(color:Colors.blueGrey,fontFamily: 'OpenSans'),)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  static void showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 26),
            SizedBox(width: 8),
            Text(
              "Error",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message.isNotEmpty ? message : "Something went wrong. Please try again!",
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.themeColor,
              ),
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Center(
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showResponseDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.message, color: AppTheme.themeColor, size: 26),
            SizedBox(width: 8),
            Text(
              "Message",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.themeColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message.isNotEmpty ? message : "Something went wrong. Please try again!",
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.themeColor,
              ),
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Center(
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}






