import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/views/audio_player_screen.dart';
import 'package:vista/views/video_player_screen.dart';
import 'package:vista/vista/assign_task_user.dart';
import 'package:vista/vista/vi_completed_task_question_series.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../utils/completed_task_series.dart';
import '../utils/vi_task_question_series.dart';



class ViShowCompletedTaskDetails extends StatefulWidget{
  String taskId;
  String subTaskId;
  String categoryId;

  ViShowCompletedTaskDetails(this.taskId, this.subTaskId,this.categoryId, {super.key});

  @override
  _submittedTaskDetails createState()=>_submittedTaskDetails();


}
class _submittedTaskDetails extends State<ViShowCompletedTaskDetails>{
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



  List<ViCompltedTaskQuestionSeries> questionList=[];
  List<bool> _expandedState = [];

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

              ///new Design screens
              ListView.builder(
                  itemCount: questionList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int groupIndex){
                    var groupData=questionList[groupIndex];
                    String groupId=groupData.groupId;
                    String groupType=groupData.groupType;
                    String groupName=groupData.groupName;
                    List<ViCompletedTaskSubGroupList> subGroupList=groupData.subGroupList;

                    return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.ExpensionTileBorder, width: 2),
                        ),
                        child:ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          trailing: Icon(
                            _expandedState[groupIndex] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 32,
                            color: AppTheme.themeColor,
                          ),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _expandedState[groupIndex] = expanded;
                            });
                          },
                          backgroundColor: AppTheme.ExpensionTileColoe,
                          collapsedBackgroundColor: AppTheme.ExpensionTileColoe,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          title: Text(
                            groupName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.themeColor,
                            ),
                          ),
                          children: [
                            ListView.builder(
                                itemCount: subGroupList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context,int subIndex){
                                  var subGroup=subGroupList[subIndex];
                                  String subGroupId=subGroup.subGroupId;
                                  String  subGroupName=subGroup.subGroupName;
                                  List<viCompletedQuestionsList> showQuestionList=subGroup.questionList;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.orangeColor, width: 2),
                                  ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 5),
                                          width:double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              color: AppTheme.orangeColor
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Text(
                                              subGroupName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Padding(padding: EdgeInsets.only(top: 3,left: 3,right: 3,bottom: 0),
                                          child: ListView.builder(
                                              itemCount: showQuestionList.length,
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder: (BuildContext context, int index){
                                                var question=showQuestionList[index];
                                                int qNo=index+1;
                                                String questionId=question.questionId;
                                                String answerId=question.answerStr;
                                                String answerStr="";
                                                if(answerId=="1"){
                                                  answerStr="Yes";
                                                }
                                                else if(answerId=="0"){
                                                  answerStr="No";
                                                }
                                                else if(answerId!="null"){
                                                  answerStr=question.answerStr;
                                                }

                                                String questiontype=question.type;
                                                String imageUrl=question.imageUrl;
                                                String voiceUrl=question.voiceUrl;
                                                String videoUrl=question.videoUrl;
                                                String eSignUrl=question.eSignUrl;

                                                List<viCompletedSubQuestionListSeries> subQuestionList=question.subQuestionList;
                                                List<String> uploadedImageList = [];
                                                if (imageUrl != "null" && imageUrl.isNotEmpty) {
                                                  uploadedImageList = imageUrl.split(",");
                                                }
                                                String readOnlyAnswer=question.readOnlyAnswer;
                                                String ScoreQuestion= question.selfScore;



                                                return Card(
                                                  margin: const EdgeInsets.only(bottom: 5,left: 3,right: 3),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  elevation: 2,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Expanded(flex:1,child: Text(
                                                              "Q${index + 1}. ${question.question}",
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppTheme.themeColor,
                                                              ),
                                                            )),
                                                            Padding(
                                                              padding: EdgeInsets.all(3),
                                                              child: buildCountBadge(ScoreQuestion),)
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                            Expanded(flex:2,
                                                              child:

                                                              questiontype=="read_only"?
                                                              Container(
                                                                padding: EdgeInsets.all(10),
                                                                width: double.infinity,
                                                                height: 50,
                                                                color: Colors.white,
                                                                child: Text(
                                                                  readOnlyAnswer,style: const TextStyle(fontWeight: FontWeight.w900,color: Colors.black,fontSize: 16),
                                                                ),
                                                              ):
                                                              Container(
                                                                padding: EdgeInsets.all(10),
                                                                width: double.infinity,
                                                                height: 50,
                                                                color: Colors.white,
                                                                child: Text(
                                                                  answerStr,style: const TextStyle(fontWeight: FontWeight.w900,color: Colors.black,fontSize: 16),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 10,),

                                                        const SizedBox(height: 10,),
                                                        uploadedImageList.isNotEmpty?
                                                        GridView.builder(
                                                          shrinkWrap: true, // important
                                                          physics: const NeverScrollableScrollPhysics(), // ListView scroll handle karega
                                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2, // 2 columns
                                                            crossAxisSpacing: 12,
                                                            mainAxisSpacing: 12,
                                                            childAspectRatio: 1, // square look
                                                          ),
                                                          itemCount: uploadedImageList.length,
                                                          itemBuilder: (context, index) {
                                                            final url = "$imageBaseUrl/${uploadedImageList[index]}";
                                                            return ClipRRect(
                                                              borderRadius: BorderRadius.circular(16), // rounded corners
                                                              child: CachedNetworkImage(
                                                                imageUrl: url,
                                                                fit: BoxFit.cover,
                                                                placeholder: (context, url) => Container(
                                                                  color: Colors.grey[200],
                                                                  child: const Center(
                                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                                  ),
                                                                ),
                                                                errorWidget: (context, url, error) =>
                                                                const Icon(Icons.error, color: Colors.red),
                                                              ),
                                                            );
                                                          },
                                                        ):Container(),
                                                        const SizedBox(height: 10,),
                                                        Row(
                                                          children: [
                                                             /*isImageUploaded==1?
                                                        Expanded(flex:1,child: Container(
                                                          height: 150,
                                                          width: double.infinity, // Optional: takes full width
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: NetworkImage(imageUrl),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        )):Container(),*/

                                                        SizedBox(width: 10,),
                                                            eSignUrl.isNotEmpty?
                                                            Expanded(flex:1,child: Container(
                                                              height: 150,
                                                              width: double.infinity, // Optional: takes full width
                                                              decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                  image: NetworkImage("$esignBaseUrl/$eSignUrl"),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            )):Container(),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 10,),
                                                        Row(
                                                          children: [
                                                            voiceUrl.isNotEmpty?
                                                            Expanded(flex:1,child: ElevatedButton.icon(
                                                              onPressed: () {
                                                                Navigator.of(context).push(MaterialPageRoute(
                                                                    builder: (BuildContext context) => AudioPlayerScreen("$voiceBaseUrl/$voiceUrl")));
                                                              },
                                                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                                                              label: const Text("Play Audio"),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppTheme.orangeColor,
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
                                                                    builder: (BuildContext context) => VideoPlayerScreen( videoUrl: "$videoBaseUrl/$videoUrl",)));
                                                              },
                                                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
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
                                                        subQuestionList.isNotEmpty?
                                                        ListView.builder(
                                                            itemCount: subQuestionList.length,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemBuilder: (BuildContext subContext,int subQIndex){
                                                              int subQNo=subQIndex+1;
                                                              String subquestionId=subQuestionList[subQIndex].subQuestionId;
                                                              String mainQuestionId=subQuestionList[subQIndex].questionId;
                                                              String subQuText="Q.$qNo.$subQNo)  ${subQuestionList[subQIndex].subQuestionText}";
                                                              String subAnswerStr=subQuestionList[subQIndex].subAnswer;

                                                              return Padding(
                                                                  padding: EdgeInsets.all(10),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(subQuText,style: const TextStyle(
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: AppTheme.themeColor
                                                                      ),),
                                                                      const SizedBox(height: 5,),
                                                                      Container(
                                                                        padding: EdgeInsets.all(10),
                                                                        width: double.infinity,
                                                                        height: 50,
                                                                        color: Colors.white,
                                                                        child: Text(
                                                                          subAnswerStr,style: const TextStyle(fontWeight: FontWeight.w900,color: Colors.black,fontSize: 16),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 15,),
                                                                    ],
                                                                  )
                                                              );


                                                            }):Container(),
                                                      ],
                                                    ),
                                                  ),
                                                );

                                              }),
                                        ),
                                      ],
                                    ),
                                  );

                                })
                          ],
                        )

                    );
                  }),

              const SizedBox(height: 20),


            /*  /// Questions List
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
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCountBadge(String count) {

    Color color=Colors.grey;
    if(count == "0"){
      color=Colors.red;
    }else if(count == "NA"){
      color=Colors.grey;
    }else{
      color=AppTheme.themeColor;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle, //
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
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
    var response = await helper.postAPI(baseUrl,'vi_completed_task_detail', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      imageBaseUrl=responseJSON['imageBaseUrl']?.toString()??"";
      voiceBaseUrl=responseJSON['voiceBaseUrl']?.toString()??"";
      videoBaseUrl=responseJSON['videoBaseUrl']?.toString()??"";
      esignBaseUrl=responseJSON['esignBaseUrl']?.toString()??"";
      taskTitleStr=responseJSON['task_name'].toString();


      List<dynamic> groupList = responseJSON['groups'] ?? [];
      questionList = groupList.map((group) {
        String groupId = group['id']?.toString() ?? "";
        String groupType = group['group_type']?.toString() ?? "";
        String groupName = group['name']?.toString() ?? "";
        List<dynamic> subGroups = group['sub_groups'] ?? [];
        List<ViCompletedTaskSubGroupList> viSubGroupList = [];

        // Helper to build questions list from a given list
        List<viCompletedQuestionsList> buildQuestions(List<dynamic> questions) => questions.map((q) {
          List<viCompletedSubQuestionListSeries> subQuestions = (q['sub_questions'] ?? []).map<viCompletedSubQuestionListSeries>((sq) {
            return viCompletedSubQuestionListSeries(
                sq['id']?.toString() ?? "",
                sq['task_id']?.toString() ?? "",
                sq['question_id']?.toString() ?? "",
                sq['type']?.toString() ?? "",
                sq['question']?.toString() ?? "",
                ""
            );
          }).toList();
          return viCompletedQuestionsList(
              q['id']?.toString() ?? "",
              q['group_id']?.toString() ?? "",
              q['sub_group_id']?.toString() ?? "",
              q['task_id']?.toString() ?? "",
              q['type']?.toString() ?? "",
              q['question']?.toString() ?? "",
              q['answers']?['answer']?.toString()??"",
              q['answers']?['image']?.toString()??"",
              q['answers']?['voice']?.toString()??"",
              q['answers']?['video']?.toString()??"",
              q['answers']?['esign']?.toString()??"",
              q['answers']?['self_score']?.toString()??"NA",
              q['read_only_answer']?.toString() ?? "",
              subQuestions
          );
        }).toList();

        if (subGroups.isNotEmpty) {
          viSubGroupList = subGroups.map<ViCompletedTaskSubGroupList>((sub) {
            String subGroupId = sub['id']?.toString() ?? "";
            String gId = sub['group_id']?.toString() ?? "";
            String subGroupName = sub['name']?.toString() ?? "";
            List<viCompletedQuestionsList> viQuestionList = buildQuestions(sub['questions'] ?? []);
            return ViCompletedTaskSubGroupList(subGroupId, gId, subGroupName, viQuestionList);
          }).toList();
        } else {
          List<viCompletedQuestionsList> viQuestionList = buildQuestions(group['questions'] ?? []);
          viSubGroupList.add(ViCompletedTaskSubGroupList("", groupId, "", viQuestionList));
        }

        return ViCompltedTaskQuestionSeries(groupId, groupType, groupName, viSubGroupList);
      }).toList();
      _expandedState = List.filled(questionList.length, false);

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      elevation: 1,
      color: AppTheme.questionCard,
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






