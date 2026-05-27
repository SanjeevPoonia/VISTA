import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';


class RatingFeedbackScreen extends StatefulWidget{
_ratingFeedbackState createState()=>_ratingFeedbackState();
}
class _ratingFeedbackState extends State<RatingFeedbackScreen>{
  var pageTitle="Rating & Feedback";
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  List<dynamic> feedbackList=[];
  String noTaskTitle="No Rating & Feedback Available";

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
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(

              children: [
                const SizedBox(height: 10,),
                feedbackList.isEmpty?
                Align(
                    alignment: Alignment.center,
                    child: Text(noTaskTitle,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppTheme.orangeColor,))
                ):
                Expanded(flex:1,child: ListView.builder(
                    itemCount: feedbackList.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context,int index){
                      String id=feedbackList[index]['id'].toString();
                      String admin_id=feedbackList[index]['admin_id'].toString();
                      String rating_period=feedbackList[index]['rating_period'].toString();
                      String employee_id=feedbackList[index]['employee_id'].toString();
                      String period=feedbackList[index]['period'].toString();
                      String year=feedbackList[index]['year'].toString();
                      String rating=feedbackList[index]['rating'].toString();
                      String feedback=feedbackList[index]['feedback'].toString();
                      String created_at=feedbackList[index]['created_at'].toString();
                      String formatedDate=formatDate(created_at);

                      return InkWell(
                          onTap: (){

                          },
                          child: Card(
                            color: AppTheme.lightblueColor,
                            elevation: 4,
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Row(
                                    children: [
                                      Text("$period - $year",style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.themeColor
                                      ),),
                                      Spacer(),
                                      Text(rating,style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.orangeColor
                                      ),),
                                      const SizedBox(width: 5,),
                                      const Icon(Icons.star,color: AppTheme.orangeColor,size: 28,)
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Text("Feedback: $feedback",style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black),),
                                  SizedBox(height: 10,),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(formatedDate,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppTheme.orangeColor,))
                                  ),
                                  SizedBox(height: 10,),

                                ],
                              ),
                            ),
                          ));







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
    setState(() {
    });
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
    var response = await helper.postAPI(baseUrl,'get-rating', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      feedbackList.clear();
      feedbackList=responseJSON['data'];
      setState(() {

      });
    } else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      feedbackList.clear();
      setState(() {

      });
      _finishScreen();
    }


  }
  _finishScreen(){
    Navigator.of(context).pop();
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


}