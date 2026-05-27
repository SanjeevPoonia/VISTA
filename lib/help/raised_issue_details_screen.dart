import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/views/audio_player_screen.dart';
import 'package:vista/views/video_player_screen.dart';



class RaisedIssueDetailsPage extends StatefulWidget{
  var issue;
  RaisedIssueDetailsPage(this.issue, {super.key});
  _raisedIssueState createState()=> _raisedIssueState();
}
class _raisedIssueState extends State<RaisedIssueDetailsPage>{

  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.blueAccent;
      case "work_in_progress":
        return Colors.orangeAccent;
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
  String getStatusIssue(String code){
    if(code=="pending"||code=="open"){
      return "Open";
    }else if(code=="complated"||code=="resolved"){
      return "Resolved";
    }else if(code=="rejected"){
      return "Rejected";
    }else if(code=="work_in_progress"){
      return "In Progress";
    }else{
      return code;
    }
  }
  String issueType="";
  String subIssueType="";
  String userRemark="";
  String adminRemark="";
  String statusStr="";
  String artifactUrl="";
  String createdAt="";
  String updatedAt="";
  String audioUrl="";
  String videoUrl="";


  @override
  Widget build(BuildContext context) {
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
            // 🟢 Issue Info Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Issue Type:", issueType),
                    subIssueType.isNotEmpty?
                    _infoRow("Sub Type:", subIssueType):Container(),
                    _infoRow("Description:", userRemark),
                    _infoRow("Created At:", createdAt),
                    updatedAt.isNotEmpty?
                    _infoRow("Last Modified At:", updatedAt):Container(),
                    adminRemark.isNotEmpty?_infoRow("Admin Remark:", adminRemark):Container(),
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
                            color: _getStatusColor(statusStr).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            getStatusIssue(statusStr),
                            style: TextStyle(
                                color: _getStatusColor(statusStr),
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
            const Text("Uploaded Artifact:",
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
            const SizedBox(height: 24),

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
            )

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
    _getData();
  }
  _getData(){
    var issueData=widget.issue;

    if(issueData['issue']!=null){
      if(issueData['issue']['issue']!=null){
        issueType=issueData['issue']['issue'].toString();
      }
    }


    if(issueData['sub_issue']!=null){
      if(issueData['sub_issue']['sub_issue']!=null){
        subIssueType=issueData['sub_issue']['sub_issue'].toString();
      }
    }
    userRemark=issueData["raised_concern"]?.toString()??"";
    adminRemark=issueData["remark"]?.toString()??"";
    statusStr=issueData['status']?.toString()??"pending";
    artifactUrl=issueData['artifact_url']?.toString()??"";
    audioUrl=issueData['voice_url']?.toString()??"";
    videoUrl=issueData['video_url']?.toString()??"";
    createdAt=formatDate(issueData['created_at']?.toString()??"");
    updatedAt=formatDate(issueData['updated_at']?.toString()??"");


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