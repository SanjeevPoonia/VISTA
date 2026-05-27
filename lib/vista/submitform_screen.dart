import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/utils/audio_recording_dialog.dart';
import 'package:vista/views/audio_player_screen.dart';
import 'package:vista/views/video_player_screen.dart';
import 'package:vista/vista/MarkAttendanceScreen.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../utils/task_draftedquestion_series.dart';
import '../utils/task_questionlist_series.dart';
import '../utils/textfield_widget.dart';
import '../utils/validator.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';



class SubmitFormScreen extends StatefulWidget{
  String taskId;
  String subTaskId;
  SubmitFormScreen(this.taskId, this.subTaskId);
  _submitState createState()=> _submitState();
}
class _submitState extends State<SubmitFormScreen>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  List<TaskQuestionListSeries> questionList=[];
  String voiceNoteBaseUrl="";
  String imageInstructionUrl="";
  final List<String> statuses = ["Yes", "No"];

  String draftedImageBaseUrl="";
  String draftedBaseVoiceUrl="";
  String draftedVideoUrl="";
  String draftedEsignBaseUrl="";
  List<TaskDraftedQuestionList> draftedQuestionList=[];

  XFile? capturedImage;
  File? capturedFile;

  XFile? imageFile;
  File? file;

  int cameraSelectionPosition=0;
  String cameraSelectionQuestionId="";
  String selectedFileType="";

  int videoSelectionPosition=0;
  String videoSelectionQuestionId="";
  XFile? videoFile;
  File? vFile;

  int eSignSelectedPosition=0;
  String eSignSelectionQuestionId="";


  int audioSelectedPosition=0;
  String audioSelectionQuestionId="";
  String? _filePathRecording;

  String taskRemarkFromAdmin="";

  ValueNotifier<double> uploadProgressNotifier = ValueNotifier<double>(0.0);
  List<TextEditingController> controllersList = [];
  List<FocusNode>focusNodesList=[];

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: AppTheme.themeColor,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Task Details",
            style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              // ===== Audio Instructions Card =====
              if (voiceNoteBaseUrl.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AudioPlayerScreen(voiceNoteBaseUrl),
                        ),
                      );
                    },
                    leading: const Icon(Icons.record_voice_over_outlined,
                        color: AppTheme.orangeColor, size: 30),
                    title: const Text(
                      "Play Audio Instructions",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    trailing: const Icon(Icons.play_circle_fill,
                        color: AppTheme.themeColor, size: 28),
                  ),
                ),

              // ===== Image Instruction Preview =====
              if (imageInstructionUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageInstructionUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 12),

              // ===== Admin Remark Card =====
              if (taskRemarkFromAdmin.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  color: AppTheme.questionCard,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      taskRemarkFromAdmin,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              // ===== Questions List =====
              ListView.builder(
                itemCount: questionList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  int qNo=index+1;
                  String YesStr="Yes";
                  String NoStr="No";
                  if (controllersList.length <= index) {
                    controllersList.add(TextEditingController());
                  }
                  var nameController=controllersList[index];

                  String questionId=questionList[index].questionId;
                  String QuestionText="Q.$qNo)  ${questionList[index].question}";
                  String answerId=questionList[index].answerId;
                  String answerStr="";
                  if(answerId=="1"){
                    answerStr="Yes";
                  }else if(answerId=="0"){
                    answerStr="No";
                  }else if(answerId!="null"){
                    answerStr=questionList[index].answerId;
                    nameController.text=answerStr;
                  }

                  String questiontype=questionList[index].questionType;

                  int imageRequired=questionList[index].imageRequired;
                  int audioRequired=questionList[index].audioRequired;
                  int videoRequired=questionList[index].videoRequired;
                  int esignRequired=questionList[index].eSignRequired;
                  int isImageUploaded=questionList[index].isImageUploaded;
                  int isAudioUploaded=questionList[index].isAudioUploaded;
                  int isVideoUploaded=questionList[index].isVideoUploaded;
                  int isSignUploaded=questionList[index].isEsignUploaded;
                  String imageUrl=questionList[index].imageUrl;
                  String voiceUrl=questionList[index].voiceUrl;
                  String videoUrl=questionList[index].videoUrl;
                  String eSignUrl=questionList[index].eSignUrl;
                  print("Image Required $imageRequired");
                  print("Audio Required $audioRequired");
                  if (focusNodesList.length <= index) {
                    focusNodesList.add(FocusNode());
                  }
                  var focusNode = focusNodesList[index];
                  bool _isDonePressed = false;
                  // Add listener for focus changes (keyboard hide)
                  focusNode.addListener(() {
                    if (!focusNode.hasFocus) {
                      // Keyboard hidden
                      if (!_isDonePressed && nameController.text.isNotEmpty) {
                        _saveAnswerOnServer(index, nameController.text, questiontype);
                      }
                      _isDonePressed = false;
                    }
                  });


                  List<TaskSubQuestionListSeries> subQuestionList=questionList[index].subQuestionList;


                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Q${index + 1}. ${questionList[index].question}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.themeColor,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              Expanded(flex:2,
                                child:
                                questiontype=="yes_no"?
                                Column(
                                    children: statuses.map((status) {
                                      return RadioListTile<String>(
                                        title: Text(status),
                                        value: status,
                                        groupValue: answerStr, // Can be null
                                        onChanged: (String? value) {
                                          setState(() {

                                          });
                                          _saveAnswerOnServer(index, value!,questiontype);
                                        },
                                      );
                                    }).toList()
                                ):
                                TextFormField(
                                  controller: nameController,
                                  focusNode: focusNode,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      borderSide: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFE4E4E4),

                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      borderSide: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFE4E4E4),

                                      ),
                                    ),


                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      borderSide: const BorderSide(
                                        width: 1,
                                        color: AppTheme.themeColor,

                                      ),
                                    ),
                                    filled: true,
                                    hintStyle: const TextStyle(color: Color(0xFF9D9CA0),fontSize: 13),
                                    hintText: "Enter Remark",
                                    fillColor: Colors.white,
                                  ),
                                  onFieldSubmitted: (value) async {
                                    setState(() {

                                    });
                                    if(value.isNotEmpty) {
                                      _isDonePressed = true;
                                      _saveAnswerOnServer(
                                          index, value, questiontype);
                                    }
                                  },
                                ),
                              ),




                            ],
                          ),
                          const SizedBox(height: 10,),
                          Wrap(
                            spacing: 15,
                            runSpacing: 10,
                            children: [
                              if (imageRequired == 1)
                                _buildActionButton(
                                  icon: Icons.camera_alt,
                                  color: AppTheme.baseBlueStart,
                                  label: "Photo",
                                  onTap: () {
                                    cameraSelectionQuestionId = questionId;
                                    cameraSelectionPosition = index;
                                    selectedFileType = "1";
                                    prepairCamera();
                                  },
                                ),
                              if (audioRequired == 1)
                                _buildActionButton(
                                  icon: Icons.mic,
                                  color: AppTheme.orangeColor,
                                  label: "Audio",
                                  onTap: () async {
                                    audioSelectionQuestionId = questionId;
                                    audioSelectedPosition = index;
                                    selectedFileType = "2";
                                    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
                                    String fileNameCustom = "${currentTimeMillis}Audio$questionId";
                                    _filePathRecording = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AudioRecordingDialog(fileNameCustom),
                                    );
                                    if (_filePathRecording != null &&
                                        _filePathRecording!.isNotEmpty) {
                                      uploadAudio();
                                    }
                                  },
                                ),
                              if (videoRequired == 1)
                                _buildActionButton(
                                  icon: Icons.videocam,
                                  color: AppTheme.baseBlueStart,
                                  label: "Video",
                                  onTap: () {
                                    videoSelectionQuestionId = questionId;
                                    videoSelectionPosition = index;
                                    selectedFileType = "3";
                                    videoRecorder(context);
                                  },
                                ),
                              if (esignRequired == 1)
                                _buildActionButton(
                                  icon: Icons.edit,
                                  color: AppTheme.orangeColor,
                                  label: "E-Sign",
                                  onTap: () {
                                    eSignSelectionQuestionId = questionId;
                                    eSignSelectedPosition = index;
                                    selectedFileType = "4";
                                    showEsignDialog(context);
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [

                              isImageUploaded==1?
                              Expanded(flex:1,child: Container(
                                height: 150,
                                width: double.infinity, // Optional: takes full width
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )):Container(),

                              SizedBox(width: 10,),
                              isSignUploaded==1?
                              Expanded(flex:1,child: Container(
                                height: 150,
                                width: double.infinity, // Optional: takes full width
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(eSignUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )):Container(),




                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              isAudioUploaded==1?
                              Expanded(flex:1,child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => AudioPlayerScreen(voiceUrl)));
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
                              isVideoUploaded==1?
                              Expanded(flex:1,child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => VideoPlayerScreen( videoUrl: videoUrl,)));
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
                              itemBuilder: (BuildContext subContext,int subIndex){
                                int subQNo=subIndex+1;
                                String subquestionId=subQuestionList[subIndex].subQuestionId;
                                String mainQuestionId=subQuestionList[subIndex].questionId;
                                String subQuText="Q.$qNo.$subQNo)  ${subQuestionList[subIndex].subQuestionText}";
                                String subAnswerStr=subQuestionList[subIndex].subAnswer;
                                var subQuestionController=TextEditingController();
                                subQuestionController.text=subAnswerStr;
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
                                        TextFormField(
                                          controller: subQuestionController,
                                          //focusNode: focusNode,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4.0),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFE4E4E4),

                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4.0),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFE4E4E4),

                                              ),
                                            ),


                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4.0),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: AppTheme.themeColor,

                                              ),
                                            ),
                                            filled: true,
                                            hintStyle: const TextStyle(color: Color(0xFF9D9CA0),fontSize: 13),
                                            hintText: "Enter Remark",
                                            fillColor: Colors.white,
                                          ),
                                          onFieldSubmitted: (value) async {
                                            setState(() {

                                            });
                                            if(value.isNotEmpty) {
                                              // _isDonePressed = true;
                                              _saveSubAnswerOnServer(index, subIndex, value);

                                            }
                                          },
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
                },
              ),

              const SizedBox(height: 20),

              // ===== Submit Button =====
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: AppTheme.baseOrange,
                  foregroundColor: Colors.white,
                  textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _submitBtnValidatorNew(),//_submitBtnValidator(),
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return SafeArea(
        child:
        Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar  (
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined, color: AppTheme.themeColor,size: 24,),
              onPressed: () => {
                Navigator.pop(context)
              },
            ),
            backgroundColor: AppTheme.at_details_header,
            title:  const Text(
              "Task Details",
              style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            *//* actions: [
             IconButton(onPressed: (){
               _showAlertDialog();
             }, icon: const Icon(Icons.logout, color: AppTheme.task_Reopen_text,size: 35,))] ,*//*
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(15),
            child: ListView(
              children: [
                voiceNoteBaseUrl.isNotEmpty?
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => AudioPlayerScreen(voiceNoteBaseUrl)));
                  },
                  child: Card(
                    color: AppTheme.playInsructions,
                    elevation: 4,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.record_voice_over_outlined,size: 32,color: AppTheme.orangeColor,),
                          SizedBox(width: 10,),
                          Text("Play Audio Instructions",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black),)
                        ],
                      ),
                    ),
                  ),
                ):Container(),

                imageInstructionUrl.isNotEmpty?
                Container(
                  height: 150,
                  width: double.infinity, // Optional: takes full width
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageInstructionUrl),
                    ),
                  ),
                ):Container(),

                const SizedBox(height: 10,),
                taskRemarkFromAdmin.isNotEmpty?
                Card(
                  color: AppTheme.questionCard,
                  elevation: 4,
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child:  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(taskRemarkFromAdmin,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black),),
                  ),
                ):Container(),


                const SizedBox(height: 10,),
                ListView.builder(
                    itemCount: questionList.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context,int index){
                      int qNo=index+1;
                      String YesStr="Yes";
                      String NoStr="No";
                      if (controllersList.length <= index) {
                        controllersList.add(TextEditingController());
                      }
                      var nameController=controllersList[index];

                      String questionId=questionList[index].questionId;
                      String QuestionText="Q.$qNo)  ${questionList[index].question}";
                      String answerId=questionList[index].answerId;
                      String answerStr="";
                      if(answerId=="1"){
                        answerStr="Yes";
                      }else if(answerId=="0"){
                        answerStr="No";
                      }else if(answerId!="null"){
                        answerStr=questionList[index].answerId;
                        nameController.text=answerStr;
                      }

                      String questiontype=questionList[index].questionType;

                      int imageRequired=questionList[index].imageRequired;
                      int audioRequired=questionList[index].audioRequired;
                      int videoRequired=questionList[index].videoRequired;
                      int esignRequired=questionList[index].eSignRequired;
                      int isImageUploaded=questionList[index].isImageUploaded;
                      int isAudioUploaded=questionList[index].isAudioUploaded;
                      int isVideoUploaded=questionList[index].isVideoUploaded;
                      int isSignUploaded=questionList[index].isEsignUploaded;
                      String imageUrl=questionList[index].imageUrl;
                      String voiceUrl=questionList[index].voiceUrl;
                      String videoUrl=questionList[index].videoUrl;
                      String eSignUrl=questionList[index].eSignUrl;
                      print("Image Required $imageRequired");
                      print("Audio Required $audioRequired");
                      if (focusNodesList.length <= index) {
                        focusNodesList.add(FocusNode());
                      }
                      var focusNode = focusNodesList[index];
                      bool _isDonePressed = false;
                      // Add listener for focus changes (keyboard hide)
                      focusNode.addListener(() {
                        if (!focusNode.hasFocus) {
                          // Keyboard hidden
                          if (!_isDonePressed && nameController.text.isNotEmpty) {
                            _saveAnswerOnServer(index, nameController.text, questiontype);
                          }
                          _isDonePressed = false;
                        }
                      });


                      List<TaskSubQuestionListSeries> subQuestionList=questionList[index].subQuestionList;


                      return Card(
                        color: AppTheme.questionCard,
                        elevation: 4,
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(QuestionText,style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.themeColor
                              ),),
                              const SizedBox(height: 5,),
                              Row(
                                children: [
                                  Expanded(flex:1,
                                      child:
                                          questiontype=="yes_no"?
                                          Column(
                                          children: statuses.map((status) {
                                            return RadioListTile<String>(
                                              title: Text(status),
                                              value: status,
                                              groupValue: answerStr, // Can be null
                                              onChanged: (String? value) {
                                                setState(() {

                                                });
                                                _saveAnswerOnServer(index, value!,questiontype);
                                              },
                                            );
                                          }).toList()
                                      ):
                                          TextFormField(
                                            controller: nameController,
                                            focusNode: focusNode,
                                            textInputAction: TextInputAction.done,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE4E4E4),

                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE4E4E4),

                                                  ),
                                                ),


                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    color: AppTheme.themeColor,

                                                  ),
                                                ),
                                                filled: true,
                                                hintStyle: const TextStyle(color: Color(0xFF9D9CA0),fontSize: 13),
                                                hintText: "Enter Remark",
                                                fillColor: Colors.white,
                                              ),
                                            onFieldSubmitted: (value) async {
                                              setState(() {

                                              });
                                              if(value.isNotEmpty) {
                                                _isDonePressed = true;
                                                _saveAnswerOnServer(
                                                    index, value, questiontype);
                                              }
                                            },
                                          ),
                                  ),
                                  imageRequired==1?
                                  IconButton(
                                    icon: Icon(Icons.camera_alt),
                                    color: AppTheme.orangeColor,
                                    iconSize: 28.0,
                                    tooltip: 'Camera',
                                    onPressed: () {

                                      cameraSelectionQuestionId=questionId;
                                      cameraSelectionPosition=index;
                                      selectedFileType="1";

                                      print("Camera button tapped");
                                      prepairCamera();

                                    },
                                  ):Container(),
                                  const SizedBox(width: 5,),
                                  audioRequired==1?
                                  IconButton(
                                    icon: Icon(Icons.mic),
                                    color: AppTheme.orangeColor,
                                    iconSize: 28.0,
                                    tooltip: 'Record Audio',
                                    onPressed: () async{
                                      print("Record button tapped");
                                      audioSelectionQuestionId=questionId;
                                      audioSelectedPosition=index;
                                      selectedFileType="2";
                                      int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
                                      String fileNameCustom="${currentTimeMillis}Audio$questionId";
                                      _filePathRecording= await showDialog<String>(
                                        context: context,
                                        builder: (context)=>AudioRecordingDialog(fileNameCustom),
                                      );
                                      if (_filePathRecording != null) {
                                        if(_filePathRecording!.isNotEmpty){
                                          print('Recorded file path: $_filePathRecording');
                                          uploadAudio();
                                        }
                                        // You can now use this path, e.g., save, upload, or play it.
                                      }
                                    },
                                  ):Container(),
                                  const SizedBox(width: 5,),
                                  videoRequired==1?
                                  IconButton(
                                    icon: Icon(Icons.videocam),
                                    color: AppTheme.orangeColor,
                                    iconSize: 28.0,
                                    tooltip: 'Record Video',
                                    onPressed: () async{
                                      videoSelectionQuestionId=questionId;
                                      videoSelectionPosition=index;
                                      selectedFileType="3";
                                      print("Video button tapped");
                                      videoRecorder(context);
                                    },
                                  ):Container(),
                                  const SizedBox(width: 5,),
                                  esignRequired==1?
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: AppTheme.orangeColor,
                                    iconSize: 28.0,
                                    tooltip: 'E-Sign',
                                    onPressed: () async{
                                      eSignSelectionQuestionId=questionId;
                                      eSignSelectedPosition=index;
                                      selectedFileType="4";
                                      print("eSign button tapped");
                                      showEsignDialog(context);
                                    },
                                  ):Container(),

                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [

                                  isImageUploaded==1?
                                  Expanded(flex:1,child: Container(
                                    height: 150,
                                    width: double.infinity, // Optional: takes full width
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )):Container(),

                                  SizedBox(width: 10,),
                                  isSignUploaded==1?
                                  Expanded(flex:1,child: Container(
                                    height: 150,
                                    width: double.infinity, // Optional: takes full width
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(eSignUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )):Container(),




                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  isAudioUploaded==1?
                                  Expanded(flex:1,child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (BuildContext context) => AudioPlayerScreen(voiceUrl)));
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
                                  isVideoUploaded==1?
                                  Expanded(flex:1,child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (BuildContext context) => VideoPlayerScreen( videoUrl: videoUrl,)));
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
                                      itemBuilder: (BuildContext subContext,int subIndex){
                                        int subQNo=subIndex+1;
                                        String subquestionId=subQuestionList[subIndex].subQuestionId;
                                        String mainQuestionId=subQuestionList[subIndex].questionId;
                                        String subQuText="Q.$qNo.$subQNo)  ${subQuestionList[subIndex].subQuestionText}";
                                        String subAnswerStr=subQuestionList[subIndex].subAnswer;
                                        var subQuestionController=TextEditingController();
                                        subQuestionController.text=subAnswerStr;
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
                                            TextFormField(
                                              controller: subQuestionController,
                                              //focusNode: focusNode,
                                              textInputAction: TextInputAction.done,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE4E4E4),

                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE4E4E4),

                                                  ),
                                                ),


                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    color: AppTheme.themeColor,

                                                  ),
                                                ),
                                                filled: true,
                                                hintStyle: const TextStyle(color: Color(0xFF9D9CA0),fontSize: 13),
                                                hintText: "Enter Remark",
                                                fillColor: Colors.white,
                                              ),
                                              onFieldSubmitted: (value) async {
                                                setState(() {

                                                });
                                                if(value.isNotEmpty) {
                                                 // _isDonePressed = true;
                                                  _saveSubAnswerOnServer(index, subIndex, value);

                                                }
                                              },
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
                const SizedBox(height: 10,),
                InkWell(
                  onTap: (){
                    _submitBtnValidator();
                  },
                  child: Container(
                    height: 58,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    // padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [AppTheme.baseOrangeStart, AppTheme.baseOrange],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }*/
  Widget _buildVerticalActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
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
      "task_id": widget.taskId,
      "sub_task_id": widget.subTaskId,

    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get_task_questions', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      questionList.clear();
      if(responseJSON['audioInstruction']!=null){
        voiceNoteBaseUrl=responseJSON['audioInstruction'].toString();
      }
      if(responseJSON['imageInstruction']!=null){
        imageInstructionUrl=responseJSON['imageInstruction'].toString();
      }

      if(responseJSON['remarkInstruction']!=null){
        taskRemarkFromAdmin=responseJSON['remarkInstruction'].toString();
      }

      List<dynamic> tempList=responseJSON['taskQuestions'];
      for(int i=0;i<tempList.length;i++){
        String id=tempList[i]['id'].toString();
        String area_id=tempList[i]['area_id'].toString();
        String sub_area_id=tempList[i]['sub_area_id'].toString();
        String task_id=tempList[i]['task_id'].toString();
        String question=tempList[i]['question'].toString();
        String after_before_image=tempList[i]['after_before_image'].toString();
        String voice_note=tempList[i]['voice_note'].toString();

        int image=tempList[i]['image'];
        int audio=tempList[i]['audio'];
        int videoRequired=0;
        int eSignRequired=0;

        String questionType="yes_no";

        if(tempList[i]['video']!=null){
          videoRequired=tempList[i]['video'];
        }
        if(tempList[i]['esign']!=null){
          eSignRequired=tempList[i]['esign'];
        }
        if(tempList[i]['type']!=null){
          questionType=tempList[i]['type'].toString();
        }
        List<TaskSubQuestionListSeries> subQuestionList=[];
        if(tempList[i]['sub_questions']!=null){
          List<dynamic>subList=tempList[i]['sub_questions'];
          for(int j=0;j<subList.length;j++){
            String subQuestionId=subList[j]['id']?.toString()??"";
            String taskId=subList[j]['task_id']?.toString()??"";
            String questionId=subList[j]['question_id']?.toString()??"";
            String subQuestionType=subList[j]['type']?.toString()??"";
            String subQuestionText=subList[j]['question']?.toString()??"";
            String subAnswer="";
            subQuestionList.add(TaskSubQuestionListSeries(subQuestionId, taskId, questionId, subQuestionType, subQuestionText, subAnswer));
          }

        }

        questionList.add(TaskQuestionListSeries(id,area_id,sub_area_id,task_id,question,after_before_image,voice_note,image,audio,"","",0,0,"","","",videoRequired,eSignRequired,questionType,0,0,"","",subQuestionList));
      }
      setState(() {

      });
      _getDrafted(context);
    }else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      MyUtils.logoutUser(context);
    }
    else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      questionList.clear();
      _finishScreen();
    }


  }
  _finishScreen(){
    Navigator.of(context).pop();
  }
  _saveSubAnswerOnServer(int index,int subIndex, String answer)async{
    String mainQuestionId=questionList[index].subQuestionList[subIndex].questionId;
    String subQuestionId=questionList[index].subQuestionList[subIndex].subQuestionId;
    questionList[index].subQuestionList[subIndex].subAnswer=answer;
    setState(() {

    });

    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "emp_id": sUserId,
      "task_id": widget.taskId,
      "sub_task_id": widget.subTaskId,
      "question_id": subQuestionId,
      "main_question_id":mainQuestionId,
      "answer": answer,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'save_answer_draft', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);
    }
    else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);

    }
    else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }



  }
  _saveAnswerOnServer(int index, String answer,String questiontype)async{
    String QuestionId=questionList[index].questionId.toString();
    String answerId="";
    if(questiontype=="yes_no"){
      if(answer=="Yes"){
        answerId="1";
      }else if(answer=="No"){
        answerId="0";
      }
    }else{
      answerId=answer;
    }

    questionList[index].answerId=answerId;
    setState(() {

    });

    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "emp_id": sUserId,
      "task_id": widget.taskId,
      "sub_task_id": widget.subTaskId,
      "question_id": QuestionId,
      "answer": answerId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'save_answer_draft', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      Toast.show(responseJSON["message"],
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
        backgroundColor: Colors.green);
    }
    else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);

    }
    else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }



  }
  _getDrafted(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "task_id": widget.taskId,
      "sub_task_id": widget.subTaskId,

    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'saved_draft', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      draftedQuestionList.clear();

      if(responseJSON['imageBaseUrl']!=null){
        draftedImageBaseUrl=responseJSON['imageBaseUrl'].toString();
      }
      if(responseJSON['voiceBaseUrl']!=null){
        draftedBaseVoiceUrl=responseJSON['voiceBaseUrl'].toString();
      }
      if(responseJSON['videoBaseUrl']!=null){
        draftedVideoUrl=responseJSON['videoBaseUrl'].toString();
      }
      if(responseJSON['esignBaseUrl']!=null){
        draftedEsignBaseUrl=responseJSON['esignBaseUrl'].toString();
      }
      List<dynamic> tempList=responseJSON['savedAnswer'];
      for(int i=0;i<tempList.length;i++){
        String id=tempList[i]['id'].toString();
        String task_id=tempList[i]['task_id'].toString();
        String sub_task_id=tempList[i]['sub_task_id'].toString();
        String question_id=tempList[i]['question_id'].toString();
        String emp_id=tempList[i]['emp_id'].toString();
        String answer=tempList[i]['answer'].toString();
        String image=tempList[i]['image'].toString();
        String voice=tempList[i]['voice'].toString();
        String video=tempList[i]['video']?.toString() ?? "";
        String eSign=tempList[i]['esign']?.toString() ?? "";
        draftedQuestionList.add(TaskDraftedQuestionList(id, task_id, sub_task_id, question_id, emp_id, answer, image, voice,video,eSign));
      }
      _setDraftedQuestion();

    }else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      _finishScreen();
    }
    else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }


  }
  _setDraftedQuestion(){
    for(int i=0;i<draftedQuestionList.length;i++){
      String qId=draftedQuestionList[i].QuestionId;
      String ansId=draftedQuestionList[i].Answer;
      String img=draftedQuestionList[i].ImageUrl;
      String voice=draftedQuestionList[i].AudioUrl;
      String video=draftedQuestionList[i].VideoUrl;
      String esign=draftedQuestionList[i].EsignUrl;
      String tId=draftedQuestionList[i].TaskId;
      String sId=draftedQuestionList[i].SubtaskId;

      for(int j=0;j<questionList.length;j++){
        String queId=questionList[j].questionId;
        if(queId==qId && tId==widget.taskId && sId==widget.subTaskId){
          questionList[j].answerId=ansId;

          if(img.isNotEmpty && img!="null"){
            questionList[j].isImageUploaded=1;
            questionList[j].imageUrl="$draftedImageBaseUrl/$img";
          }
          if(voice.isNotEmpty && voice!="null"){
            questionList[j].isAudioUploaded=1;
            questionList[j].voiceUrl="$draftedBaseVoiceUrl/$voice";
          }
          if(video.isNotEmpty && video!="null"){
            questionList[j].isVideoUploaded=1;
            questionList[j].videoUrl="$draftedVideoUrl/$video";
          }
          if(esign.isNotEmpty && esign!="null"){
            questionList[j].isEsignUploaded=1;
            questionList[j].eSignUrl="$draftedEsignBaseUrl/$esign";
          }
        }
      }
    }
    setState(() {

    });

  }
  Future<void> prepairCamera() async{

    // imageSelector(context);
    if(Platform.isAndroid){
      final imageData=await Navigator.push(context,MaterialPageRoute(builder: (context)=>MarkAttendanceScreen(0)));
      if(imageData!=null)
      {
        capturedImage=imageData;
        capturedFile=File(capturedImage!.path);
        _showCameraImageDialog();

      }else{
        Toast.show("Unable to capture Image. Please try Again...",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    }else{
      imageSelector(context);
    }


  }
  videoRecorder(BuildContext context) async{
    videoFile = await ImagePicker().pickVideo(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);

    if(videoFile!=null){
      vFile=File(videoFile!.path);
      final imageFiles = videoFile;
      if (imageFiles != null) {
        print("You selected  video : " + imageFiles.path.toString());
        setState(() {
          debugPrint("SELECTED video PICK   $imageFiles");
        });
        submitVideo();
      } else {
        print("You have not taken image");
      }

    }else{
      Toast.show("Unable to capture Video. Please try Again...",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }

  }
  imageSelector(BuildContext context) async{

    imageFile = await ImagePicker().pickImage(source: ImageSource.camera,
        imageQuality: 60,preferredCameraDevice: CameraDevice.front
    );

    if(imageFile!=null){
      file=File(imageFile!.path);

      final imageFiles = imageFile;
      if (imageFiles != null) {
        print("You selected  image : " + imageFiles.path.toString());
        setState(() {
          debugPrint("SELECTED IMAGE PICK   $imageFiles");
        });
        _showImageDialog();
      } else {
        print("You have not taken image");
      }
    }
    else{
      Toast.show("Unable to capture Image. Please try Again...",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }


  }
  submitVideo() async{
    uploadProgressNotifier.value = 0.0;
    showUploadDialog(context,"Video");


    String fileName = vFile!.path.split("/").last;
    String filePath = vFile!.path;
    String extension = fileName.split('.').last;

    FormData formData = FormData.fromMap({
      "auth_key":sRemeberToken,
      "task_id":widget.taskId,
      "sub_task_id":widget.subTaskId,
      "question_id":videoSelectionQuestionId,
      "emp_id":sUserId,
      "file_type":selectedFileType,
      "Orignal_Name":fileName,
      "ext":extension,
      "file": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl="${baseUrl}save_draft";
    print(apiUrl);
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    try {
      var response = await dio.post(
          apiUrl, data: formData,
          onSendProgress: (int sent, int total) {
          double percentage = (sent / total) * 100;
          uploadProgressNotifier.value = percentage;
        },

      );
      print(response.data);
      Navigator.pop(context);
      var data=jsonDecode(response.data);
      if (response.statusCode == 200) {
        int status=data['status'];
        String message=data['message'].toString();
        Toast.show(message,
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.green);
        if(status==1){
          String image = data['image_url']?.toString() ?? "";
          String voice = data['voice_url']?.toString() ?? "";
          String video = data['video_url']?.toString() ?? "";
          String fileType = data['file_type']?.toString() ?? selectedFileType;
          if (fileType == "1") {
            questionList[cameraSelectionPosition].isImageUploaded = 1;
            questionList[cameraSelectionPosition].imageUrl = image;
          } else if (fileType == "2") {
            questionList[audioSelectedPosition].isAudioUploaded = 1;
            questionList[audioSelectedPosition].voiceUrl = voice;
          } else if (fileType == "3") {
            questionList[videoSelectionPosition].isVideoUploaded = 1;
            questionList[videoSelectionPosition].videoUrl = video;
          }
          setState(() {});
        }

      }else{
        Toast.show(data['message'],
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    }on DioError catch(e){
      print(e);
      print(e.response.toString());
      Navigator.pop(context);
      Toast.show(e.toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }



  }
  submitReimbursmentWithImage(String from) async{
    uploadProgressNotifier.value = 0.0;
    showUploadDialog(context,"Image");
    String fileName="";
    String filePath="";
    if(from=='camera'){
      fileName=capturedFile!.path.split("/").last;
      filePath=capturedFile!.path;
    }else{
      fileName=file!.path.split("/").last;
      filePath=file!.path;
    }
    String extension = fileName.split('.').last;
    FormData formData = FormData.fromMap({
      "auth_key":sRemeberToken,
      "task_id":widget.taskId,
      "sub_task_id":widget.subTaskId,
      "question_id":cameraSelectionQuestionId,
      "emp_id":sUserId,
      "file_type":selectedFileType,
      "Orignal_Name":fileName,
      "ext":extension,
      "file": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl="${baseUrl}save_draft";
    print(apiUrl);
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    try {
      var response = await dio.post(
          apiUrl, data: formData,
        onSendProgress: (int sent, int total) {
          double percentage = (sent / total) * 100;
          uploadProgressNotifier.value = percentage;
        },

      );
      print(response.data);
      Navigator.pop(context);
      var data=jsonDecode(response.data);
      if (response.statusCode == 200) {


        int status=data['status'];
        String message=data['message'].toString();
        Toast.show(message,
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.green);

        if(status==1){

          String image="";
          if(data['image_url']!=null){
            image=data['image_url'].toString();
          }

          String voice="";
          if(data['voice_url']!=null){
            voice=data['voice_url'].toString();
          }

          String fileType=selectedFileType;
          if(data['file_type']!=null){
            fileType=data['file_type'].toString();
          }

          if(fileType=="1"){

            questionList[cameraSelectionPosition].isImageUploaded=1;
            questionList[cameraSelectionPosition].imageUrl=image;

          }else if(fileType=="2"){
            questionList[cameraSelectionPosition].isAudioUploaded=1;
            questionList[cameraSelectionPosition].voiceUrl=voice;
          }

          setState(() {

          });


        }

      }else{
        Toast.show(data['message'],
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    }on DioError catch(e){
      print(e);
      print(e.response.toString());
      Navigator.pop(context);
      Toast.show(e.toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }



  }
  _showCameraImageDialog(){

    showDialog(context: context, builder: (ctx)=>AlertDialog(
        title: const Text("Image",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 18),),
        content: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.rectangle,
            image: DecorationImage(
                image: FileImage(capturedFile!),
                fit: BoxFit.cover
            ),

          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: (){
                Navigator.of(ctx).pop();
                submitReimbursmentWithImage("camera");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.themeColor,
                ),
                height: 45,
                padding: const EdgeInsets.all(10),
                child: const Center(child: Text("Upload",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
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
        ]
    ));
  }
  _showImageDialog(){

    showDialog(context: context, builder: (ctx)=>AlertDialog(
        title: const Text("Image",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 18),),
        content: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.rectangle,
            image: DecorationImage(
                image: FileImage(file!),
                fit: BoxFit.cover
            ),

          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: (){
                Navigator.of(ctx).pop();
                submitReimbursmentWithImage("iOS");

              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.themeColor,
                ),
                height: 45,
                padding: const EdgeInsets.all(10),
                child: const Center(child: Text("Upload",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
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
        ]
    ));
  }
  void _showError(String msg) {
    Toast.show(
      msg,
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
      backgroundColor: Colors.red,
    );
  }
  _submitBtnValidatorNew() {
    bool validation = true;

    for (int i = 0; i < questionList.length; i++) {
      int qNo = i + 1;
      var q = questionList[i];

      //  Main Answer Validation
      if (q.answerId.isEmpty || q.answerId == "null") {
        _showError("Please Select the Answer of Q.No.:- $qNo");
        validation = false;
        break;
      }

      //  Common Requirement Checks
      final validations = [
        [q.imageRequired == 1 && q.isImageUploaded != 1, "Please upload the Image of Q.No.:- $qNo"],
        [q.audioRequired == 1 && q.isAudioUploaded != 1, "Please upload the Voice Recording of Q.No.:- $qNo"],
        [q.videoRequired == 1 && q.isVideoUploaded != 1, "Please upload the Video of Q.No.:- $qNo"],
        [q.eSignRequired == 1 && q.isEsignUploaded != 1, "Please upload the E-Sign of Q.No.:- $qNo"],
      ];

      for (var v in validations) {
        if (v[0] as bool) {
          _showError(v[1] as String);
          validation = false;
          break;
        }
      }
      if (!validation) break;

      //  Sub-Questions Validation
      for (int j = 0; j < q.subQuestionList.length; j++) {
        int subQNo = j + 1;
        var subQ = q.subQuestionList[j];

        if (subQ.subAnswer.isEmpty || subQ.subAnswer == "null") {
          _showError("Please Enter the Answer of Q.No.:- $qNo.$subQNo");
          validation = false;
          break;
        }
      }

      if (!validation) break;
    }


    if (validation) {
      var jsonArray=[];
      for(int i=0;i<questionList.length;i++){
        var q=questionList[i];
        var ans={
          "question_id":q.questionId,
          "answer":q.answerId
        };
        jsonArray.add(ans);
        List<TaskSubQuestionListSeries> subQList=q.subQuestionList;
        for(int j=0;j<subQList.length;j++){
          var subQ=subQList[j];
          var ans={
            "question_id":subQ.subQuestionId,
            "main_question_id":subQ.questionId,
            "answer":subQ.subAnswer
          };
          jsonArray.add(ans);
        }



      }

      var params = {
        "auth_key": sRemeberToken,
        "task_id": widget.taskId,
        "sub_task_id": widget.subTaskId,
        "emp_id": sUserId,
        "parameter": jsonArray,
      };

      _submitDraftedQuestion(params);
    }
  }
  _submitBtnValidator(){
      bool validation=false;
      for(int i=0;i<questionList.length;i++){
        int qNo=i+1;
        int isVideoRequired=questionList[i].videoRequired;
        int isEsignRequired=questionList[i].eSignRequired;
        int isImageRequired=questionList[i].imageRequired;
        int isImageUploaded=questionList[i].isImageUploaded;

        int isAudioRequired=questionList[i].audioRequired;
        int isAudioUploaded=questionList[i].isAudioUploaded;
        int isVideoUploaded=questionList[i].isVideoUploaded;
        int isEsignUploaded=questionList[i].isEsignUploaded;

        String answerStr=questionList[i].answerId;

        print("Qno $qNo Answer $answerStr   Image Required $isImageRequired   voice Required $isAudioRequired");

          if (answerStr.isNotEmpty && answerStr != "null") {
            if (isImageRequired == 1) {
              if (isImageUploaded == 1) {
                if (isAudioRequired == 1) {
                  if (isAudioUploaded == 1) {
                    validation = true;
                  } else {
                    Toast.show(
                        "Please upload the Voice Recording of Q.No.:- $qNo",
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom,
                        backgroundColor: Colors.red);
                    validation = false;
                    break;
                  }
                } else {
                  validation = true;
                }
              } else {
                Toast.show("Please upload the Image of Q.No.:- $qNo",
                    duration: Toast.lengthLong,
                    gravity: Toast.bottom,
                    backgroundColor: Colors.red);
                validation = false;
                break;
              }
            } else {
              if (isAudioRequired == 1) {
                if (isAudioUploaded == 1) {
                  validation = true;
                } else {
                  Toast.show(
                      "Please upload the Voice Recording of Q.No.:- $qNo",
                      duration: Toast.lengthLong,
                      gravity: Toast.bottom,
                      backgroundColor: Colors.red);
                  validation = false;
                  break;
                }
              } else {
                validation = true;
              }
            }
          }
          else {
            Toast.show("Please Select the Answer of Q.No.:- $qNo",
                duration: Toast.lengthLong,
                gravity: Toast.bottom,
                backgroundColor: Colors.red);
            validation = false;
            break;
          }
      }

      if(validation){
        var jsonArray=[];
        for(int i=0;i<questionList.length;i++){
          var ans={
            "question_id":questionList[i].questionId,
            "answer":questionList[i].answerId
          };
          jsonArray.add(ans);
        }
        var params={
          "auth_key":sRemeberToken,
          "task_id":widget.taskId,
          "sub_task_id":widget.subTaskId,
          "emp_id":sUserId,
          "parameter":jsonArray
        };

        _submitDraftedQuestion(params);

      }
  }
  _submitDraftedQuestion(var params)async{
    APIDialog.showAlertDialog(context, 'Please Wait...');
    print(params);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'submit_task', params, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);
      _finishScreen();
    }
    else {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }



  }
  uploadAudio() async{
    uploadProgressNotifier.value = 0.0;
    showUploadDialog(context,"Audio");
    String fileName="";
    String filePath="";
    filePath=_filePathRecording!;
    fileName=filePath.split("/").last;
    String extension = fileName.split('.').last;
    FormData formData = FormData.fromMap({
      "auth_key":sRemeberToken,
      "task_id":widget.taskId,
      "sub_task_id":widget.subTaskId,
      "question_id":audioSelectionQuestionId,
      "emp_id":sUserId,
      "file_type":selectedFileType,
      "Orignal_Name":fileName,
      "ext":extension,
      "file": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl="${baseUrl}save_draft";
    print(apiUrl);
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    try {
      var response = await dio.post(
          apiUrl, data: formData,
        onSendProgress: (int sent, int total) {
          double percentage = (sent / total) * 100;
          uploadProgressNotifier.value = percentage;
        },
      );
      print(response.data);
      Navigator.pop(context);
      var data=jsonDecode(response.data);
      if (response.statusCode == 200) {


        int status=data['status'];
        String message=data['message'].toString();
        Toast.show(message,
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.green);

        if(status==1){

          String image="";
          if(data['image_url']!=null){
            image=data['image_url'].toString();
          }

          String voice="";
          if(data['voice_url']!=null){
            voice=data['voice_url'].toString();
          }

          String fileType=selectedFileType;
          if(data['file_type']!=null){
            fileType=data['file_type'].toString();
          }

          if(fileType=="1"){

            questionList[cameraSelectionPosition].isImageUploaded=1;
            questionList[cameraSelectionPosition].imageUrl=image;

          }else if(fileType=="2"){
            questionList[audioSelectedPosition].isAudioUploaded=1;
            questionList[audioSelectedPosition].voiceUrl=voice;
          }

          setState(() {

          });


        }

      }else{
        Toast.show(data['message'],
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    }on DioError catch(e){
      print(e);
      print(e.response.toString());
      Navigator.pop(context);
      Toast.show(e.toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }



  }
  void showUploadDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.cloud_upload_rounded, color: AppTheme.orangeColor),
              SizedBox(width: 8),
              Text(
                "Uploading $title...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.themeColor,
                ),
              ),
            ],
          ),
          content: ValueListenableBuilder<double>(
            valueListenable: uploadProgressNotifier,
            builder: (context, value, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar with gradient feel
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 12,
                      backgroundColor: AppTheme.themeColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.orangeColor),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Percentage text
                  Text(
                    "${value.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.orangeColor,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Sub text
                  Text(
                    "Please wait while your file is being uploaded...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
  void showEsignDialog(BuildContext context) {
    SignatureController _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: AppTheme.orangeColor,
      exportBackgroundColor: Colors.white,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit, color: AppTheme.orangeColor),
              SizedBox(width: 8),
              Text(
                "E-Sign",
                style: TextStyle(color: AppTheme.themeColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.maxFinite,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.themeColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _controller.clear(),
                    icon: Icon(Icons.refresh, color: AppTheme.themeColor),
                    label: Text("Clear", style: TextStyle(color: AppTheme.themeColor)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      if (_controller.isNotEmpty) {
                        Uint8List? data = await _controller.toPngBytes();
                        if (data != null) {
                          Navigator.pop(context); // close dialog
                          await uploadSignatureToServer(data);
                        }
                      }
                    },
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
  Future<void> uploadSignatureToServer(Uint8List imageBytes) async {
    uploadProgressNotifier.value = 0.0;
    showUploadDialog(context, "Sign");
    String fileName = "${DateTime
        .now()
        .millisecondsSinceEpoch}.png";


    FormData formData = FormData.fromMap({
      "auth_key": sRemeberToken,
      "task_id": widget.taskId,
      "sub_task_id": widget.subTaskId,
      "question_id": eSignSelectionQuestionId,
      "emp_id": sUserId,
      "file_type": selectedFileType,
      "Orignal_Name": fileName,
      "ext": "png",
      "file": MultipartFile.fromBytes(
        imageBytes,
        filename: fileName,
        contentType: DioMediaType("image", "png"),
      ),
    });

    String apiUrl = "${baseUrl}save_draft";
    print(apiUrl);
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    try {
      var response = await dio.post(
        apiUrl, data: formData,
        onSendProgress: (int sent, int total) {
          double percentage = (sent / total) * 100;
          uploadProgressNotifier.value = percentage;
        },
      );
      print(response.data);
      Navigator.pop(context);
      var data = jsonDecode(response.data);
      if (response.statusCode == 200) {
        int status = data['status'];
        String message = data['message'].toString();
        Toast.show(message,
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.green);
        if(status==1){
          String image = data['image_url']?.toString() ?? "";
          String voice = data['voice_url']?.toString() ?? "";
          String video = data['video_url']?.toString() ?? "";
          String esign = data['esign_url']?.toString() ?? "";
          String fileType = data['file_type']?.toString() ?? selectedFileType;
          if (fileType == "1") {
            questionList[cameraSelectionPosition].isImageUploaded = 1;
            questionList[cameraSelectionPosition].imageUrl = image;
          } else if (fileType == "2") {
            questionList[audioSelectedPosition].isAudioUploaded = 1;
            questionList[audioSelectedPosition].voiceUrl = voice;
          } else if (fileType == "3") {
            questionList[videoSelectionPosition].isVideoUploaded = 1;
            questionList[videoSelectionPosition].videoUrl = video;
          }else if (fileType == "4") {
            questionList[eSignSelectedPosition].isEsignUploaded = 1;
            questionList[eSignSelectedPosition].eSignUrl = esign;
          }
          setState(() {});
        }
      } else {
        Toast.show(data['message'],
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    } on DioError catch (e) {
      print(e);
      print(e.response.toString());
      Navigator.pop(context);
      Toast.show(e.toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }
  }
  @override
  void dispose() {
    for (var node in focusNodesList) {
      node.dispose();
    }
    for (var ctrl in controllersList) {
      ctrl.dispose();
    }
    super.dispose();
  }

}