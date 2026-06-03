import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:vista/issue_admin/issue_detail_admin_page.dart';
import 'package:vista/utils/app_theme.dart';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import 'dart:io';

class ListOfIssuesPage extends StatefulWidget{
  final String title;
  const ListOfIssuesPage({super.key, required this.title});
  _listOfIssueState createState()=> _listOfIssueState();
}
class _listOfIssueState extends State<ListOfIssuesPage>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";

  String pendingStatus="pending";
  String inProgressStatus="work_in_progress";
  String rejectedStatus="rejected";
  String resolvedStatus="resolved";

  String currentIssueStatus="";
  Color cardColor=Colors.blue.shade100;

  String openTitle="Open Issues";
  String resolvedTitle="Resolved Issues";
  String rejectedTitle="Rejected Issues";
  String inProgressTitle="In Progress Issue";
  List<Map<String, String>> issues = [
    {
      "issue_id":"0",
      "issue_type": "Dummy",
      "issue_sub_type": "Dummy",
      "description": "Dummy",
      "created_by": "Test User",
      "created_on": "MMM dd,yyyy"
    }
  ];
  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.blueAccent;
      case "work_in_progress":
        return Colors.orangeAccent;
      case "resolved":
        return Colors.green;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    // Dummy issues



    return Scaffold(
      appBar: AppBar  (
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: AppTheme.themeColor,size: 24,),
          onPressed: () => {
            Navigator.pop(context)
          },
        ),
        backgroundColor: AppTheme.at_details_header,
        title:  Text(
          widget.title,
          style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.themeColor),
        ),
        /* actions: [
             IconButton(onPressed: (){
               _showAlertDialog();
             }, icon: const Icon(Icons.logout, color: AppTheme.task_Reopen_text,size: 35,))] ,*/
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: issues.isEmpty
            ? const Center(
          child: Text(
            "No issues found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        )
            : ListView.separated(
          itemCount: issues.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final issue = issues[index];
            String issueId=issue['issue_id']?.toString()??"";
            final statusColor = _getStatusColor(issue["status"] ?? "");

            return InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IssueDetailsAdminScreen(issueId: issueId),
                  ),
                ).then((value) => _getUserData());
              },
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cardColor, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Issue Type: ${issue['issue_type']}",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text("Issue Sub Type: ${issue['issue_sub_type']}",
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      Text("Description: ${issue['description']}",
                          style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 6),
                      Text("Created By: ${issue['created_by']}",
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      Text("Created On: ${issue['created_on']}",
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
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

    print(sRemeberToken);
    print(baseUrl);
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }
    final statusMap = {
      openTitle:   {"status": pendingStatus,   "color": Colors.blue.shade100},
      resolvedTitle: {"status": resolvedStatus, "color": Colors.green.shade100},
      rejectedTitle: {"status": rejectedStatus, "color": Colors.red.shade100},
      inProgressTitle: {"status": inProgressStatus, "color": Colors.orange.shade100},
    };
    final selected = statusMap[widget.title];
    if (selected != null) {
      currentIssueStatus = selected["status"] as String;
      cardColor = selected["color"] as Color;
    }




    setState(() {

    });
    _getTickets(context);
  }

  _getTickets(BuildContext context) async {
    APIDialog.showAlertDialog(context, "Please wait...");
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "type":currentIssueStatus
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'tickets', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      issues.clear();
      List<dynamic> tempList=responseJSON['data']??[];
      for(int i=0;i<tempList.length;i++){
        String issueId=tempList[i]['id']?.toString()??"";
        String raised_concern=tempList[i]['raised_concern']?.toString()??"";
        String status=tempList[i]['status']?.toString()??"";
        String issue=tempList[i]['issue']?['issue']?.toString()??"";
        String sub_issue=tempList[i]['sub_issue']?['sub_issue']?.toString()??"";
        String createdBY=tempList[i]['created_by']?['name']?.toString()??"";
        String createdAt=formatDate(tempList[i]['created_at']?.toString()??"");

        Map<String,String>map={
          "issue_id":issueId,
          "issue_type": issue,
          "issue_sub_type": sub_issue,
          "description": raised_concern,
          "created_by": createdBY,
          "created_on": createdAt
        };
        issues.add(map);

      }



      setState(() {

      });

    }else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      MyUtils.logoutUser(context);
    }
    else {
      setState(() {
      });
      /*Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);*/
      APIDialog.showErrorDialog(responseJSON["message"]?.toString()??"Something went wrong. Please try again", context);
    }


  }
  String formatDate(String isoString) {
    try {
      // Parse ISO string (Z = UTC timezone)
      final dateTime = DateTime.parse(isoString).toLocal();
      // Format to desired style
      return DateFormat("MMM dd, yyyy hh:mm a").format(dateTime);
    } catch (e) {
      return "";
    }
  }
}