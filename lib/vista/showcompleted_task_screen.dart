import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/views/audio_player_screen.dart';
import 'package:vista/views/video_player_screen.dart';
import 'package:vista/vista/assign_task_user.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';

import '../utils/completed_task_series.dart';


class ShowCompletedTaskDetails extends StatefulWidget{
  String taskId;
  String subTaskId;
  String categoryId;

  ShowCompletedTaskDetails(this.taskId, this.subTaskId,this.categoryId, {super.key});

  @override
  _submittedTaskDetails createState()=>_submittedTaskDetails();


}
class _submittedTaskDetails extends State<ShowCompletedTaskDetails>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var pageTitle="";
  var assignTaskPermission="0";

  String taskTitleStr="";
  String taskIdStr="";


  String imageBaseUrl="";
  String voiceBaseUrl="";
  String videoBaseUrl="";
  String esignBaseUrl="";

  List<CompletedTaskQuestionSeries> completedQuestionList=[];

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: AppTheme.themeColor, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: AppTheme.at_details_header,
          title: Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              /// Task Header Card
              _taskHeaderCard(
                taskTitle: taskTitleStr,
                assignTaskPermission: assignTaskPermission,
                onAssignTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignCompletedTask(
                        widget.taskId,
                        taskTitleStr,
                        widget.categoryId,
                      ),
                    ),
                  );
                },
              ),

              /// Questions List
              ListView.builder(
                itemCount: completedQuestionList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final q = completedQuestionList[index];
                  return _QuestionCard(
                    index: index,
                    question: q.QuestionStr,
                    answer: q.AnswerStr,
                    image: q.ImageUrl,
                    esign: q.eSignUrl,
                    voice: q.VoiceUrl,
                    video: q.VideoUrl,
                    subQuestions: q.subQuestionlist,
                  );
                },
              ),
            ],
          ),
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
    assignTaskPermission=await MyUtils.getSharedPreferences("assign_task")??"0";
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }
    pageTitle="Completed Task Details";

    setState(() {
    });
    _getHomePageData(context);
  }

  _getHomePageData(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "task_id": widget.taskId,
      "sub_task_id": widget.subTaskId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'completed_task_detail', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      imageBaseUrl=responseJSON['imageBaseUrl'].toString();
      voiceBaseUrl=responseJSON['voiceBaseUrl'].toString();
      videoBaseUrl=responseJSON['videoBaseUrl']?.toString()??"";
      esignBaseUrl=responseJSON['esignBaseUrl']?.toString()??"";

      taskTitleStr=responseJSON['completedTasks']['task_name'].toString();
      completedQuestionList.clear();
      List<dynamic>tempList= [];
      tempList=responseJSON['completedTasks']['task_questions'];
      for(int i=0;i<tempList.length;i++){
        String QuestionId=tempList[i]['id'].toString();
        String question=tempList[i]['question'].toString();
        String AnswerStr=tempList[i]['answers']['answer'].toString();
        String image=tempList[i]['answers']['image'].toString();
        String voice=tempList[i]['answers']['voice'].toString();
        String video=tempList[i]['answers']['video']?.toString()??"";
        String esign=tempList[i]['answers']['esign']?.toString()??"";

        List<CompletedTaskSubQuestionSeries> subQuestionList=[];
        List<dynamic> subTempList=[];
        if(tempList[i]['sub_questions']!=null){
          subTempList=tempList[i]['sub_questions'];
        }
        for(int j=0;j<subTempList.length;j++){
          var subQ=subTempList[j];
          String mainQuestionId=subQ['question_id']?.toString()??"";
          String subQuestionId=subQ['id']?.toString()??"";
          String subQuestionStr=subQ['question']?.toString()??"";
          String subQuesAnser="";
          if(subQ['answers']!!=null){
            subQuesAnser=subQ['answers']['answer']?.toString()??"";
          }
          subQuestionList.add(CompletedTaskSubQuestionSeries(subQuestionId,subQuestionStr, mainQuestionId, subQuesAnser));
        }



        completedQuestionList.add(CompletedTaskQuestionSeries(QuestionId, question, AnswerStr, image, voice,video,esign,subQuestionList));
      }



      setState(() {

      });
    } else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      setState(() {

      });
      _finishScreen();

    }


  }

  _finishScreen(){
    Navigator.pop(context);
  }


  Widget _taskHeaderCard({required String taskTitle,required VoidCallback onAssignTap, required String assignTaskPermission}){
    return Card(
      color: AppTheme.lightblueColor,
      elevation: 4,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                taskTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.themeColor,
                ),
              ),
            ),
            if (assignTaskPermission == "1")
              InkWell(
                onTap: onAssignTap,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [AppTheme.baseOrangeStart, AppTheme.baseOrange],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Assign Task",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _QuestionCard(
  {required int index,required String question,required String answer,required String image, required String esign,required  String voice, required String video,required List<CompletedTaskSubQuestionSeries>subQuestions }){
    String yesNo = (answer == "1")
        ? "Yes"
        : (answer == "0")
        ? "No"
        : (answer == "null")?"":answer;

    return Card(
      color: AppTheme.lightblueColor,
      elevation: 4,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Q.${index + 1}) $question",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.themeColor)),
            const SizedBox(height: 12),
            yesNo.isEmpty?Container():
            Text("Answer: $yesNo",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.orangeColor)),
            const SizedBox(height: 12),

            /// Images Row
            Row(
              children: [
                if (image.isNotEmpty && image != "null")
                  Expanded(
                    child: Image.network("$imageBaseUrl/$image",
                        height: 150, fit: BoxFit.cover),
                  ),
                const SizedBox(width: 10),
                if (esign.isNotEmpty)
                  Expanded(
                    child: Image.network("$esignBaseUrl/$esign",
                        height: 150, fit: BoxFit.cover),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            /// Media Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (voice.isNotEmpty && voice != "null")
                  _ActionButton(
                    label: "Play Audio",
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AudioPlayerScreen(
                              "$voiceBaseUrl/$voice")));
                    },
                  ),
                if (video.isNotEmpty && video != "null")
                  _ActionButton(
                    label: "Play Video",
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              VideoPlayerScreen(videoUrl: "$videoBaseUrl/$video")));
                    },
                  ),
              ],
            ),

            /// Sub Questions
            if (subQuestions.isNotEmpty)
              ListView.builder(
                itemCount: subQuestions.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, subIndex) {
                  final subQ = subQuestions[subIndex];
                  String subYesNo = (subQ.AnswerStr == "1")
                      ? "Yes"
                      : (subQ.AnswerStr == "0")
                      ? "No"
                      : subQ.AnswerStr;

                  return _SubQuestionWidget(
                    parentIndex: index + 1,
                    subIndex: subIndex + 1,
                    question: subQ.subQuestionStr,
                    answer: subYesNo,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _SubQuestionWidget({required int parentIndex,required int subIndex, required  String question,required String answer }){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Q.$parentIndex.$subIndex) $question",
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.themeColor)),
          const SizedBox(height: 8),
          Text("Answer: $answer",
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.orangeColor)),
        ],
      ),
    );
  }

  Widget _ActionButton({required String label,required IconData icon,required VoidCallback onPressed}){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.orangeColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}






