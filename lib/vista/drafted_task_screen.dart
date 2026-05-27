import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/vista/submitform_screen.dart';
import 'package:vista/vista/submitform_vi_screen.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';


class DraftedTaskScreen extends StatefulWidget{
  draftedState createState()=>draftedState();
}
class draftedState extends State<DraftedTaskScreen>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var pageTitle="Drafted Checklist";
  List<dynamic> taskList=[];
  String noTaskTitle="There is no drafted checklist";
  var createTaskPermission="0";
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
                taskList.isEmpty?
                Align(
                    alignment: Alignment.center,
                    child: Text(noTaskTitle,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppTheme.orangeColor,))
                ):
                Expanded(flex:1,child: ListView.builder(
                    itemCount: taskList.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context,int index){
                      String id=taskList[index]['id'].toString();
                      String task_id=taskList[index]['task_id'].toString();
                      String task_name=taskList[index]['task_name'].toString();
                      String startTime=taskList[index]['start_date_time'].toString();
                      String endTime=taskList[index]['end_date_time'].toString();
                      String task_status=taskList[index]['task_status'].toString();

                      String task_repetation=taskList[index]['task_detail']['task_repetation'].toString();
                      String remark="";
                      if(taskList[index]['task_detail']['remark']!=null){
                        remark=taskList[index]['task_detail']['remark'].toString();
                      }

                      final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                      final outputFormat = DateFormat("hh:mm a");
                      final outputDateFormat=DateFormat("dd MMM,yyyy");
                      DateTime startDate = inputFormat.parse(startTime);
                      DateTime endDate=inputFormat.parse(endTime);
                      String strTime=outputFormat.format(startDate);
                      String edtime=outputFormat.format(endDate);
                      String taskDate=outputDateFormat.format(startDate);

                      String timeStr="Time : $taskDate ( $strTime - $edtime )";
                      String repeatChangeStr="";
                      if(taskList[index]['task_detail']['task_repetation']!=null){
                        var repeat=task_repetation.split(",");
                        String rep=repeat[0];
                        if(rep=="1" || rep=="daily" ){
                          repeatChangeStr="Daily";
                        }else if(rep=="2" || rep=="alternately" ){
                          repeatChangeStr="Alternately";
                        }if(rep=="3" || rep=="weekly"){
                          repeatChangeStr="Weekly";
                        }
                      }
                      String totalTime="$strTime - $edtime";

                      String buildingName="";
                      if(taskList[index]['task_detail']['building_name']!=null){
                        buildingName="${taskList[index]['task_detail']['building_name']}";
                      }
                      if(taskList[index]['task_detail']['unit_number']!=null){
                        buildingName="$buildingName (${taskList[index]['task_detail']['unit_number']})";
                      }

                      String taskPriority="";
                      var priorityColor=AppTheme.orangeColor;
                      if(taskList[index]['task_detail']['priority']!=null){
                        String pr=taskList[index]['task_detail']['priority'].toString();
                        if(pr=="critical"){
                          taskPriority="Priority: Critical";
                          priorityColor=AppTheme.priorityCritical;
                        }else if(pr=="medium"){
                          taskPriority="Priority: Medium";
                          priorityColor=AppTheme.priorityMedium;
                        }else if(pr=="high"){
                          taskPriority="Priority: High";
                          priorityColor=AppTheme.priorityHigh;
                        }else if(pr=="low"){
                          taskPriority="Priority: Low";
                          priorityColor=AppTheme.priorityLow;
                        }
                      }else{
                        taskPriority="Priority: Medium";
                        priorityColor=AppTheme.priorityMedium;
                      }


                      return InkWell(
                          onTap: (){
                        if(task_status!="1"){
                          if(createTaskPermission=="1"){
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitFormScreen(task_id, id))).then((value) => {
                              _getUserData()
                            });
                          }else if (checkTimeValidation(startTime, endTime)) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitFormVIScreen(task_id, id))).then((value) => {
                              _getUserData()
                            });
                          }else{
                            APIDialog.showErrorDialog("This task can be completed within the timeframe of $strTime to $edtime on $taskDate.", context);
                          }

                        }
                      },
                      child:Card(
                        color: AppTheme.lightblueColor,
                        elevation: 4,
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(task_name,style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.themeColor
                                      ),),
                                      SizedBox(height: 10,),

                                      buildingName.isNotEmpty?
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(buildingName,style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black
                                          ),),
                                          const SizedBox(height: 10,),
                                        ],
                                      ):Container(),
                                      Row(children: [
                                        Expanded(flex:1,child:
                                        taskPriority.isNotEmpty?
                                        Text(taskPriority,style:  TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: priorityColor
                                        )):Container()),
                                        SizedBox(width: 5,),
                                        Expanded(flex:1,child:
                                        Text("Repetition: $repeatChangeStr",style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black
                                        ),),),
                                      ],),

                                      SizedBox(height: 10,),
                                      Text("Remark: $remark",style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black
                                      ),),
                                      SizedBox(height: 10,),
                                      Text(timeStr,style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.orangeColor
                                      ),),
                                    ],
                                  )
                              ),
                              const SizedBox(width: 5,),

                              task_status=="1"?
                              const Icon(Icons.task_alt,size: 32,color: Colors.green,):
                              const Icon(Icons.incomplete_circle_outlined,size: 32,color: Colors.orange,)

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
  bool checkTimeValidation(String startTime, String endTime) {
    try {
      final DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");

      DateTime startDate = format.parse(startTime);
      DateTime endDate = format.parse(endTime);
      DateTime currentDate = DateTime.now();

      print("Current Date: $currentDate");
      print("Start Date: $startDate");
      print("End Date: $endDate");
      if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
        //if (currentDate.isAfter(startDate)) {
        print("Date Matched: Matched");
        return true;
      } else {
        print("Date Matched: Not Matched");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
  _getUserData() async {
    sMobileNumber=await MyUtils.getSharedPreferences("mobile_no")??"";
    sPersonName=await MyUtils.getSharedPreferences("name")??"";
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    sUserId=await MyUtils.getSharedPreferences("user_id")??"";
    sUserLanguage=await MyUtils.getSharedPreferences("language")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    createTaskPermission=await MyUtils.getSharedPreferences("create_task")??"0";
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
    var response = await helper.postAPI(baseUrl,'saved_draft_listing', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      taskList.clear();
      taskList=responseJSON['draftTask'];
      setState(() {

      });
    }else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      MyUtils.logoutUser(context);
    } else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      taskList.clear();
      setState(() {

      });
    }


  }

}