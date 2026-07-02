import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/modules/main_editor/main_editor.dart';
import 'package:signature/signature.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/utils/vi_task_question_series.dart';
import 'package:vista/views/audio_player_screen.dart';
import 'package:vista/views/video_player_screen.dart';
import 'package:vista/vista/MarkAttendanceScreen.dart';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../network/loader.dart';
import '../utils/audio_recording_dialog.dart';
import '../utils/task_draftedquestion_series.dart';
import 'dart:io';
import '../utils/task_questionlist_series.dart';
import 'fancy_toggal_vi.dart';
import 'package:flutter/services.dart';


class SubmitFormVIScreen extends StatefulWidget{
  String taskId;
  String subTaskId;
  SubmitFormVIScreen(this.taskId, this.subTaskId);
  _submitFormState createState()=>_submitFormState();
}
class _submitFormState extends State<SubmitFormVIScreen>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  List<ViTaskQuestionSeries> questionList=[];
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
  int cameraGroupPosition=0;
  int cameraSubGroupPosition=0;
  int cameraSelectionPosition=0;
  String cameraSelectionQuestionId="";
  String selectedFileType="";
  int videoGroupPosition=0;
  int videoSubGroupPosition=0;
  int videoSelectionPosition=0;
  String videoSelectionQuestionId="";
  XFile? videoFile;
  File? vFile;
  int eSignGroupPosition=0;
  int eSignSubGroupPosition=0;
  int eSignSelectedPosition=0;
  String eSignSelectionQuestionId="";
  int audioGroupPosition=0;
  int audioSubGroupPosition=0;
  int audioSelectedPosition=0;
  String audioSelectionQuestionId="";
  String? _filePathRecording;
  String taskRemarkFromAdmin="";
  String referenceImageBaseUrl="";
  ValueNotifier<double> uploadProgressNotifier = ValueNotifier<double>(0.0);
  Map<String, TextEditingController> controllersMap = {};
  Map<String, FocusNode> focusNodesMap = {};
  String latitudeStr="";
  String longitudeStr="";
  Position? _currentPosition;
  List<bool> _expandedState = [];
  Map<String, String> lastSavedSubAnswers = {};
  Map<String, FocusNode> mainFocusNodesMap = {};
  Map<String, String> lastSavedMainAnswers = {};
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

  Widget _buildHintActionButton({
    required IconData icon,
    required Color color,
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
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ],
    );
  }
  Future<void> _getCurrentPosition() async {
    FocusScope.of(context).unfocus();
    APIDialog.showAlertDialog(context, "Fetching Location..");
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      Navigator.of(context).pop();
      _showPermissionCustomDialog();
      return;
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      latitudeStr=_currentPosition!.latitude.toString();
      longitudeStr=_currentPosition!.longitude.toString();
      print(
          "Location  latitude : ${_currentPosition!.latitude} Longitude : ${_currentPosition!.longitude}");
      Navigator.pop(context);
    }).catchError((e) {
      latitudeStr="0.0";
      longitudeStr="0.0";
      debugPrint(e);
      Toast.show(
          "Error!!! Can't get Location. Please Ensure your location services are enabled",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      Navigator.pop(context);
    });
  }
  _showPermissionCustomDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Location permission is required. Please allow the location service",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "1.) Location Permission",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "2.) Enable GPS Services",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          //call attendance punch in or out
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.themeColor,
                          ),
                          height: 45,
                          padding: const EdgeInsets.all(10),
                          child: const Center(
                            child: Text(
                              "OK",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Toast.show("Location services are disabled. Please enable the services.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      /*ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));*/
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Toast.show("Location permissions are denied.",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
        /*ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));*/
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Toast.show(
          "Location permissions are permanently denied, we cannot request permissions.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      /*ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));*/
      return false;
    }

    return true;
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
    _getCurrentPosition();
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
    var response = await helper.postAPI(baseUrl,'vi_get_task_questions', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      questionList.clear();
      voiceNoteBaseUrl=responseJSON['audioInstruction']?.toString()??"";
      voiceNoteBaseUrl=responseJSON['audioInstruction']?.toString()??"";
      imageInstructionUrl=responseJSON['imageInstruction']?.toString()??"";
      taskRemarkFromAdmin=responseJSON['remarkInstruction']?.toString()??"";
      referenceImageBaseUrl=responseJSON['refrenceImageBaseUrl']?.toString()??"";

      List<dynamic> groupList = responseJSON['groups'] ?? [];
      questionList = groupList.map((group) {
        String groupId = group['id']?.toString() ?? "";
        String groupType = group['group_type']?.toString() ?? "";
        String groupName = group['name']?.toString() ?? "";
        List<dynamic> subGroups = group['sub_groups'] ?? [];
        List<ViTaskSubGroupList> viSubGroupList = [];

        // Helper to build questions list from a given list
        List<viQuestionsList> buildQuestions(List<dynamic> questions) => questions.map((q) {
          List<viSubQuestionListSeries> subQuestions = (q['sub_questions'] ?? []).map<viSubQuestionListSeries>((sq) {
            return viSubQuestionListSeries(
                sq['id']?.toString() ?? "",
                sq['task_id']?.toString() ?? "",
                sq['question_id']?.toString() ?? "",
                sq['type']?.toString() ?? "",
                sq['question']?.toString() ?? "",
                ""
            );
          }).toList();
          return viQuestionsList(
              q['id']?.toString() ?? "",
              q['group_id']?.toString() ?? "",
              q['sub_group_id']?.toString() ?? "",
              q['task_id']?.toString() ?? "",
              q['type']?.toString() ?? "",
              q['question']?.toString() ?? "",
              q['score']?.toString() ?? "",
              q['image'] ?? 0,
              q['audio'] ?? 0,
              q['video'] ?? 0,
              q['eSign'] ?? 0,
              q['after_before_image']?.toString() ?? "",
              q['voice_note']?.toString() ?? "",
              q['created_by']?.toString() ?? "",
              q['area_id']?.toString() ?? "",
              q['sub_area_id']?.toString() ?? "",
              q['norms']?.toString() ?? "",
              q['reference_image']?.toString() ?? "",
              q['min_photo'] ?? 0,
              q['max_photo'] ?? 0,
              "", "", 0, 0, "", "", "", 0, 0, "", "",
              subQuestions,q['read_only_answer']?.toString()??""
          );
        }).toList();

        if (subGroups.isNotEmpty) {
          viSubGroupList = subGroups.map<ViTaskSubGroupList>((sub) {
            String subGroupId = sub['id']?.toString() ?? "";
            String gId = sub['group_id']?.toString() ?? "";
            String subGroupName = sub['name']?.toString() ?? "";
            List<viQuestionsList> viQuestionList = buildQuestions(sub['questions'] ?? []);
            return ViTaskSubGroupList(subGroupId, gId, subGroupName, viQuestionList);
          }).toList();
        } else {
          List<viQuestionsList> viQuestionList = buildQuestions(group['questions'] ?? []);
          viSubGroupList.add(ViTaskSubGroupList("", groupId, "", viQuestionList));
        }

        return ViTaskQuestionSeries(groupId, groupType, groupName, viSubGroupList);
      }).toList();
      _expandedState = List.filled(questionList.length, false);

      setState(() {

      });
      _getDrafted(context);
    }else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"].toString(),
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
    var response = await helper.postAPI(baseUrl,'vi_saved_draft', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      draftedQuestionList.clear();
      draftedImageBaseUrl=responseJSON['imageBaseUrl']?.toString()??"";
      draftedBaseVoiceUrl=responseJSON['voiceBaseUrl']?.toString()??"";
      draftedVideoUrl=responseJSON['videoBaseUrl']?.toString()??"";
      draftedEsignBaseUrl=responseJSON['esignBaseUrl']?.toString()??"";
      List<dynamic> tempList=responseJSON['savedAnswer'];
      for(int i=0;i<tempList.length;i++){
        String id=tempList[i]['id'].toString();
        String task_id=tempList[i]['task_id'].toString();
        String sub_task_id=tempList[i]['sub_task_id'].toString();
        String question_id=tempList[i]['question_id'].toString();
        String emp_id=tempList[i]['emp_id'].toString();
        String answer=tempList[i]['answer'].toString();
        String image=tempList[i]['image_url'].toString();
        String voice=tempList[i]['voice'].toString();
        String video=tempList[i]['video']?.toString() ?? "";
        String eSign=tempList[i]['esign']?.toString() ?? "";
        draftedQuestionList.add(TaskDraftedQuestionList(id, task_id, sub_task_id, question_id, emp_id, answer, image, voice,video,eSign));
      }
      _setDraftedQuestion();
      sortGroupsByCompletion();
      setState(() {});

    }else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      _finishScreen();
    }
    else {
      /*Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);*/
      APIDialog.showErrorDialog(responseJSON["message"]?.toString()??"Something went wrong. Please try again", context);
    }


  }
  _setDraftedQuestion(){
    for (var drafted in draftedQuestionList) {
      for (var group in questionList) {
        for (var subGroup in group.subGroupList) {
          for (var q in subGroup.questionList) {
            if (q.questionId == drafted.QuestionId &&
                drafted.TaskId == widget.taskId &&
                drafted.SubtaskId == widget.subTaskId) {

              q.answerId = drafted.Answer;

              void updateField(String value, void Function() onUpdate) {
                if (value.isNotEmpty && value != "null") onUpdate();
              }

              updateField(drafted.ImageUrl, () {
                q.isImageUploaded = 1;
                q.imageUrl = drafted.ImageUrl;
                //q.imageUrl = "$draftedImageBaseUrl/${drafted.ImageUrl}";
              });

              updateField(drafted.AudioUrl, () {
                q.isAudioUploaded = 1;
                q.voiceUrl = "$draftedBaseVoiceUrl/${drafted.AudioUrl}";
              });

              updateField(drafted.VideoUrl, () {
                q.isVideoUploaded = 1;
                q.videoUrl = "$draftedVideoUrl/${drafted.VideoUrl}";
              });

              updateField(drafted.EsignUrl, () {
                q.isEsignUploaded = 1;
                q.eSignUrl = "$draftedEsignBaseUrl/${drafted.EsignUrl}";
              });
            }
          }
        }
      }
    }
    setState(() {

    });

  }
  _finishScreen(){
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          final focus = FocusManager.instance.primaryFocus;

          if (focus != null && focus.hasFocus) {
            focus.unfocus();
            return;
          }

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color(0xFFF47320), // notification area color
              statusBarIconBrightness: Brightness.light,   // Android icons
              statusBarBrightness: Brightness.light,      // iOS
            ),
            elevation: 0,
            backgroundColor: AppTheme.at_details_header,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Task Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

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
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 1,
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
                // ===== Group list =====
                ListView.builder(
                    itemCount: questionList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int groupIndex){
                      var groupData=questionList[groupIndex];
                      String groupId=groupData.groupId;
                      String groupType=groupData.groupType;
                      String groupName=groupData.groupName;
                      List<ViTaskSubGroupList> subGroupList=groupData.subGroupList;

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
                                /*for (int i = 0; i < _expandedState.length; i++) {
                              _expandedState[i] = false;
                            }*/
                                _expandedState[groupIndex] = expanded;
                                //_expandedState[groupIndex] = expanded;
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
                                    List<viQuestionsList> showQuestionList=subGroup.questionList;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
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




                                                  controllersMap.putIfAbsent(questionId, () => TextEditingController());
                                                  var nameController = controllersMap[questionId]!;

                                                  String answerId=question.answerId;
                                                  String answerStr="";
                                                  if(answerId=="1"){
                                                    answerStr="Yes";
                                                  }
                                                  else if(answerId=="0"){
                                                    answerStr="No";
                                                  }
                                                  else if(answerId!="null" && answerId.isNotEmpty){
                                                    answerStr=question.answerId;
                                                    //nameController.text=answerStr;
                                                    if (nameController.text.isEmpty) {
                                                      nameController.text = answerStr;
                                                    }

                                                  }

                                                  String questiontype=question.type;
                                                  int imageRequired=question.imageRequired;
                                                  int audioRequired=question.audioRequired;
                                                  int videoRequired=question.videoRequired;
                                                  int esignRequired=question.eSignRequired;
                                                  int isImageUploaded=question.isImageUploaded;
                                                  int isAudioUploaded=question.isAudioUploaded;
                                                  int isVideoUploaded=question.isVideoUploaded;
                                                  int isSignUploaded=question.isEsignUploaded;
                                                  int minImageRequired=question.minPhoto;
                                                  int maxImageRequired=question.maxPhoto;
                                                  String imageUrl=question.imageUrl;
                                                  String voiceUrl=question.voiceUrl;
                                                  String videoUrl=question.videoUrl;
                                                  String eSignUrl=question.eSignUrl;
                                                  print("Image Required $imageRequired");
                                                  print("Audio Required $audioRequired");

                                                  List<viSubQuestionListSeries> subQuestionList=question.subQuestionList;

                                                  String norms=question.norms;
                                                  String referenceImage=question.referenceImage;
                                                  String referenceImageUrl="$referenceImageBaseUrl/$referenceImage";

                                                  List<String> uploadedImageList = [];

                                                  if (imageUrl != "null" && imageUrl.isNotEmpty) {
                                                    uploadedImageList = imageUrl.split(",");
                                                  }
                                                  bool showCameraIcon = false;

                                                  if (questiontype == "photo" && maxImageRequired > uploadedImageList.length) {
                                                    showCameraIcon = true;
                                                  } else if (questiontype == "yes_no" && imageRequired == 1 && uploadedImageList.isEmpty) {
                                                    showCameraIcon = true;
                                                  }

                                                  String readOnlyAnswer=question.readOnlyAnswer;

                                                  String? toggleValue;
                                                  if(answerStr.isNotEmpty){
                                                    toggleValue=answerStr;
                                                  }

                                                  mainFocusNodesMap.putIfAbsent(
                                                    questionId,
                                                        () {
                                                      final node = FocusNode();

                                                      node.addListener(() {
                                                        if (!node.hasFocus) {
                                                          print(
                                                              "Question $questionId Focus Changed : ${node.hasFocus}");
                                                          final value =
                                                              controllersMap[questionId]?.text.trim() ?? '';

                                                          if (value.isNotEmpty) {
                                                            saveMainAnswerIfChanged(
                                                              questionId,
                                                              groupIndex,
                                                              subIndex,
                                                              index,
                                                              value,
                                                              questiontype,
                                                            );
                                                          }
                                                        }
                                                      });

                                                      return node;
                                                    },
                                                  );

                                                  final mainFocusNode = mainFocusNodesMap[questionId]!;

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
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: AppTheme.themeColor,
                                                                ),
                                                              )),
                                                              if(norms.isNotEmpty || referenceImage.isNotEmpty)
                                                                Padding(padding: EdgeInsets.all(3),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                    children: [
                                                                      norms.isNotEmpty?
                                                                      IconButton(onPressed: (){
                                                                        _showHintNormsDialog(norms);
                                                                      },
                                                                          icon: Icon(Icons.info,color: AppTheme.greyColor,size: 24,)
                                                                      ):Container(),
                                                                      referenceImage.isNotEmpty?
                                                                      IconButton(onPressed: (){
                                                                        _showHintImageDialog(referenceImageUrl);
                                                                      },
                                                                          icon: Icon(Icons.image,color: AppTheme.greyColor,size: 24,)
                                                                      ):Container(),
                                                                    ],
                                                                  ),)
                                                            ],
                                                          ),
                                                          const SizedBox(height: 5,),
                                                          Row(
                                                            children: [
                                                              Expanded(flex:2,
                                                                child:
                                                                questiontype=="yes_no" ||  questiontype=="photo"?
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Wrap(
                                                                      spacing: 8,
                                                                      children: statuses.map((status) {
                                                                        final isSelected = answerStr == status;
                                                                        return ChoiceChip(
                                                                          label: Text(
                                                                            status,
                                                                            style: TextStyle(
                                                                              color: isSelected ? Colors.white : Colors.black,
                                                                            ),
                                                                          ),
                                                                          selected: isSelected,
                                                                          selectedColor: status == "Yes" ? Colors.green : Colors.red,
                                                                          checkmarkColor: Colors.white, // tick का color white
                                                                          onSelected: (bool selected)async {
                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                            await Future.delayed(const Duration(milliseconds: 150));
                                                                            if (!mounted) return;
                                                                            setState(() {
                                                                              answerStr = selected ? status : "";
                                                                            });
                                                                            _saveAnswerOnServer(
                                                                                groupIndex, subIndex, index, status, questiontype);
                                                                          },
                                                                        );
                                                                      }).toList(),
                                                                    )
                                                                  ],
                                                                )
                                                                    :
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
                                                                TextFormField(
                                                                  controller: nameController,
                                                                  focusNode: mainFocusNode,
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
                                                                    suffixIcon: IconButton(
                                                                      icon: const Icon(
                                                                        Icons.send_rounded,
                                                                        color: AppTheme.themeColor,
                                                                        size: 22,
                                                                      ),
                                                                      onPressed: () {
                                                                        FocusScope.of(context).unfocus();
                                                                        final value = nameController.text.trim();
                                                                        if (value.isNotEmpty) {
                                                                          saveMainAnswerIfChanged(
                                                                            questionId,
                                                                            groupIndex,
                                                                            subIndex,
                                                                            index,
                                                                            value,
                                                                            questiontype,
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                  onEditingComplete: () {
                                                                    FocusScope.of(context).unfocus();
                                                                  },
                                                                  onFieldSubmitted: (value) async {
                                                                    if(value.isNotEmpty) {
                                                                      await saveMainAnswerIfChanged(
                                                                        questionId,
                                                                        groupIndex,
                                                                        subIndex,
                                                                        index,
                                                                        value,
                                                                        questiontype,
                                                                      );
                                                                      /*_saveAnswerOnServer(
                                                                      groupIndex,subIndex,
                                                                      index, value, questiontype);*/
                                                                    }
                                                                  },
                                                                  onTapOutside: (_){
                                                                    print("tap out side ");
                                                                    FocusScope.of(context).unfocus();
                                                                    final value = nameController.text.trim();
                                                                    if (value.isNotEmpty) {
                                                                      saveMainAnswerIfChanged(
                                                                        questionId,
                                                                        groupIndex,
                                                                        subIndex,
                                                                        index,
                                                                        value,
                                                                        questiontype,
                                                                      );
                                                                    }
                                                                  },
                                                                ),
                                                              ),




                                                            ],
                                                          ),
                                                          const SizedBox(height: 10,),
                                                          questiontype=="photo"?
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Image Required: ",
                                                                style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Colors.black),

                                                              ),
                                                              SizedBox(width: 5,),
                                                              Text(
                                                                "Min: $minImageRequired",
                                                                style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Colors.green),

                                                              ),
                                                              SizedBox(width: 5,),
                                                              Text(
                                                                " | ",
                                                                style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),

                                                              ),
                                                              SizedBox(width: 5,),
                                                              Text(
                                                                "Max : $maxImageRequired",
                                                                style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Colors.red),
                                                              )


                                                            ],
                                                          ):Container(),
                                                          const SizedBox(height: 20,),

                                                          Wrap(
                                                            spacing: 15,
                                                            runSpacing: 10,
                                                            children: [
                                                              if (showCameraIcon)
                                                                _buildActionButton(
                                                                  icon: Icons.camera_alt,
                                                                  color: AppTheme.baseBlueStart,
                                                                  label: "Photo",
                                                                  onTap: () {
                                                                    cameraGroupPosition=groupIndex;
                                                                    cameraSubGroupPosition=subIndex;
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
                                                                    audioGroupPosition=groupIndex;
                                                                    audioSubGroupPosition=subIndex;
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
                                                                    videoGroupPosition=groupIndex;
                                                                    videoSubGroupPosition=subIndex;
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
                                                                    eSignGroupPosition=groupIndex;
                                                                    eSignSubGroupPosition=subIndex;
                                                                    eSignSelectionQuestionId = questionId;
                                                                    eSignSelectedPosition = index;
                                                                    selectedFileType = "4";
                                                                    showEsignDialog(context);
                                                                  },
                                                                ),
                                                            ],
                                                          ),
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
                                                              final url = uploadedImageList[index];
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
                                                              /* isImageUploaded==1?
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

                                                        SizedBox(width: 10,),*/
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
                                                              itemBuilder: (BuildContext subContext,int subQIndex){
                                                                int subQNo=subQIndex+1;
                                                                String subquestionId=subQuestionList[subQIndex].subQuestionId;
                                                                String mainQuestionId=subQuestionList[subQIndex].questionId;
                                                                String subQuText="Q.$qNo.$subQNo)  ${subQuestionList[subQIndex].subQuestionText}";
                                                                String subAnswerStr=subQuestionList[subQIndex].subAnswer;

                                                                /*var subQuestionController=TextEditingController();
                                                            subQuestionController.text=subAnswerStr;*/
                                                                controllersMap.putIfAbsent(
                                                                  subquestionId,
                                                                      () => TextEditingController(),
                                                                );

                                                                var subQuestionController =
                                                                controllersMap[subquestionId]!;

                                                                if(subQuestionController.text.isEmpty){
                                                                  subQuestionController.text = subAnswerStr;
                                                                }


// FocusNode Map
                                                                focusNodesMap.putIfAbsent(
                                                                  subquestionId,
                                                                      () {
                                                                    final node = FocusNode();

                                                                    node.addListener(() {
                                                                      if (!node.hasFocus) {
                                                                        final value =
                                                                            controllersMap[subquestionId]?.text.trim() ?? '';

                                                                        if (value.isNotEmpty) {
                                                                          saveSubAnswerIfChanged(
                                                                            subquestionId,
                                                                            groupIndex,
                                                                            subIndex,
                                                                            index,
                                                                            subQIndex,
                                                                            value,
                                                                          );
                                                                          /*_saveSubAnswerOnServer(
                                                                        groupIndex,
                                                                        subIndex,
                                                                        index,
                                                                        subQIndex,
                                                                        value,
                                                                      );*/

                                                                        }
                                                                      }
                                                                    });

                                                                    return node;
                                                                  },
                                                                );

                                                                final focusNode =
                                                                focusNodesMap[subquestionId]!;




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
                                                                            suffixIcon: IconButton(
                                                                              icon: const Icon(
                                                                                Icons.send_rounded,
                                                                                color: AppTheme.themeColor,
                                                                                size: 22,
                                                                              ),
                                                                              onPressed: () {
                                                                                FocusScope.of(context).unfocus();

                                                                                final value = subQuestionController.text.trim();

                                                                                if (value.isNotEmpty) {
                                                                                  saveSubAnswerIfChanged(
                                                                                    subquestionId,
                                                                                    groupIndex,
                                                                                    subIndex,
                                                                                    index,
                                                                                    subQIndex,
                                                                                    value,
                                                                                  );
                                                                                }
                                                                              },
                                                                            ),
                                                                          ),
                                                                          onTapOutside: (_){
                                                                            FocusScope.of(context).unfocus();
                                                                            final value=subQuestionController.text.trim();
                                                                            if(value.isNotEmpty){
                                                                              saveSubAnswerIfChanged(
                                                                                subquestionId,
                                                                                groupIndex,
                                                                                subIndex,
                                                                                index,
                                                                                subQIndex,
                                                                                value,
                                                                              );
                                                                              // _saveSubAnswerOnServer(groupIndex,subIndex,index, subQIndex, value);
                                                                            }

                                                                          },
                                                                          onEditingComplete: (){
                                                                            FocusScope.of(context).unfocus();
                                                                            final value=subQuestionController.text.trim();
                                                                            if(value.isNotEmpty){
                                                                              saveSubAnswerIfChanged(
                                                                                subquestionId,
                                                                                groupIndex,
                                                                                subIndex,
                                                                                index,
                                                                                subQIndex,
                                                                                value,
                                                                              );
                                                                              // _saveSubAnswerOnServer(groupIndex,subIndex,index, subQIndex, value);
                                                                            }
                                                                          },
                                                                          /*onFieldSubmitted: (value) async {
                                                                        setState(() {
                                                                        });
                                                                        if(value.isNotEmpty) {
                                                                          //_saveSubAnswerOnServer(groupIndex,subIndex,index, subIndex, value);
                                                                          _saveSubAnswerOnServer(groupIndex,subIndex,index, subQIndex, value);
                                                                        }
                                                                      },*/
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
        ));
  }
  _saveSubAnswerOnServer(int groupIndex,int subGroupIndex,int index,int subIndex, String answer)async{
    String mainQuestionId=questionList[groupIndex].subGroupList[subGroupIndex].questionList[index].subQuestionList[subIndex].questionId;
    String subQuestionId=questionList[groupIndex].subGroupList[subGroupIndex].questionList[index].subQuestionList[subIndex].subQuestionId;
    questionList[groupIndex].subGroupList[subGroupIndex].questionList[index].subQuestionList[subIndex].subAnswer=answer;
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
      Toast.show(responseJSON["message"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      MyUtils.logoutUser(context);

    }
    else {
      /*Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);*/
      APIDialog.showErrorDialog(responseJSON["message"]?.toString()??"Something went wrong. Please try again", context);
    }
  }
  _saveAnswerOnServer(int groupIndex,int subGroupIndex,int index, String answer,String questiontype)async{
    var group=questionList[groupIndex];
    var subGroup=group.subGroupList[subGroupIndex];
    var question=subGroup.questionList[index];
    String QuestionId=question.questionId;
    String answerId="";
    if(questiontype=="yes_no" || questiontype=="photo"){
      if(answer=="Yes"){
        answerId="1";
      }else if(answer=="No"){
        answerId="0";
      }
    }else{
      answerId=answer;
    }
    questionList[groupIndex].subGroupList[subGroupIndex].questionList[index].answerId=answerId;
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
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }

    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      sortGroupsByCompletion();
      setState(() {});
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);
    }
    else if(responseJSON["status"]==3){
      Toast.show(responseJSON["message"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      MyUtils.logoutUser(context);


    }
    else {
      /*Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);*/
      APIDialog.showErrorDialog(responseJSON["message"]?.toString()??"Something went wrong. Please try again", context);
    }
  }
  Future<void> prepairCamera() async{

    final imageData=await Navigator.push(context,MaterialPageRoute(builder: (context)=>MarkAttendanceScreen(0)));
    if(imageData!=null)
    {
      capturedImage=imageData;
      capturedFile=File(capturedImage!.path);
      openImageEditor(capturedFile!);
    }else{
      Toast.show("Unable to capture Image. Please try Again...",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }

    // imageSelector(context);
    /*if(Platform.isAndroid){
      final imageData=await Navigator.push(context,MaterialPageRoute(builder: (context)=>MarkAttendanceScreen(0)));
      if(imageData!=null)
      {
        capturedImage=imageData;
        capturedFile=File(capturedImage!.path);
        openImageEditor(capturedFile!);
       // _showCameraImageDialog();
      }else{
        Toast.show("Unable to capture Image. Please try Again...",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    }else{
      imageSelector(context);
    }*/


  }
  Future<void> openImageEditor(File imageFile) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (editorContext) => ProImageEditor.file(
          imageFile,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {

              final tempDir = await getTemporaryDirectory();

              final editedFile = File(
                '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );

              await editedFile.writeAsBytes(bytes);

              capturedFile = editedFile;

              // Close Image Editor
              Navigator.of(editorContext).pop();

              // Give navigation some time
              await Future.delayed(
                const Duration(milliseconds: 200),
              );

              if (mounted) {
                _showCameraImageDialog();
              }
            },
          ),
        ),
      ),
    );
  }
  videoRecorder(BuildContext context) async{
    videoFile = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      maxDuration: const Duration(seconds: 60)
    );

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
      "latitude":latitudeStr,
      "longitude":longitudeStr,
      "emp_id":sUserId,
      "file_type":selectedFileType,
      "Orignal_Name":fileName,
      "ext":extension,
      "file": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl="${baseUrl}vi_save_draft";
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
          String esign = data['esign_url']?.toString() ?? "";
          String fileType = data['file_type']?.toString() ?? selectedFileType;
          if (fileType == "1") {
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].imageUrl=image;
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].isImageUploaded=1;
          } else if (fileType == "2") {
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].voiceUrl=voice;
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].isAudioUploaded=1;
          } else if (fileType == "3") {
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].videoUrl=video;
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].isVideoUploaded=1;
          }else if (fileType == "4") {
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].eSignUrl=esign;
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].isEsignUploaded=1;

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
      "latitude":latitudeStr,
      "longitude":longitudeStr,
      "file_type":selectedFileType,
      "Orignal_Name":fileName,
      "ext":extension,
      "file": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl="${baseUrl}vi_save_draft";
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
          String esign = data['esign_url']?.toString() ?? "";
          String fileType = data['file_type']?.toString() ?? selectedFileType;
          if (fileType == "1") {
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].imageUrl=image;
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].isImageUploaded=1;
          } else if (fileType == "2") {
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].voiceUrl=voice;
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].isAudioUploaded=1;
          } else if (fileType == "3") {
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].videoUrl=video;
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].isVideoUploaded=1;
          }else if (fileType == "4") {
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].eSignUrl=esign;
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].isEsignUploaded=1;

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
                  value==100?
                  Center(child: Loader(),):
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
                  value==100?
                  Text(
                    "Please wait... Getting confirmation from server",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ):
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
      "latitude":latitudeStr,
      "longitude":longitudeStr,
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

    String apiUrl = "${baseUrl}vi_save_draft";
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
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].imageUrl=image;
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].isImageUploaded=1;
          } else if (fileType == "2") {
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].voiceUrl=voice;
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].isAudioUploaded=1;
          } else if (fileType == "3") {
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].videoUrl=video;
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].isVideoUploaded=1;
          }else if (fileType == "4") {
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].eSignUrl=esign;
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].isEsignUploaded=1;

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
    controllersMap.forEach((key, controller) => controller.dispose());
    focusNodesMap.forEach((key, node) => node.dispose());
    mainFocusNodesMap.forEach((_, n) => n.dispose());
    super.dispose();
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
      "latitude":latitudeStr,
      "longitude":longitudeStr,
      "emp_id":sUserId,
      "file_type":selectedFileType,
      "Orignal_Name":fileName,
      "ext":extension,
      "file": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl="${baseUrl}vi_save_draft";
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
          String esign = data['esign_url']?.toString() ?? "";
          String fileType = data['file_type']?.toString() ?? selectedFileType;
          if (fileType == "1") {
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].imageUrl=image;
            questionList[cameraGroupPosition].subGroupList[cameraSubGroupPosition].questionList[cameraSelectionPosition].isImageUploaded=1;
          } else if (fileType == "2") {
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].voiceUrl=voice;
            questionList[audioGroupPosition].subGroupList[audioSubGroupPosition].questionList[audioSelectedPosition].isAudioUploaded=1;
          } else if (fileType == "3") {
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].videoUrl=video;
            questionList[videoGroupPosition].subGroupList[videoSubGroupPosition].questionList[videoSelectionPosition].isVideoUploaded=1;
          }else if (fileType == "4") {
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].eSignUrl=esign;
            questionList[eSignGroupPosition].subGroupList[eSignSubGroupPosition].questionList[eSignSelectedPosition].isEsignUploaded=1;

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
  _submitBtnValidatorNew() {
    bool validation = true;
    outerLoop:
    for (int i = 0; i < questionList.length; i++) {
      var subGroupList = questionList[i].subGroupList;
      for (int j = 0; j < subGroupList.length; j++) {
        var questions = subGroupList[j].questionList;
        for (int k = 0; k < questions.length; k++) {
          int qNo = k + 1;
          String groupName = questionList[i].groupName;
          String subGroupName = subGroupList[j].subGroupName;
          var q = questions[k];

          List<String> imageList = [];
          if (q.imageUrl != null && q.imageUrl.isNotEmpty && q.imageUrl != "null") {
            imageList = q.imageUrl.split(",");
          }
          if (q.type == "photo" && q.minPhoto > imageList.length) {
            APIDialog.showErrorDialog("You have not uploaded required Images $groupName($subGroupName) question-$qNo", context);
            //_showError("You have not uploaded required Images $groupName($subGroupName) question-$qNo");
            validation = false;
            break outerLoop;
          } else if (q.type != "read_only" && (q.answerId == null || q.answerId.isEmpty || q.answerId == "null")) {
           // _showError("Please Select the Answer of $groupName($subGroupName) question- $qNo");
            APIDialog.showErrorDialog("Please Select the Answer of $groupName($subGroupName) question- $qNo", context);
            validation = false;
            break outerLoop;
          }
          final validations = [
            [q.imageRequired == 1 && q.isImageUploaded != 1, "You have not uploaded required Image of $groupName($subGroupName) question-$qNo"],
            [q.audioRequired == 1 && q.isAudioUploaded != 1, "You have not uploaded required Voice Recording of $groupName($subGroupName) question-$qNo"],
            [q.videoRequired == 1 && q.isVideoUploaded != 1, "You have not uploaded required Video of $groupName($subGroupName) question-$qNo"],
            [q.eSignRequired == 1 && q.isEsignUploaded != 1, "You have not uploaded required E-Sign of $groupName($subGroupName) question-$qNo"],
          ];

          for (var v in validations) {
            if (v[0] as bool) {
              APIDialog.showErrorDialog(v[1] as String, context);
              //_showError(v[1] as String);

              validation = false;
              break outerLoop;
            }
          }

          for (int l = 0; l < q.subQuestionList.length; l++) {
            int subQNo = l + 1;
            var subQ = q.subQuestionList[l];
            if (subQ.subAnswer == null || subQ.subAnswer.isEmpty || subQ.subAnswer == "null") {
              APIDialog.showErrorDialog("Please Enter the Answer of $groupName($subGroupName) question- $qNo.$subQNo", context);
              //_showError("Please Enter the Answer of $groupName($subGroupName) question- $qNo.$subQNo");
              validation = false;
              break outerLoop;
            }
          }
        }
      }
    }
    if (validation) {
      var jsonArray=[];
      for(int i=0;i<questionList.length;i++){
        var q=questionList[i].subGroupList;
        for(int j=0;j<q.length;j++){
          var subQ=q[j].questionList;
          for(int k=0;k<subQ.length;k++){
            var questions=subQ[k];
            var ans={
              "question_id":questions.questionId,
              "answer":questions.answerId
            };
            jsonArray.add(ans);
            var subQList=questions.subQuestionList;
            for(int l=0;l<subQList.length;l++){
              var subQues=subQList[l];
              var ans={
                "question_id":subQues.subQuestionId,
                "main_question_id":subQues.questionId,
                "answer":subQues.subAnswer
              };
              jsonArray.add(ans);
            }
          }
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
  _showHintImageDialog(String imageUrl){
    showDialog(context: context, builder: (ctx)=>AlertDialog(
        title: const Text("Reference Image",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 18),),
        content: Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.rectangle,
            image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover
            ),

          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: (){
                Navigator.of(ctx).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.themeColor,
                ),
                height: 45,
                padding: const EdgeInsets.all(10),
                child: const Center(child: Text("ok",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
              )
          ),
        ]
    ));
  }
  _showHintNormsDialog(String norms){
    showDialog(context: context, builder: (ctx)=>AlertDialog(
        title: const Text("Norms",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 18),),
        content: Padding(
          padding: EdgeInsets.all(5),
          child: Text(norms,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Colors.black),),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: (){
                Navigator.of(ctx).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.themeColor,
                ),
                height: 45,
                padding: const EdgeInsets.all(10),
                child: const Center(child: Text("OK",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
              )
          ),
        ]
    ));
  }
  Future<void> saveSubAnswerIfChanged(
      String subQuestionId,
      int groupIndex,
      int subIndex,
      int index,
      int subQIndex,
      String value,
      ) async {

    value = value.trim();

    if (value.isEmpty) return;

    if (lastSavedSubAnswers[subQuestionId] == value) {
      return;
    }

    lastSavedSubAnswers[subQuestionId] = value;

    await _saveSubAnswerOnServer(
      groupIndex,
      subIndex,
      index,
      subQIndex,
      value,
    );
  }

  Future<void> saveMainAnswerIfChanged(
      String questionId,
      int groupIndex,
      int subIndex,
      int index,
      String value,
      String questionType,
      ) async {

    if (lastSavedMainAnswers[questionId] == value) {
      return;
    }

    lastSavedMainAnswers[questionId] = value;

    await _saveAnswerOnServer(
      groupIndex,
      subIndex,
      index,
      value,
      questionType,
    );
  }

  bool isGroupCompleted(ViTaskQuestionSeries group) {
    for (var subGroup in group.subGroupList) {
      for (var question in subGroup.questionList) {

        // Skip read only questions
        if (question.type == "read_only") {
          continue;
        }

        // Main answer validation
        if (question.answerId.isEmpty ||
            question.answerId == "null") {
          print(
              "Group ${group.groupName} pending because Question ${question.questionId} is unanswered"
          );
          return false;
        }

        // Sub questions validation
        for (var subQ in question.subQuestionList) {
          if (subQ.subAnswer.trim().isEmpty) {
            return false;
          }
        }

        // Required image validation
        if (question.imageRequired == 1 &&
            question.isImageUploaded != 1) {
          return false;
        }

        // Required audio validation
        if (question.audioRequired == 1 &&
            question.isAudioUploaded != 1) {
          return false;
        }

        // Required video validation
        if (question.videoRequired == 1 &&
            question.isVideoUploaded != 1) {
          return false;
        }

        // Required eSign validation
        if (question.eSignRequired == 1 &&
            question.isEsignUploaded != 1) {
          return false;
        }
      }
    }

    return true;
  }

  void sortGroupsByCompletion() {
    questionList.sort((a, b) {

      bool aCompleted = isGroupCompleted(a);
      bool bCompleted = isGroupCompleted(b);

      if (aCompleted == bCompleted) {
        return 0; // keep existing order
      }

      if (!aCompleted && bCompleted) {
        return -1; // pending first
      }

      return 1; // completed last
    });

    _expandedState = List.filled(questionList.length, false);
  }


}