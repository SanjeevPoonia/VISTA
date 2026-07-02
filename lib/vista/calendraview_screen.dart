import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/vista/edittask_screen.dart';
import 'package:vista/vista/showcompleted_task_screen.dart';
import 'package:vista/vista/showdatetask_screen.dart';
import 'package:vista/vista/submitform_screen.dart';
import 'package:vista/vista/submitform_vi_screen.dart';
import 'package:vista/vista/vi_show_completed_task_details.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../utils/datetime_listitem_series.dart';
import 'package:intl/intl.dart';
class CalendraViewScreen extends StatefulWidget{

  String taskType;
  CalendraViewScreen(this.taskType, {super.key});
  calendraViewState createState()=> calendraViewState();
}
class calendraViewState extends State<CalendraViewScreen> with WidgetsBindingObserver{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var pageTitle="";
  var editTaskPermission="0";
  String selectedDate="";
  String currentDate="";
  String selectedDateForShow="";
  List<DateTimeListSeries> dateList=[];
  List<dynamic> taskList=[];
  String noTaskTitle="There is no checklist for ";

  final ScrollController _scrollController = ScrollController();


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
               SizedBox(
                 height: 100,
                 child: ListView.builder(
                     controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: dateList.length,
                      itemBuilder: (context,index){
                        var item=dateList[index];

                        return InkWell(
                          onTap: (){
                            setOnDateClick(index);
                          },
                          child: Container(
                            width: 75,
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.isSelected == 1 ? AppTheme.orangeColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.DateStr,style:  TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: item.isSelected == 1 ? Colors.white : Colors.black),),
                                const SizedBox( height: 4,),
                                Text(item.DayStr,style:  TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: item.isSelected == 1 ? Colors.white : Colors.black),),
                              ],
                            ),



                          ),
                        );
                      }),
               ),
               const SizedBox(height: 10,),
               taskList.isEmpty?
               Align(
                   alignment: Alignment.center,
                   child: Text("$noTaskTitle $selectedDateForShow",style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppTheme.orangeColor,))
               ):

               Expanded(flex:1,child: ListView.builder(
                   itemCount: taskList.length,
                   scrollDirection: Axis.vertical,
                   itemBuilder: (BuildContext context,int index){
                     return taskList[index]["task_artifacts"]!=null?_buildTodayTaskCard(taskList[index], context):Container();
                   }
               )),
               /*Expanded(flex:1,child: ListView.builder(
                       itemCount: taskList.length,
                       scrollDirection: Axis.vertical,
                       itemBuilder: (BuildContext context,int index){
                         String id=taskList[index]['id'].toString();
                         String task_id=taskList[index]['task_id'].toString();
                         String task_role_id=taskList[index]['task_role_id'].toString();
                         String task_name=taskList[index]['task_name'].toString();
                         String startTime=taskList[index]['start_date_time'].toString();
                         String endTime=taskList[index]['end_date_time'].toString();
                         String task_status=taskList[index]['task_status'].toString();

                         String task_repetation=taskList[index]['task_artifacts']['task_repetation'].toString();
                         String remark="";
                         if(taskList[index]['task_artifacts']['remark']!=null){
                           remark=taskList[index]['task_artifacts']['remark'].toString();
                         }

                         final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                         final outputFormat = DateFormat("hh:mm a");
                         DateTime startDate = inputFormat.parse(startTime);
                         DateTime endDate=inputFormat.parse(endTime);
                         String strTime=outputFormat.format(startDate);
                         String edtime=outputFormat.format(endDate);

                         String timeStr="Time : $strTime - $edtime";
                         String repeatChangeStr="";
                         if(taskList[index]['task_artifacts']['task_repetation']!=null){
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
                         if(taskList[index]['task_artifacts']['building_name']!=null){
                           buildingName="${taskList[index]['task_artifacts']['building_name']}";
                         }
                         if(taskList[index]['task_artifacts']['unit_number']!=null){
                           buildingName="$buildingName (${taskList[index]['task_artifacts']['unit_number']})";
                         }

                         String taskPriority="";
                         var priorityColor=AppTheme.orangeColor;
                         if(taskList[index]['task_artifacts']['priority']!=null){
                           String pr=taskList[index]['task_artifacts']['priority'].toString();
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
                               if(checkTimeValidation(startTime, endTime)){
                                 Navigator.of(context).pushReplacement(MaterialPageRoute(
                                     builder: (BuildContext context) => SubmitFormScreen(task_id, id)));

                               }else{
                                 Toast.show("You can complete this task between $strTime to $edtime",
                                     duration: Toast.lengthLong,
                                     gravity: Toast.bottom,
                                     backgroundColor: Colors.red);
                               }

                             }else{
                               Navigator.of(context).pushReplacement(MaterialPageRoute(
                                   builder: (BuildContext context) => ShowCompletedTaskDetails(task_id, id,task_role_id)));
                             }


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
                           ),
                         );







                       })),*/


             ],
           ),
         ),
         floatingActionButton: FloatingActionButton(
           onPressed: () {
             // Handle calendar button tap here
             showDatePicker(
               context: context,
               initialDate: DateTime.now(),
               firstDate: DateTime(2000),
               lastDate: DateTime.now(),
             ).then((selectedDate) {
               if (selectedDate != null) {
                 // Do something with the selected date
                 print("Selected: $selectedDate");
                 _redirectToDateTaskDetails(selectedDate);
               }
             });
           },
           backgroundColor: AppTheme.orangeColor,
           tooltip: 'Pick a date',
           child: const Icon(Icons.calendar_today, color: Colors.white),
         ),
       )
   );
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
    final outputDateFormat=DateFormat("dd MMM,yyyy");

    DateTime startDate = inputFormat.parse(startTime);
    DateTime endDate = inputFormat.parse(endTime);
    String strTime = outputFormat.format(startDate);
    String edtime = outputFormat.format(endDate);

    String timeStr = "$strTime - $edtime";

    String startTme="Start: $strTime";
    String endTme="End: $edtime";
    String taskDate=outputDateFormat.format(startDate);

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
            APIDialog.showErrorDialog("This task can be completed within the timeframe of $strTime to $edtime on $taskDate.", context);
            /*Toast.show("This task can be completed within the timeframe of $strTime to $edtime on $taskDate.",
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
            ),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getUserData();
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

    if(widget.taskType=="0"){
      pageTitle="Incomplete Checklist";
    }else{
      pageTitle="Completed Checklist";
    }



    dateList.clear();
    final sdf = DateFormat('yyyy-MM-dd');
    final curr = DateFormat('dd MMM, yyyy');
    final sdfDate = DateFormat('dd');
    final sdfDay = DateFormat('EEE');
    for(int i=6;i>=0;i--){
      int pos=-i;
      DateTime cal = DateTime.now().add(Duration(days: pos));
      String fullDate = sdf.format(cal);
      String cur = curr.format(cal);
      String date = sdfDate.format(cal);
      String dayS = sdfDay.format(cal);
      int isSelected = 0;
      if (i == 0) {
        isSelected = 1;
        selectedDate = fullDate;
        currentDate = fullDate;
        selectedDateForShow=cur;
      }
      print("Date Selected - Date: $fullDate DayNumber: $date day: $dayS");
      dateList.add(DateTimeListSeries(fullDate, dayS, date, isSelected));
    }
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEnd();
      });
    });
    _getHomePageData(context,selectedDate);
  }
  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  _getHomePageData(BuildContext context,String dateStr) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "date": dateStr,
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
  setOnDateClick(int index){
    for(int i=0;i<dateList.length;i++){
      if(i==index){
        selectedDate=dateList[i].FullDateStr;
        dateList[i].isSelected=1;
        selectedDateForShow=DateFormat('dd MMM, yyyy').format(DateTime.parse(selectedDate));
      }else{
        dateList[i].isSelected=0;
      }
    }
    setState(() {
      
    });
    _getHomePageData(context, selectedDate);
  }
  _redirectToDateTaskDetails(var selectedDate){
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    print("Selected date: $formattedDate");
    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowDateTaskScreen(formattedDate,currentDate,widget.taskType)),).then((value) => _getUserData());
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
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("On Resume state called");
      _getUserData(); // Make API call here
    }
  }
}