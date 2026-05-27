import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';

import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../utils/audio_recording_dialog.dart';

class RaiseIssuePage extends StatefulWidget {
  @override
  _RaiseIssuePageState createState() => _RaiseIssuePageState();
}

class _RaiseIssuePageState extends State<RaiseIssuePage> {
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var sUserLanguage="";
  final _formKey = GlobalKey<FormState>();
  Map<String,dynamic>? selectedTopic;
  Map<String,dynamic>? selectedSubTopic;
  String? description;
  File? _image;
  String? selectedIssueId;
  String? selectedSubIssueId;
  String pageTitle="Raise an Issue";
  List<dynamic> issueTypeList=[];
  List<dynamic> issueSubTypeList=[];
  var descriptionController=TextEditingController();
  String? _filePathRecording;
  XFile? videoFile;
  File? vFile;
  String videoFileName="";
  String audioFileName="";


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      submitIssue();
    }
  }
  ValueNotifier<double> uploadProgressNotifier = ValueNotifier<double>(0.0);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Topic Dropdown
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedTopic,
                decoration: const InputDecoration(labelText: "Select Issue"),
                items: issueTypeList.map<DropdownMenuItem<Map<String, dynamic>>>(
                      (item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item['issue']?.toString() ?? "N/A"),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTopic = value;
                    selectedSubTopic = null;
                    selectedIssueId=value?['id'].toString();
                    print("Selected ID: ${value?['id']}");
                    print("Selected Issue: ${value?['issue']}");
                  });
                  _getIssueSubType(context, selectedIssueId!);
                },
                validator: (value) =>
                value == null ? "Please select a issue" : null,
              ),

              SizedBox(height: 16),

              issueSubTypeList.isNotEmpty?

              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedSubTopic,
                decoration: const InputDecoration(labelText: "Select Sub Issue"),
                items: issueSubTypeList.map<DropdownMenuItem<Map<String, dynamic>>>(
                      (item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item['sub_issue']?.toString() ?? "N/A"),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubTopic = value;
                    selectedSubIssueId=value?['id'].toString();
                    print("Selected Sub ID: ${value?['id']}");
                    print("Selected Sub Issue: ${value?['sub_issue']}");
                  });
                },
                validator: (value) =>
                value == null ? "Please select sub issue" : null,
              ):Container(),
              // Subtopic Dropdown


              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                cursorColor: AppTheme.themeColor,
                decoration: const InputDecoration(
                  labelText: "Enter Description",
                  labelStyle: TextStyle(color: AppTheme.themeColor),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, //
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.themeColor, width: 2), // 👈 focus border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.themeColor, width: 1), // 👈 normal border color
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                maxLines: 4,
                maxLength: 500,
                onSaved: (value) => description = value,
                validator: (value) => value == null || value.isEmpty
                    ? "Description cannot be empty"
                    : null,
              ),

              SizedBox(height: 16),

              // Image Capture
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.camera_alt,color: AppTheme.orangeColor,),
                    label: Text("Capture Image",style: TextStyle(color: AppTheme.orangeColor),),
                  ),
                  SizedBox(width: 16),
                  _image != null
                      ? Image.file(_image!, width: 80, height: 80)
                      : Text("No image selected"),
                ],
              ),
              SizedBox(height: 10,),
              //Record Audio
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _recordAudio,
                    icon: Icon(Icons.mic,color: AppTheme.orangeColor,),
                    label: Text("Record Audio",style: TextStyle(color: AppTheme.orangeColor),),
                  ),
                  SizedBox(width: 16),
                  _filePathRecording != null
                      ? Text("Audio Added",style: TextStyle(fontWeight: FontWeight.w700,color: AppTheme.themeColor),)
                      : Text("No Audio Recorded"),
                ],
              ),
              SizedBox(height: 10,),
              //Record Audio
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _videoRecorder,
                    icon: Icon(Icons.video_camera_back_outlined,color: AppTheme.orangeColor,),
                    label: Text("Record Video",style: TextStyle(color: AppTheme.orangeColor),),
                  ),
                  SizedBox(width: 16),
                  vFile != null
                      ? Text("Video Added",style: TextStyle(fontWeight: FontWeight.w700,color: AppTheme.themeColor))
                      : Text("No Video Recorded"),
                ],
              ),


              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54), // 👈 width & height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 👈 rounded corners
                  ),
                  backgroundColor: AppTheme.orangeColor,
                  foregroundColor: Colors.white
                ),
                onPressed: _submitForm,
                child: Text("Submit",),

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
    _getIssueType(context);
  }
  _getIssueType(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get-issue-type', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      issueTypeList.clear();
      issueTypeList = List.from(responseJSON['data']);
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
      issueTypeList.clear();
      issueSubTypeList.clear();
      setState(() {

      });
    }


  }
  _getIssueSubType(BuildContext context,String issueId) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "issue_id":issueId
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get-sub-issue-type', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      issueSubTypeList.clear();
      issueSubTypeList = List.from(responseJSON['data']);
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

      issueSubTypeList.clear();
      setState(() {

      });
    }


  }
  submitIssue() async{
    uploadProgressNotifier.value = 0.0;
    showUploadDialog(context);
    String fileName="";
    String filePath="";
    if(_image!=null){
      fileName=_image!.path.split("/").last;
      filePath=_image!.path;
    }

    String videoFileName = "";
    String videoFilePath = "";
    if(vFile!=null){
     videoFileName= vFile!.path.split("/").last;
     videoFilePath= vFile!.path;
    }

    String audioFileName="";
    String audioFilePath="";
    if(_filePathRecording!=null){
      audioFilePath=_filePathRecording!;
      audioFileName=audioFilePath.split("/").last;
    }


    String extension = fileName.split('.').last;
    final Map<String, dynamic> data = {
      "auth_key": sRemeberToken,
      "issue_id": selectedIssueId,
      "sub_issue_id": selectedSubIssueId,
      "raised_concern": descriptionController.text.toString(),
    };
    if (_image != null) {
      data["artifact"] = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
    }
    if (vFile != null) {
      data["video"] = await MultipartFile.fromFile(
        videoFilePath,
        filename: videoFileName,
      );
    }
    if (_filePathRecording != null) {
      data["voice"] = await MultipartFile.fromFile(
        audioFilePath,
        filename: audioFileName,
      );
    }

    FormData formData = FormData.fromMap(data);


    String apiUrl="${baseUrl}raise-issue";
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
          setState(() {

          });
          Navigator.pop(context);

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
  void showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.cloud_upload_rounded, color: AppTheme.orangeColor),
              SizedBox(width: 8),
              Text(
                "Raising Issue...",
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
                    "Please wait while your issue is being raised...",
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


  Future<void> _recordAudio() async{
    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
    String fileNameCustom = "${currentTimeMillis}issue_recorded_audio";
    _filePathRecording = await showDialog<String>(
      context: context,
      builder: (context) => AudioRecordingDialog(fileNameCustom),
    );

    if(_filePathRecording!=null && _filePathRecording!.isNotEmpty){
      setState(() {
        audioFileName=_filePathRecording!.split("/").last;
      });
    }


  }
  Future<void>  _videoRecorder() async{
    videoFile = await ImagePicker().pickVideo(source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      maxDuration: const Duration(seconds: 60)
    );

    if(videoFile!=null){
      vFile=File(videoFile!.path);
      final imageFiles = videoFile;
      if (imageFiles != null) {
        print("You selected  video : " + imageFiles.path.toString());
        setState(() {
          videoFileName = vFile!.path.split("/").last;
        });
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



}