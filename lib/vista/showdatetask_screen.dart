import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/vista/edittask_screen.dart';
import 'package:vista/vista/showcompleted_task_screen.dart';
import 'package:vista/vista/submitform_screen.dart';
import 'package:vista/vista/submitform_vi_screen.dart';
import 'package:vista/vista/vi_show_completed_task_details.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';

class ShowDateTaskScreen extends StatefulWidget{
String selectedDate;
String currentDate;
String taskType;

ShowDateTaskScreen(this.selectedDate, this.currentDate, this.taskType, {super.key});

  _showDateState createState()=> _showDateState();

}
class _showDateState extends State<ShowDateTaskScreen>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var pageTitle="";
  var editTaskPermission="0";
  List<dynamic> taskList=[];
  String noTaskTitle="No Task Available On";
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
                      return taskList[index]["task_artifacts"]!=null?_buildTodayTaskCard(taskList[index], context):Container();
                    }
                )),



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
  Widget _buildTodayTaskCard(Map<String, dynamic> task, BuildContext context) {
    String id = task['id'].toString();
    String task_id = task['task_id'].toString();
    String task_role_id = task['task_role_id'].toString();
    String task_name = task['task_name'].toString();
    String startTime = task['start_date_time'].toString();
    String endTime = task['end_date_time'].toString();
    String task_status = task['task_status'].toString();

    String createdAt = task['task_artifacts']['created_at'].toString();
    String updated_at = task['task_artifacts']['updated_at'].toString();
    String task_repetation = task['task_artifacts']['task_repetation'].toString();

    String remark = task['task_artifacts']['remark']?.toString() ?? "";

    final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final outputFormat = DateFormat("dd MMM,yyyy hh:mm a");

    DateTime startDate = inputFormat.parse(startTime);
    DateTime endDate = inputFormat.parse(endTime);
    String strTime = outputFormat.format(startDate);
    String edtime = outputFormat.format(endDate);

    String timeStr = "$strTime - $edtime";

    String startTme="Start: $strTime";
    String endTme="End: $edtime";

    // Repetition
    String repeatChangeStr = "";
    if (task_repetation.isNotEmpty && task_repetation!="null") {
      var repeat = task_repetation.split(",");
      switch (repeat[0]) {
        case "1" || "daily":
          repeatChangeStr = "Daily";
          break;
        case "2" || "alternately":
          repeatChangeStr = "Alternately";
          break;
        case "3" || "weekly":
          repeatChangeStr = "Weekly";
          break;

      }
    }else{
      repeatChangeStr="Once";
    }

    String buildingName = "";
    if (task['task_artifacts']['building_name'] != null) {
      buildingName = task['task_artifacts']['building_name'];
    }
    if (task['task_artifacts']['unit_number'] != null) {
      buildingName += " (${task['task_artifacts']['unit_number']})";
    }

    String taskPriority = "";
    Color priorityColor = AppTheme.orangeColor;

    if (task['task_artifacts']['priority'] != null) {
      switch (task['task_artifacts']['priority'].toString()) {
        case "critical":
          taskPriority = "Priority: Critical";
          priorityColor = AppTheme.priorityCritical;
          break;
        case "medium":
          taskPriority = "Priority: Medium";
          priorityColor = AppTheme.priorityMedium;
          break;
        case "high":
          taskPriority = "Priority: High";
          priorityColor = AppTheme.priorityHigh;
          break;
        case "low":
          taskPriority = "Priority: Low";
          priorityColor = AppTheme.priorityLow;
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        if (task_status != "1") {
          if (checkTimeValidation(startTime, endTime)) {
            editTaskPermission=="1"?
            Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitFormScreen(task_id, id))).then((value) => {
              _getUserData()
            }):Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitFormVIScreen(task_id, id))).then((value) => {
              _getUserData()
            });
          } else {
            APIDialog.showErrorDialog("You can complete this Checklist between $strTime to $edtime", context);
            /*Toast.show("You can complete this task between $strTime to $edtime",
                duration: Toast.lengthLong, gravity: Toast.bottom, backgroundColor: Colors.red);*/
          }
        } else {
          if(editTaskPermission=="1"){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShowCompletedTaskDetails(task_id, id, task_role_id))).then((value) => {
              _getUserData()
            });
          }else{
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViShowCompletedTaskDetails(task_id, id, task_role_id))).then((value) => {
              _getUserData()
            });
          }

        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.lightblueColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: Offset(1, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task_name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.themeColor)),
            const SizedBox(height: 8),
            if (buildingName.isNotEmpty)
              Text(buildingName, style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (taskPriority.isNotEmpty)
                  Text(taskPriority, style: TextStyle(fontSize: 14, color: priorityColor)),
                Text("Repetition: $repeatChangeStr", style: const TextStyle(fontSize: 14, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 6),
            Text("Remark: $remark", style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 6),
            Text(timeStr, style: const TextStyle(fontSize: 14, color: AppTheme.orangeColor)),

            Row(
              children: [
                const Spacer(),
                editTaskPermission=="1"?
                task_status == "0"?
                checkEditIconFunctionality(startTime, endTime)?
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskScreen(task))).then((value) => {
                      _getUserData()
                    });
                  },
                  child: const Icon(Icons.edit_note,color: AppTheme.themeColor,size: 28,),
                ):Container():Container():Container(),
                const SizedBox(width: 5,),
                Icon(
                  task_status == "1" ? Icons.task_alt : Icons.incomplete_circle_outlined,
                  color: task_status == "1" ? Colors.green : Colors.orange,
                  size: 28,
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
  bool checkEditIconFunctionality(String startTime,String endTime){
    try{
      final DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime startDate = format.parse(startTime);
      DateTime endDate = format.parse(endTime);
      DateTime currentDate = DateTime.now();
      print("Current Date: $currentDate");
      print("Start Date: $startDate");
      print("End Date: $endDate");
      if(currentDate.isAfter(endDate)){
        return true;
      }else{
        return false;
      }


    }catch(e){
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
    editTaskPermission=await MyUtils.getSharedPreferences("edit_task")??"0";
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }
    String selectedDateForShow=DateFormat('dd MMM, yyyy').format(DateTime.parse(widget.selectedDate));
    pageTitle="Checklist  Of ${widget.selectedDate}";
    noTaskTitle="There is no checklist for $selectedDateForShow";
    setState(() {
    });
    _getHomePageData(context);
  }
  _getHomePageData(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "date": widget.selectedDate,
      "task_type": widget.taskType,

    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get_task', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      taskList.clear();
      taskList=responseJSON['taskData'];
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

}