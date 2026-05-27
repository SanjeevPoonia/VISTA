import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:vista/help/raise_issue_screen.dart';
import 'package:vista/help/raised_issue_details_screen.dart';
import 'package:vista/utils/app_theme.dart';

import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import 'dart:io';

class RaisedIssuePage extends StatefulWidget{
  _raisedIssueState createState()=>_raisedIssueState();
}

class _raisedIssueState extends State<RaisedIssuePage> {

  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var sUserLanguage="";

  List<dynamic> raisedIssueList=[];
  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.blueAccent;
      case "work_in_progress":
        return Colors.deepOrange;
      case "complated":
        return Colors.green;
      case "resolved":
        return Colors.green;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
  String pageTitle="Raised Issue";
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
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
      body: raisedIssueList.isEmpty? const Center(child:  Padding(padding: EdgeInsets.all(15),child:Text(
        "You haven't raised any issues yet. Tap the icon below to create a Issue.",
        style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),
      ) ,),): ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: raisedIssueList.length,
        itemBuilder: (context, index) {
          final issue = raisedIssueList[index];

          String issueType="";
          if(issue['issue']!=null){
            if(issue['issue']['issue']!=null){
              issueType=issue['issue']['issue'].toString();
            }
          }

          String subIssueType="";
          if(issue['sub_issue']!=null){
            if(issue['sub_issue']['sub_issue']!=null){
              subIssueType=issue['sub_issue']['sub_issue'].toString();
            }
          }
          String concern=issue["raised_concern"]?.toString()??"";




          return  Card(

              margin: const EdgeInsets.symmetric(vertical: 8),
              shadowColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              child: ListTile(
                title: Text(issueType,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subIssueType.isEmpty?concern:subIssueType),
                    const SizedBox(height: 4),
                    Text(
                      "Created: ${formatDate(issue["created_at"]?.toString() ?? "")}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(issue["status"]?.toString()??"pending").withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatusIssue(issue["status"]?.toString()??"pending"),
                    style: TextStyle(
                      color: _getStatusColor(issue["status"]?.toString()??"pending"),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RaisedIssueDetailsPage(issue)),
                  );
                },
              ),
            );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF47320), // Orange background
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RaiseIssuePage()),
          ).then((value) => _getUserData());
        },
        child: SvgPicture.asset("assets/create_issue.svg",height: 24,width: 24,
            colorFilter: const ColorFilter.mode(
          Colors.white, // 👈 desired color
          BlendMode.srcIn, // blend mode
        ),),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
  String getStatusIssue(String code){
    if(code=="pending"||code=="open"){
      return "Open";
    }else if(code=="complated" || code=="resolved"){
      return "Resolved";
    }else if(code=="rejected"){
      return "Rejected";
    }else if(code=="work_in_progress"){
      return "In Progress";
    }else{
      return code;
    }
  }
  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  _getUserData() async {
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
    _getIssueList(context);
  }
  _getIssueList(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'user-raised-issues', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      raisedIssueList.clear();
      raisedIssueList = List.from(responseJSON['data']);
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
      raisedIssueList.clear();
      setState(() {

      });
    }


  }
}