import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/views/audio_player_screen.dart';
import 'package:vista/views/video_player_screen.dart';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import 'dart:io';
class IssueDetailsAdminScreen extends StatefulWidget{
  final String issueId;
   const IssueDetailsAdminScreen({super.key, required this.issueId});
  _issueDetailsState createState()=>_issueDetailsState();
}
class _issueDetailsState extends State<IssueDetailsAdminScreen>{
  String? selectedStatus;
  final TextEditingController remarkController = TextEditingController();

  final List<String> statusOptions = [
    "Open",
    "In Progress",
    "Resolved",
    "Rejected"
  ];

  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var sRole="";

  String currentIssueId="";
  String currentSubIssueId="";
  String currentUserId="";
  String raisedConcern="";
  String adminRemark="";
  String artifact="";
  String currentStatus="";
  String createdAt="";
  String updateAt="";
  String artifactUrl="";
  String audioUrl="";
  String videoUrl="";
  String issueName="";
  String subIssueName="";
  String createdBy="";

  String storeName="";
  String storeCode="";
  String storeAddress="";
  String storePincode="";
  String storeCircleName="";
  String storeRegionName="";
  String storeStateName="";
  String storeCityName="";

  String openStatus="open";
  String pendingStatus="pending";
  String inProgressStatus="work_in_progress";
  String rejectedStatus="rejected";
  String resolvedStatus="resolved";
  String currentStatusCode="";
  String newSelectedStatusCode="";




  Color _getStatusColor(String status){
    switch (status) {
      case "Open":
        return Colors.blueAccent;
      case "In Progress":
        return Colors.orangeAccent;
      case "Resolved":
        return Colors.green;
      case "Rejected":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.at_details_header,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: AppTheme.themeColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Issue Detail",
          style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.themeColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: Text(
                storeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.themeColor,
                ),
              ),
              collapsedBackgroundColor: Colors.grey[200],
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("Store Code:", storeCode),
                      _infoRow("Address:", storeAddress),
                      _infoRow("City:", storeCityName),
                      _infoRow("State:", storeStateName),
                      _infoRow("Pincode:", storePincode),
                      _infoRow("Region:", storeRegionName),
                      _infoRow("Circle:", storeCircleName),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   // storeName.isNotEmpty? Text(storeName,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: AppTheme.themeColor),):Container(),
                    createdBy.isNotEmpty?_infoRow("Created By:", createdBy):Container(),
                    _infoRow("Issue Type:", issueName),
                    _infoRow("Sub Type:", subIssueName),
                    _infoRow("User Remark:", raisedConcern),
                    _infoRow("Created At:", createdAt),
                    updateAt.isNotEmpty?
                    _infoRow("Last Modified At:", updateAt):Container(),
                    adminRemark.isNotEmpty?
                    _infoRow("Admin Remark:", adminRemark):Container(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          "Status:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(currentStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentStatus,
                            style: TextStyle(
                                color: _getStatusColor(currentStatus),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🖼 Image Section
            const Text("Image from User:",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: artifactUrl.isNotEmpty?Image.network(artifactUrl,
                  height: 250, fit: BoxFit.cover):const Center(child: Text("No Image Provided")),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                audioUrl.isNotEmpty?
                Expanded(flex:1,child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => AudioPlayerScreen(audioUrl)));
                  },
                  icon: const Icon(Icons.audio_file_outlined, color: Colors.white),
                  label: const Text("Play Audio"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.themeColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                )):Container(),

                SizedBox(width: 10,),

                videoUrl.isNotEmpty?
                Expanded(flex:1,child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => VideoPlayerScreen( videoUrl: videoUrl,)));
                  },
                  icon: const Icon(Icons.video_camera_back_outlined, color: Colors.white),
                  label: const Text("Play Video"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orangeColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                )):Container(),
              ],
            ),

            const SizedBox(height: 24),

            // ✏️ Update Section (only if not resolved/rejected)
            if (sRole=="project_head"&&currentStatus != "Resolved" && currentStatus != "Rejected") ...[
              const Text("Change Status:",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: statusOptions.map((status) {
                  return DropdownMenuItem(
                      value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedStatus = value);
                },
              ),
              const SizedBox(height: 20),

              TextField(
                controller: remarkController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  labelText: "Add Remark",
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    _submitBtnValidation();
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Submit",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                )),
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
    sMobileNumber=await MyUtils.getSharedPreferences("mobile_no")??"";
    sPersonName=await MyUtils.getSharedPreferences("name")??"";
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    sUserId=await MyUtils.getSharedPreferences("user_id")??"";
    sUserLanguage=await MyUtils.getSharedPreferences("language")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    sRole=await MyUtils.getSharedPreferences("user_role")??"";

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
      "ticket_id":widget.issueId
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get-ticket-data', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {

      if(responseJSON['data']!=null){
        currentIssueId=responseJSON['data'][0]['issue_id']?.toString()??"";
        currentSubIssueId=responseJSON['data'][0]['sub_issue_id']?.toString()??"";
        currentUserId=responseJSON['data'][0]['user_id']?.toString()??"";
        raisedConcern=responseJSON['data'][0]['raised_concern']?.toString()??"";
        adminRemark=responseJSON['data'][0]['remark']?.toString()??"";


        print("Admin Remark : $adminRemark");

        artifact=responseJSON['data'][0]['artifact']?.toString()??"";

        currentStatusCode=responseJSON['data'][0]['status']?.toString()??"";
        String createdA=responseJSON['data'][0]['created_at']?.toString()??"";
        String updatedA=responseJSON['data'][0]['updated_at']?.toString()??"";
        createdAt=formatDate(createdA);
        updateAt=formatDate(updatedA);
        artifactUrl=responseJSON['data'][0]['artifact_url']?.toString()??"";
        audioUrl=responseJSON['data'][0]['voice_url']?.toString()??"";
        videoUrl=responseJSON['data'][0]['video_url']?.toString()??"";
        issueName=responseJSON['data'][0]['issue']?['issue']?.toString()??"";
        subIssueName=responseJSON['data'][0]['sub_issue']?['sub_issue']?.toString()??"";
        createdBy=responseJSON['data'][0]['created_by']?['name']?.toString()??"";

        final store = responseJSON['data']?[0]?['created_by']?['stores']?['store'];

        storeName       = store?['name']?.toString() ?? "";
        storeAddress    = store?['address']?.toString() ?? "";
        storeCode       = store?['store_code']?.toString() ?? "";
        storePincode    = store?['pincode']?.toString() ?? "";
        storeCircleName = store?['circle_name']?.toString() ?? "";
        storeRegionName = store?['region_name']?.toString() ?? "";
        storeStateName  = store?['state_name']?.toString() ?? "";
        storeCityName   = store?['city_name']?.toString() ?? "";




        if(currentStatusCode==openStatus||currentStatusCode=="pending"){
          currentStatus="Open";
        }else if(currentStatusCode==inProgressStatus){
          currentStatus="In Progress";
        }else if(currentStatusCode==resolvedStatus){
          currentStatus="Resolved";
        }else if(currentStatusCode==rejectedStatus){
          currentStatus="Rejected";
        }else{
          currentStatus=currentStatusCode;
        }

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
  _submitBtnValidation(){
    if(selectedStatus!=null){

      if(selectedStatus=="Open"){
        newSelectedStatusCode=pendingStatus;
      }else if(selectedStatus=="In Progress"){
        newSelectedStatusCode=inProgressStatus;
      }else if(selectedStatus=="Resolved"){
        newSelectedStatusCode=resolvedStatus;
      }else if(selectedStatus=="Rejected"){
        newSelectedStatusCode=rejectedStatus;
      }
      if(currentStatusCode!=newSelectedStatusCode){
        if(remarkController.text.isNotEmpty){
          _updateTicketStatus(context);
        }else{
          Toast.show("Please enter an update remark.",
              duration: Toast.lengthLong,
              gravity: Toast.bottom,
              backgroundColor: Colors.red);
        }
      }else{
        Toast.show("The selected status is already applied. Kindly choose another.",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }

  }else{
      Toast.show("Please select status",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }

  }
  _updateTicketStatus(BuildContext context) async {
    APIDialog.showAlertDialog(context, "Please wait...");
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "ticket_id":widget.issueId,
      "remark":remarkController.text,
      "status":newSelectedStatusCode,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'update-ticket', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);

      setState(() {

      });
      Navigator.pop(context);

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
}
