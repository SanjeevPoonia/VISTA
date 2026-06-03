import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';
import 'package:vista/help/raised_issuelist_screen.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/views/notification_screen.dart';
import 'package:vista/vista/calendraview_screen.dart';
import 'package:vista/vista/create_task_screen.dart';
import 'package:vista/vista/drafted_task_screen.dart';
import 'package:vista/vista/edittask_screen.dart';
import 'package:vista/vista/pdf_view_screen.dart';
import 'package:vista/vista/rating_feedback_screen.dart';
import 'package:vista/vista/show_expired_checksheet_screen.dart';
import 'package:vista/vista/showcompleted_task_screen.dart';
import 'package:vista/vista/submitform_screen.dart';
import 'package:vista/vista/submitform_vi_screen.dart';
import 'package:vista/vista/update_password_screen.dart';
import 'package:vista/vista/vi_show_completed_task_details.dart';
import 'dart:io';
import '../help/raise_issue_screen.dart';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class LandingScreen extends StatefulWidget{
  _landingState createState()=>_landingState();
}
class _landingState extends State<LandingScreen>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var createTaskPermission="0";
  var assignTaskPermission="0";
  var editTaskPermission="0";

  String profileUrl="";
  String employeeRating="0.0";
  String reportTitle="Overall Task Report";
  String incompleteTitle="Incomplete Task";
  String completedTitle="Completed Task";
  String draftedTitle="Drafted Task";
  String createTask="Create Task";
  String raiseIssue="Raise Issue";
  String incompleteTaskCount='0';
  String completedTaskCount="0";
  String draftedTaskCount="0";
  String expiredTaskCount="0";
  String todayTaskTitle="Today Checklist";
  List<dynamic>todayTaskList=[];
  String noTaskTitle="No Task Available For Today";
  String notificationCount="0";

  String assignedBy="all";
  String byDueTime="nearest";
  String userGuidePdfUrl="";





  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.at_details_header, // notification area color
          statusBarIconBrightness: Brightness.dark,   // Android icons
          statusBarBrightness: Brightness.light,      // iOS
        ),
        elevation: 0,
        backgroundColor: AppTheme.at_details_header,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/update_pass.png',
            width: 28,
            height: 28,
            color: AppTheme.themeColor, // Optional, remove if image has its own colors
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UpdatePasswordScreen())).then((value) => {
              _getUserData()
            });
          },
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: AppTheme.themeColor, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen())).then((value) => {
                _getUserData()
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black, size: 28),
            onPressed: _showAlertDialog,
          ),
        ],
      ),
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// User Info Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.orangeColor,
                          child: profileUrl.length <= 2
                              ? Text(
                            profileUrl,
                            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                              : ClipOval(
                            child: Image.network(profileUrl, width: 80, height: 80, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 05,),
                        const Text("Welcome", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          sPersonName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.orangeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RatingFeedbackScreen())).then((value) => {
                        _getUserData()
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(employeeRating, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.orangeColor)),
                        const SizedBox(width: 5),
                        Lottie.asset(
                            'assets/rating.json',
                            repeat: true,
                            fit: BoxFit.contain,
                            width: 100,
                            height: 100
                        )
                      ],
                    ),
                  )

                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              /// Task Cards (refactor as grid or scrollable row)

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTaskCardNew("assets/pending.svg", "Pending", incompleteTaskCount, Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CalendraViewScreen("0"))).then((value) => {
                      _getUserData()
                    });
                  }),
                  _buildTaskCardNew("assets/completed.svg", "Completed", completedTaskCount, Colors.green, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CalendraViewScreen("1"))).then((value) => {
                      _getUserData()
                    });
                  }),
                  _buildTaskCardNew("assets/drft.svg", "Drafted", draftedTaskCount, Colors.blueGrey, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DraftedTaskScreen())).then((value) => {
                      _getUserData()
                    });
                  }),

                  _buildTaskCardNew("assets/expired.svg", "Expired", expiredTaskCount, Colors.red, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ShowExpiredCheckSheet())).then((value) => {
                      _getUserData()
                    });
                  }),

                  createTaskPermission=="1"?
                  _buildTaskCardNew("assets/create.svg", "New Task", createTask, AppTheme.themeColor, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateTaskScreen())).then((value) => {
                      _getUserData()
                    });
                  }):
                  _buildTaskCardRaise("assets/raise_issue.svg", "Issues &\nConcern",   () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RaisedIssuePage()),
                    );
                  }),

                  createTaskPermission!="1" && userGuidePdfUrl.isNotEmpty?
                  _buildGuideCard("assets/user_guide.json",  () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerPage( pdfUrl: userGuidePdfUrl,)));
                  })
                      :Container(),

                ],
              ),




              const SizedBox(height: 30),
              /// Today’s Tasks Title
              Row(
                children: [
                  Expanded(flex:1,child: Text(todayTaskTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 5,),
                  createTaskPermission=="1"?
                  InkWell(
                    onTap: (){
                      _showFilterDialog(context);
                    },
                    child: const Icon(Icons.filter_alt,size: 30,color: AppTheme.baseOrange,),
                  ):Container()
                ],
              ),
              const SizedBox(height: 15),
              /// Task List
              todayTaskList.isEmpty
                  ? Center(
                child: Text(noTaskTitle, style: const TextStyle(color: AppTheme.orangeColor, fontWeight: FontWeight.w500)),
              )
                  : ListView.builder(
                itemCount: todayTaskList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // Your task item logic here
                  return todayTaskList[index]["task_detail"]!=null?_buildTodayTaskCard(todayTaskList[index], context):Container();
                },
              ),
            ],
          ),
        ),
      )),

    );
  }
  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  _getUserData() async {
    sMobileNumber=await MyUtils.getSharedPreferences("mobile_no")??"";
    sPersonName=await MyUtils.getSharedPreferences("name")??"";
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    sUserId=await MyUtils.getSharedPreferences("user_id")??"";
    sUserLanguage=await MyUtils.getSharedPreferences("language")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    createTaskPermission=await MyUtils.getSharedPreferences("create_task")??"0";
    assignTaskPermission=await MyUtils.getSharedPreferences("assign_task")??"0";
    editTaskPermission=await MyUtils.getSharedPreferences("edit_task")??"0";
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
      "assigned_by":assignedBy,
      "sort_by_due_time":byDueTime
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'home_page', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      incompleteTaskCount=responseJSON['totalPandingTask'].toString();
      completedTaskCount=responseJSON['totalTask'].toString();
      expiredTaskCount=responseJSON['totalExpiredTask']?.toString()??"0";
      profileUrl=responseJSON['userProfile'].toString();
      print("Profile url $profileUrl");
      if(responseJSON['notificationCount']!=null){
        notificationCount=responseJSON['notificationCount'].toString();
      }
      if(responseJSON['employeeRating']!=null){
        employeeRating=responseJSON['employeeRating'].toString();
      }
      todayTaskList.clear();
      todayTaskList=responseJSON['todayTasks'];
      userGuidePdfUrl=responseJSON['guide_url']?.toString()??"";

      setState(() {

      });
      _getDraftedCount(context);



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
    }


  }
  _getDraftedCount(BuildContext context) async {
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
      List<dynamic> tempList=responseJSON['draftTask'];
      draftedTaskCount=tempList.length.toString();
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
    }


  }
  _logOut(BuildContext context)  {
    MyUtils.logoutUser(context);
  }
  _showAlertDialog(){
    showDialog(context: context, builder: (ctx)=> AlertDialog(
      title: const Text("Logout",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 18),),
      content: const Text("Are you sure you want to Logout ?",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16,color: Colors.black),),
      actions: <Widget>[
        TextButton(
            onPressed: (){
              Navigator.of(ctx).pop();
              _logOut(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.themeColor,
              ),
              height: 45,
              padding: const EdgeInsets.all(10),
              child: const Center(child: Text("Logout",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
            )
        ),
        TextButton(
            onPressed: (){
              Navigator.of(ctx).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.greyColor,
              ),
              height: 45,
              padding: const EdgeInsets.all(10),
              child: const Center(child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
            )
        )
      ],
    ));
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
  Widget _buildRaiseIssueCard( String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 22,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/support_ic.png",
              width: 30,
              height: 30,
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.orangeColor)),
            const SizedBox(height: 5),
            const Text("", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

          ],
        ),
      ),
    );
  }
  Widget _buildTaskCard(IconData icon, String title, String count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 22,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 6, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 10),
            Column(
              children: [
                Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 5),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            )

          ],
        ),
      ),
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

    String createdAt = task['task_detail']['created_at'].toString();
    String updated_at = task['task_detail']['updated_at'].toString();
    String task_repetation = task['task_detail']['task_repetation'].toString();

    String remark = task['task_detail']['remark']?.toString() ?? "";

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
    if (task['task_detail']['building_name'] != null) {
      buildingName = task['task_detail']['building_name'];
    }
    if (task['task_detail']['unit_number'] != null) {
      buildingName += " (${task['task_detail']['unit_number']})";
    }

    String taskPriority = "";
    Color priorityColor = AppTheme.orangeColor;

    if (task['task_detail']['priority'] != null) {
      switch (task['task_detail']['priority'].toString()) {
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
            if(createTaskPermission=="1"){
              Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitFormScreen(task_id, id))).then((value) => {
                _getUserData()
              });
            }else{

              Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitFormVIScreen(task_id, id))).then((value) => {
                _getUserData()
              });
            }

          } else {
            APIDialog.showErrorDialog("You can complete this task between $strTime to $edtime", context);
            /*Toast.show("You can complete this task between $strTime to $edtime",
                duration: Toast.lengthLong, gravity: Toast.bottom, backgroundColor: Colors.red);*/
          }
        } else {
          if(createTaskPermission=="1"){
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
                ): Container(): Container():Container(),


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
  Widget _buildTaskCardNew(String svg, String title, String count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 22,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 6, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            SvgPicture.asset(svg,height: 40,width: 40,fit: BoxFit.contain,),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            )

          ],
        ),
      ),
    );
  }
  Widget _buildTaskCardRaise(String svg, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 22,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 6, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            SvgPicture.asset(svg,height: 40,width: 40,fit: BoxFit.contain,),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w500,color: AppTheme.themeColor)),

          ],
        ),
      ),
    );
  }
  void _showFilterDialog(BuildContext context1){
    showDialog(context: context1,
      builder: (context){
        var _formKey=GlobalKey<FormState>();
        final List<String> assignedByList=["all","admin"];
        if(createTaskPermission=="1"){
          assignedByList.add("myself");
        }
        final List<String> bytimeList=['nearest','farthest'];
        String selectedAssignedBy=assignedBy;
        String selectedByTime=byDueTime;
        return  StatefulBuilder(
            builder: (BuildContext context,StateSetter setDialogState){
              return AlertDialog(
                title:const Text("Filter",style: TextStyle(fontWeight:FontWeight.bold,fontSize: 16,color: AppTheme.themeColor),),
                content: SizedBox(
                  width: 400,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Assigned By",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.orangeColor
                              )),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: assignedByList.map((status) {
                                return RadioListTile<String>(
                                  title: Text(status),
                                  value: status,
                                  groupValue: selectedAssignedBy, // Can be null
                                  onChanged: (String? value) {
                                    setDialogState(() {
                                      selectedAssignedBy = value!;
                                    });
                                  },
                                );
                              }).toList()
                          ),
                          SizedBox(height: 20),
                          const Text("Task Time",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.orangeColor
                              )),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: bytimeList.map((status) {
                                return RadioListTile<String>(
                                  title: Text(status),
                                  value: status,
                                  groupValue: selectedByTime, // Can be null
                                  onChanged: (String? value) {
                                    setDialogState(() {
                                      selectedByTime = value!;
                                    });
                                  },
                                );
                              }).toList()
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppTheme.task_Reopen_text),),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),child: Text('Apply'),),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                          FocusScope.of(context).unfocus();
                          assignedBy=selectedAssignedBy;
                          byDueTime=selectedByTime;
                          Navigator.of(context).pop();
                          setState(() {
                          });
                          _getHomePageData(context1);

                        }
                    },
                  ),
                ],
              );
            }

        );
      },);
  }
  Widget _buildGuideCard(String svg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 22,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 6, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
                svg,
                repeat: true,
                fit: BoxFit.contain,
                width: 40,
                height: 40
            ),
            const SizedBox(width: 16),
            const Text("User\nGuide", style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.w500,color: AppTheme.orangeColor)),
          ],
        ),
      ),
    );
  }

}