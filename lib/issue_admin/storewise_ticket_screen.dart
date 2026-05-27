import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:vista/network/api_dialog.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_helper.dart';
import 'issue_detail_admin_page.dart';

class StoreTicketsPage extends StatefulWidget {
  final String storeId;
  final String storeName;

  const StoreTicketsPage({super.key, required this.storeId, required this.storeName});

  @override
  State<StoreTicketsPage> createState() => _StoreTicketsPageState();
}

class _StoreTicketsPageState extends State<StoreTicketsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample dummy tickets data (API से आएगा असली data)
   Map<String, List<Map<String, dynamic>>> ticketsData = {
    "Open": [
      {
        "issue_type": "Dummy",
        "issue_sub_type": "Dummy",
        "description": "Dummy",
        "created_by": "Test User",
        "created_on": "MMM dd,yyyy"
      },
    ],
    "In Progress": [
      {
        "issue_type": "Dummy",
        "issue_sub_type": "Dummy",
        "description": "Dummy",
        "created_by": "Test User",
        "created_on": "MMM dd,yyyy"
      },
    ],
    "Resolved": [
      {
        "issue_type": "Dummy",
        "issue_sub_type": "Dummy",
        "description": "Dummy",
        "created_by": "Test User",
        "created_on": "MMM dd,yyyy"
      },
    ],
    "Rejected": [
      {
        "issue_type": "Dummy",
        "issue_sub_type": "Dummy",
        "description": "Dummy",
        "created_by": "Test User",
        "created_on": "MMM dd,yyyy"
      },
    ],
  };

  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    setState(() {

    });
    _getTickets(context);

  }
  _getTickets(BuildContext context) async {
   APIDialog.showAlertDialog(context, "Please wait...");
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "store_id":widget.storeId
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get-individual-store-ticket', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {

      List<dynamic> tempList=responseJSON['data']??[];
      List<Map<String,String>>openList=[];
      List<Map<String,String>>inProgressList=[];
      List<Map<String,String>>resolvedList=[];
      List<Map<String,String>>rejectedList=[];

      for(int i=0;i<tempList.length;i++){
        String issueId=tempList[i]['id']?.toString()??"";
        String issueType=tempList[i]['issue']?['issue']?.toString()??"";
        String subIssue=tempList[i]['sub_issue']?['sub_issue']?.toString()??"";
        String description=tempList[i]['raised_concern']?.toString()??"";
        String createdBy=tempList[i]['created_by']?['name'].toString()??"";
        String createdAt=tempList[i]['created_at']?.toString()??"";
        String converted=formatDate(createdAt);
        String status=tempList[i]['status']?.toString()??"pending";

        Map<String,String> map= {
          "issue_id":issueId,
          "issue_type": issueType,
          "issue_sub_type": subIssue,
          "description": description,
          "created_by": createdBy,
          "created_on": converted
        };

        if(status=="pending"){
          openList.add(map);
        }else if(status=="complated"){
          resolvedList.add(map);
        }else if(status=="work_in_progress"){
          inProgressList.add(map);
        }else{
          rejectedList.add(map);
        }

      }
      ticketsData['Open']=openList;
      ticketsData['In Progress']=inProgressList;
      ticketsData['Resolved']=resolvedList;
      ticketsData['Rejected']=rejectedList;


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
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
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
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.storeName}",
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4A90E2), // Muted Blue
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Open"),
            Tab(text: "In Progress"),
            Tab(text: "Resolved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTicketsList(ticketsData["Open"] ?? [], Colors.blue.shade100),
          buildTicketsList(ticketsData["In Progress"] ?? [], Colors.orange.shade100),
          buildTicketsList(ticketsData["Resolved"] ?? [], Colors.green.shade100),
          buildTicketsList(ticketsData["Rejected"] ?? [], Colors.red.shade100),
        ],
      ),
    );
  }
  Widget buildTicketsList(List<Map<String, dynamic>> tickets, Color cardColor) {
    if (tickets.isEmpty) {
      return const Center(
        child: Text("No Issues available",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return InkWell(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IssueDetailsAdminScreen(issueId: ticket['issue_id']),
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
                  Text("Issue Type: ${ticket['issue_type']}",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text("Issue Sub Type: ${ticket['issue_sub_type']}",
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("Description: ${ticket['description']}",
                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text("Created By: ${ticket['created_by']}",
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  Text("Created On: ${ticket['created_on']}",
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}