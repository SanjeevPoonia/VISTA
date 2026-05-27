import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../utils/app_theme.dart';

class NotificationScreen extends StatefulWidget{
  _notificationState createState()=>_notificationState();
}
class _notificationState extends State<NotificationScreen>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var pageTitle="Notification";
  String noTaskTitle="There is no notification currently";
  List<dynamic> notificationList=[];

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return SafeArea(
        child:
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar  (
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined, color: AppTheme.themeColor,size: 24,),
              onPressed: () => {
                Navigator.pop(context)
              },
            ),
            backgroundColor: AppTheme.at_details_header,
            title:  Text(
              pageTitle,
              style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            /* actions: [
             IconButton(onPressed: (){
               _showAlertDialog();
             }, icon: const Icon(Icons.logout, color: AppTheme.task_Reopen_text,size: 35,))] ,*/
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                const SizedBox(height: 10,),
                notificationList.isEmpty?
                Align(
                    alignment: Alignment.center,
                    child: Text(noTaskTitle,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppTheme.orangeColor,))
                ):
                Expanded(flex:1,child: ListView.builder(
                    itemCount: notificationList.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context,int index){
                      String id=notificationList[index]['id'].toString();
                      String task_id=notificationList[index]['task_id'].toString();
                      String employee_id=notificationList[index]['employee_id'].toString();
                      String type=notificationList[index]['type'].toString();
                      String title=notificationList[index]['title'].toString();
                      String body=notificationList[index]['body'].toString();
                      String read_at=notificationList[index]['read_at'].toString();
                      String created_at=notificationList[index]['created_at'].toString();
                      String updated_at=notificationList[index]['updated_at'].toString();
                      String formattedDate= formatDate(created_at);

                      return InkWell(
                        onTap: (){
                          if(read_at=="null"){
                            _updateNotificationReadStatus(context, id, index);
                          }

                        },
                        child: Card(
                          color: read_at=="null"?AppTheme.notificationUnread:AppTheme.notificationRead,
                          elevation: 4,
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.themeColor
                                ),),
                                SizedBox(height: 10,),
                                Text(body,style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black
                                ),),
                                SizedBox(height: 10,),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(formattedDate,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppTheme.orangeColor,))
                                ),
                                SizedBox(height: 10,),

                              ],
                            ),
                          ),
                        ),
                      );







                    })),


              ],
            ),
          ),

        )
    );
  }
  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  String formatDate(String createdAt) {
    final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.S'Z'");
    final outputFormat = DateFormat("dd MMM,yyyy hh:mm a");

    try {
      final DateTime dateStart = inputFormat.parseUtc(createdAt).toLocal(); // parse UTC & convert to local
      final String formatted = outputFormat.format(dateStart);
      return formatted;
    } catch (e) {
      print("Date parsing error: $e");
      return createdAt; // fallback
    }
  }
  _getUserData() async {
    sMobileNumber=await MyUtils.getSharedPreferences("mobile_no")??"";
    sPersonName=await MyUtils.getSharedPreferences("name")??"";
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    sUserId=await MyUtils.getSharedPreferences("user_id")??"";
    sUserLanguage=await MyUtils.getSharedPreferences("language")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }






    _getHomePageData(context);
  }

  _getHomePageData(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'notifications', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==200)
    {
      notificationList.clear();
      notificationList=responseJSON['data'];
      setState(() {

      });
    } else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      notificationList.clear();
      setState(() {

      });
    }


  }
  _updateNotificationReadStatus(BuildContext context,String notificationId,int index) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "notification_id": notificationId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'notification_mark_as_read', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==200)
    {
      notificationList[index]['read_at']="updated";
      setState(() {

      });
    } else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      setState(() {

      });
    }


  }

}