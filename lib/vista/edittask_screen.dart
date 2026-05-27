import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import '../network/Utils.dart';
import 'dart:io';

import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../utils/app_theme.dart';

class EditTaskScreen extends StatefulWidget{
  Map<String, dynamic> taskData;
  EditTaskScreen(this.taskData, {super.key});
  _editTaskState createState()=> _editTaskState();
}
class _editTaskState extends State<EditTaskScreen>{
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var empRoleId="";
  var empShiftId="";
  var pageTitle="Edit Task";


  String id="";
  String taskId="";
  String taskRoleId="";
  String taskName="";
  String startTime="";
  String endTime="";
  String taskStatus="";
  String task_repetation="";
  String remark="";
  String repeatChangeStr="";
  String buildingName="";
  String taskPriority = "";
  Color priorityColor = AppTheme.orangeColor;

  String selectedStartDate="";
  String selectedStartTime="";
  String selectedEndDate="";
  String selectedEndTime="";

  String convertedStartTime="";
  String convertedEndTime="";

  String newSelectedStartDate="";
  String newSelectedStartTime="";
  String newSelectedEndDate="";
  String newSelectedEndTime="";

  var remarkController=TextEditingController();




  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
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
            padding: const EdgeInsets.all(15),
            child: ListView(
              children: [
                Container(
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
                      Text(taskName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.themeColor)),
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
                      Text("$convertedStartTime-$convertedEndTime", style: const TextStyle(fontSize: 14, color: AppTheme.orangeColor)),

                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Select Start Date & Time*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                InkWell(
                  onTap: (){
                    _selectDateTime(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE4E4E4), // Border color
                          width: 2.0,         // Border width
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white

                    ),


                    child: Row(
                      children: [
                        Expanded(flex:1,child: Text(
                          "$newSelectedStartDate $newSelectedStartTime",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black,fontSize: 13),

                        )),
                        SizedBox(),
                        const Icon(Icons.calendar_month_outlined,size: 24,color: Color(0xFFE4E4E4),)

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Select End Date & Time*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                InkWell(
                  onTap: (){
                    if(newSelectedStartDate.isNotEmpty){
                      _selectEndDateTime(context);
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select start date and time first")));
                    }

                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE4E4E4), // Border color
                          width: 2.0,         // Border width
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white

                    ),


                    child: Row(
                      children: [
                        Expanded(flex:1,child: Text(
                          "$newSelectedEndDate $newSelectedEndTime",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black,fontSize: 13),

                        )),
                        SizedBox(),
                        const Icon(Icons.calendar_month_outlined,size: 24,color: Color(0xFFE4E4E4),)

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),


                const Text("Update Remark",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        //color: Colors.black
                        color: Color(0xFF9D9CA0)
                    )),
                const SizedBox(height: 7),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color(0xFFE4E4E4),
                        width: 1.0
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex:1,child:
                      TextFormField(
                        controller: remarkController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: InputBorder.none,           // Removes all borders (including the bottom line)
                          enabledBorder: InputBorder.none,    // Removes border when enabled
                          focusedBorder: InputBorder.none,    // Removes border when focused
                          hintText: 'Enter Update Remark',
                        ),
                        maxLines: null,
                        minLines: 3,
                      ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 16,),

                InkWell(
                  onTap: (){
                    onCreateTaskButtonClick(context);
                  },
                  child: Container(
                    height: 58,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    // padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [AppTheme.baseOrangeStart, AppTheme.baseOrange],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Update Task",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
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

    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    sUserId=await MyUtils.getSharedPreferences("user_id")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    empRoleId=await MyUtils.getSharedPreferences("emp_role_id")??"";
    empShiftId=await MyUtils.getSharedPreferences("emp_shift_id")??"";

    print("Employee Role Id $empRoleId");
    print("Employee empShiftId Id $empShiftId");
    print("UserId $sUserId");
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }

    id = widget.taskData['id'].toString();
    taskId = widget.taskData['task_id'].toString();
    taskRoleId= widget.taskData['task_role_id'].toString();
    taskName = widget.taskData['task_name'].toString();
    startTime = widget.taskData['start_date_time'].toString();
    endTime = widget.taskData['end_date_time'].toString();
    taskStatus = widget.taskData['task_status'].toString();


    final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final outputFormat = DateFormat("dd MMM,yyyy hh:mm a");

    final dateoutFormat=DateFormat("yyyy-MM-dd");
    final timeOutFormat=DateFormat("HH:mm:ss");

    DateTime startDate = inputFormat.parse(startTime);
    DateTime endDate = inputFormat.parse(endTime);
    convertedStartTime = outputFormat.format(startDate);
    convertedEndTime = outputFormat.format(endDate);

    selectedStartDate=dateoutFormat.format(startDate);
    selectedStartTime=timeOutFormat.format(startDate);

    selectedEndDate=dateoutFormat.format(endDate);
    selectedEndTime=timeOutFormat.format(endDate);

    if(widget.taskData['task_detail']!=null){
      task_repetation = widget.taskData['task_detail']['task_repetation'].toString();
      remark = widget.taskData['task_detail']['remark']?.toString() ?? "";
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
      buildingName = "";
      if (widget.taskData['task_detail']['building_name'] != null) {
        buildingName = widget.taskData['task_detail']['building_name'];
      }
      if (widget.taskData['task_detail']['unit_number'] != null) {
        buildingName += " (${widget.taskData['task_detail']['unit_number']})";
      }
      if (widget.taskData['task_detail']['priority'] != null) {
        switch (widget.taskData['task_detail']['priority'].toString()) {
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
    }else{
      task_repetation = widget.taskData['task_artifacts']['task_repetation'].toString();
      remark = widget.taskData['task_artifacts']['remark']?.toString() ?? "";
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
      buildingName = "";
      if (widget.taskData['task_artifacts']['building_name'] != null) {
        buildingName = widget.taskData['task_artifacts']['building_name'];
      }
      if (widget.taskData['task_artifacts']['unit_number'] != null) {
        buildingName += " (${widget.taskData['task_artifacts']['unit_number']})";
      }
      if (widget.taskData['task_artifacts']['priority'] != null) {
        switch (widget.taskData['task_artifacts']['priority'].toString()) {
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
    }





    setState(() {
    });
  }
  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        print("Selected DateTime: $fullDateTime");


        String year = pickedDate.year.toString();
        String month = pickedDate.month.toString().padLeft(2, '0'); // Add leading zero if needed
        String day = pickedDate.day.toString().padLeft(2, '0');
        String hour = pickedTime.hour.toString().padLeft(2, '0');
        String minute = pickedTime.minute.toString().padLeft(2, '0');


        newSelectedStartDate="$year-$month-$day";
        newSelectedStartTime="$hour:$minute:00";

        selectedStartDate=newSelectedStartDate;
        selectedStartTime=newSelectedStartTime;

        setState(() {

        });
        // Do something with fullDateTime (like update a controller)
      }
    }
  }
  Future<void> _selectEndDateTime(BuildContext context) async {

    final DateTime startDateTime = DateTime.parse("$newSelectedStartDate $newSelectedStartTime");

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDateTime,
      firstDate: startDateTime,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startDateTime),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        print("Selected DateTime: $fullDateTime");


        String year = pickedDate.year.toString();
        String month = pickedDate.month.toString().padLeft(2, '0'); // Add leading zero if needed
        String day = pickedDate.day.toString().padLeft(2, '0');
        String hour = pickedTime.hour.toString().padLeft(2, '0');
        String minute = pickedTime.minute.toString().padLeft(2, '0');

        if(fullDateTime.isBefore(startDateTime)){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("End time can't be earlier than start time($selectedStartDate $selectedStartTime)")));
          return;
        }

        newSelectedEndDate="$year-$month-$day";
        newSelectedEndTime="$hour:$minute:00";

        selectedEndDate=newSelectedEndDate;
        selectedEndTime=newSelectedEndTime;

        setState(() {

        });
        // Do something with fullDateTime (like update a controller)
      }
    }
  }
  void onCreateTaskButtonClick(BuildContext context){
    if(checkAssignValidation()){
      _updateTaskOnServer(context);
    }
  }
  bool checkAssignValidation(){
    String upRemark=remarkController.text.toString().trim();
    if (newSelectedStartDate.isNotEmpty) {
      if (newSelectedStartTime.isNotEmpty) {
            if(newSelectedEndDate.isNotEmpty) {
              if(newSelectedEndTime.isNotEmpty) {
                if(upRemark.isNotEmpty) {
                  return true;
                }else{
                  Toast.show("Please enter update remark",
                      duration: Toast.lengthLong,
                      gravity: Toast.bottom,
                      backgroundColor: Colors.red);
                  return false;
                }
              }else{
                Toast.show("Please Select Task End Time",
                    duration: Toast.lengthLong,
                    gravity: Toast.bottom,
                    backgroundColor: Colors.red);
                return false;
              }
            }else{
              Toast.show("Please Select Task End Date",
                  duration: Toast.lengthLong,
                  gravity: Toast.bottom,
                  backgroundColor: Colors.red);
              return false;
            }
          }
      else {
            Toast.show("Please Select Task Start Time",
                duration: Toast.lengthLong,
                gravity: Toast.bottom,
                backgroundColor: Colors.red);
            return false;
          }
        } else {
          Toast.show("Please Select Task Start Date",
              duration: Toast.lengthLong,
              gravity: Toast.bottom,
              backgroundColor: Colors.red);
          return false;
        }




  }
  _updateTaskOnServer(BuildContext context)async{
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var jsonArray=[];
    jsonArray.add(sUserId);
    var param={
      "auth_key":sRemeberToken,
      "id":id,
      "task_id":taskId,
      "start_time":newSelectedStartTime,
      "start_date":newSelectedStartDate,
      "end_date":newSelectedEndDate,
      "end_time":newSelectedEndTime,
      "update_remark":remarkController.text.toString(),
    };
    print(param);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'edit-assigned-task', param, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1 ||responseJSON["status"]==200)
    {
      Toast.show(responseJSON["message"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);
      _finishScreen();
    }
    else {
      Toast.show(responseJSON["error"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }

  }
  _finishScreen() {
    Navigator.of(context).pop();
  }


}