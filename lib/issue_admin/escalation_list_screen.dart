import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:vista/issue_admin/escalated_details_screen.dart';
import 'package:vista/network/Utils.dart';
import 'package:vista/network/api_dialog.dart';
import 'package:vista/network/api_helper.dart';
import 'package:vista/network/loader.dart';
import '../utils/app_theme.dart';

class EscalationListScreen extends StatefulWidget {
  const EscalationListScreen({Key? key}) : super(key: key);

  @override
  State<EscalationListScreen> createState() =>
      _EscalationListScreenState();
}

class _EscalationListScreenState extends State<EscalationListScreen> {

  bool isLoading=false;
  var sRemeberToken="";
  var platform="";
  var baseUrl="";
  var userRole="";
  String EmpRoleId="";
  List<dynamic> escList=[];
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(

      backgroundColor: const Color(0xffF4F6F8),

      appBar: AppBar(

        elevation: 0,

        title: const Text(
          "Missed Checklist",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),

        backgroundColor: AppTheme.at_details_header,

        iconTheme: const IconThemeData(color: Colors.black),

      ),

      body: isLoading?Center(child: Loader(),):escList.isEmpty
          ? _emptyWidget()
          : ListView.builder(

        padding: const EdgeInsets.all(15),

        itemCount: escList.length,

        itemBuilder: (context, index) {

          final item = escList[index];

          return _escalationCard(item);

        },

      ),
    );
  }
  Widget _escalationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item["task_name"]??"",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Divider(height: 30),
            const SizedBox(height: 18),


            buildInfoRow(
              Icons.person,
              "Store Manager",
              item["sm_name"]??"",
            ),

            buildInfoRow(
              Icons.store,
              "Store",
              item["store_name"]??"",
            ),
            buildInfoRow(
              Icons.schedule,
              "Alert At",
              formatDateTime( EmpRoleId=="20"?item['arl_alert_at']??"":item['tl_alert_at']??""),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.themeColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text("View Details"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EscalatedDetailsScreen(
                        escalation: item,
                      ),
                    ),
                  ).then((value){
                    _getTicketEscalations(context);
                  });
                },
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _emptyWidget() {

    return const Center(

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(Icons.assignment_late_outlined,
              size: 80,
              color: Colors.grey),

          SizedBox(height: 15),

          Text(
            "No Escalations Found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          Text(
            "All escalations will appear here.",
            style: TextStyle(
                color: Colors.grey),
          ),

        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  _getUserData() async {
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    EmpRoleId= await MyUtils.getSharedPreferences("emp_role_id")??"";
    print(sRemeberToken);
    print(baseUrl);
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }
    setState(() {
    });
    _getTicketEscalations(context);
  }
  _getTicketEscalations(BuildContext context) async {
    setState(() {
      isLoading=true;
    });
    var data = {
      "auth_key": sRemeberToken,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'checklist/escalate-list', data, context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      escList.clear();
      escList=responseJSON['data']??[];
      setState(() {
        isLoading=false;
      });

    }else if(responseJSON["status"]==3){

      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      setState(() {
        isLoading=false;
      });

      MyUtils.logoutUser(context);

    } else {
      setState(() {
        isLoading=false;
      });
      APIDialog.showErrorDialog(responseJSON["message"]?.toString()??"Something went wrong. Please try again", context);
    }


  }
  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "";
    }

    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd MMM, yyyy hh:mm a').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }
  Widget buildInfoRow(
      IconData icon,
      String title,
      String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [

          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: AppTheme.themeColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.themeColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}