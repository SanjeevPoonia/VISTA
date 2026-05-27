import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/vista/MarkAttendanceScreen.dart';
import 'package:vista/vista/landing_screen.dart';

import '../issue_admin/issue_admin_dashboard_screen.dart';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../network/loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class VerifyOtp extends StatefulWidget{
  String userId;
  String email;
  String mobile;

  VerifyOtp(this.email,this.mobile,this.userId, {super.key});

  _verifyOtpState createState()=> _verifyOtpState();
}
class _verifyOtpState extends State<VerifyOtp>{

  String? userEnteredOTP = "";
  List<TextEditingController?> controllerList = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _start = 30;
  Timer? _timer;

  bool clearText = false;
  var baseUrl;
  List<dynamic> locationList=[];
  Position? _currentPosition;
  XFile? capturedImage;
  File? capturedFile;

  XFile? imageFile;
  File? file;
  void startTimer() {
    _start = 30;
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    bool setText = clearText;
    if (clearText) {
      clearText = false;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.themeColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 10,),

                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/back_img.png'),
                        fit: BoxFit.cover,
                      )
                  ),
                )
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 18),
              Container(
                height: 475,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      const SizedBox(height: 25),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset("assets/vista_logo.png",height: 50,width: 150,),
                      ),
                      const SizedBox(height: 10,),
                      const Center(
                        child: Text('Hello',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orangeColor,
                            )),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text('Please enter the otp sent on your email address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 45,
                        child: Center(
                          child: OtpTextField(
                            borderRadius: BorderRadius.circular(4),
                            borderColor: AppTheme.otpColor,
                            fillColor: AppTheme.otpColor,
                            filled: true,
                            numberOfFields: 4,
                            handleControllers:
                                (List<TextEditingController?> controllers) {
                              controllerList = controllers;
                            },
                            textStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),


                            clearText: setText,
                            focusedBorderColor: AppTheme.orangeColor,
                            //set to true to show as box or false to show as dash
                            showFieldAsBox: true,
                            //runs when a code is typed in
                            showCursor: false,
                            onCodeChanged: (String code) {},
                            //runs when every textfield is filled
                            onSubmit: (String verificationCode) {
                              userEnteredOTP = verificationCode;
                              setState(() {
                                // validateMobileotp(verificationCode);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A1A1A),
                              ),
                              children: <TextSpan>[
                                const TextSpan(text: 'Resend OTP in '),
                                TextSpan(
                                  text: _start < 10
                                      ? '00:0' + _start.toString()
                                      : '00:' + _start.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                                const TextSpan(text: ' seconds '),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Didn\'t receive the OTP ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              )),
                          _start == 0
                              ? GestureDetector(
                            onTap: () {
                              print("resend otp triggered");
                              resendOtp(context);
                            },
                            child: Text('Resend',
                                style: TextStyle(
                                    fontSize: 15,
                                    decoration:
                                    TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.themeColor)),
                          )
                              : Text('Resend',
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                        ],
                      ),

                      const SizedBox(height: 35),
                      InkWell(
                        onTap: () {
                          _submitHandler();

                        },
                        child: Container(
                            margin:
                            const EdgeInsets.symmetric(horizontal: 15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: AppTheme.themeColor,
                                borderRadius: BorderRadius.circular(5)),
                            height: 50,
                            child: const Center(
                              child: Text('Verify',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            )),
                      ),
                      const SizedBox(height: 40,),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SvgPicture.asset("assets/powered_by.svg",height: 30),),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height:MediaQuery.of(context).viewInsets.bottom)
            ],
          )

        ],
      )),
    );
  }
  resendOtp(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Validating...');
    var data = {
      "mobile_number": widget.mobile,
      "email": widget.email,
      "fcm_token": "",
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'vi_login_employee', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);

    if(responseJSON["status"]==1)
    {

      Toast.show("OTP has been resend on your email address",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);
      startTimer();
      clearText = true;
      setState(() {});
    }
    else
    {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }





    print(responseJSON);

  }
  _getClientInfo() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base = prefs.getString('base_url') ?? '';

    if(base!=''){
      baseUrl=base.toString();
    }

    print("base url $baseUrl");

  }
  @override
  void initState() {
    super.initState();
    _getClientInfo();
     startTimer();
  }
  _submitHandler() async {
    print(userEnteredOTP);
    if (userEnteredOTP != "") {
      validateMobileotp(userEnteredOTP);
    } else {
      Toast.show("Please Enter OTP",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }
  }
  validateMobileotp(otpStr) async {
    FocusScope.of(context).unfocus();
    APIDialog.showAlertDialog(context, 'Verifying OTP...');
    var requestModel = {
      "user_id": widget.userId,
      "otp": otpStr,
    };
    print(baseUrl);
    print(requestModel);

    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(
        baseUrl, 'vi_login_varify_otp', requestModel, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);

    if (responseJSON['status'] == 1) {

      if(responseJSON['data']['is_photo_login']!=null){
        int isPhotoLogin=responseJSON['data']['is_photo_login'];
        if(isPhotoLogin==1){
          locationList.clear();
          locationList=responseJSON['data']['location'];
          _getLocation(responseJSON);
        }else{
          Toast.show(responseJSON['message'],
              duration: Toast.lengthLong,
              gravity: Toast.bottom,
              backgroundColor: Colors.green);
          _saveUerDetailsAndRedirect(responseJSON);
        }
      }else{
        Toast.show(responseJSON['message'],
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.green);
        _saveUerDetailsAndRedirect(responseJSON);
      }


    } else {
      String msg=responseJSON['message']?.toString()??"";
      APIDialog.showErrorDialog(msg, context);
    }
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
  Future<void> _getLocation(var loginResponse) async {
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
      print(
          "Location  latitude : ${_currentPosition!.latitude} Longitude : ${_currentPosition!.longitude}");
      Navigator.pop(context);

      _checkLocationDistance(loginResponse);

    }).catchError((e) {
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
                      "Please allow below permissions for access the login Functionality.",
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
  _saveUerDetailsAndRedirect(var responseJSON){
    String sUserId = responseJSON['data']['user_id'].toString();
    String sUSerName = responseJSON['data']['full_name'].toString();
    String sUSerMobileNumber = responseJSON['data']['mobile_number'].toString();
    String language = responseJSON['data']['language'].toString();
    String employeeRoleId = responseJSON['data']['employee_role_id'].toString();
    String employeeShiftId = responseJSON['data']['employee_shift_id'].toString();
    String empRoleName=responseJSON["user_role"]?.toString()??"";
    String token = responseJSON['data']['remember_token'];
    String lang="";
    if(language=='hindi' || language == 'Hindi'){
      lang="hi";
    }else if(language=='english' || language == 'English'){
      lang="en";
    }else if(language=='Gujarati' || language == 'gujarati'){
      lang="gu";
    }else if(language=='Urdu' || language == 'urdu'){
      lang="ur";
    }else {
      lang=language;
    }
    MyUtils.saveUserDetails(sUserId, sUSerName, sUSerMobileNumber, lang, employeeRoleId, token,employeeShiftId,empRoleName);

    if(employeeRoleId=="18" ||employeeRoleId=="19" ||employeeRoleId=="20"||employeeRoleId=="24"){
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => IssueAdminDashboard()),
              (Route<dynamic> route) => false);
    }else{

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LandingScreen()),
              (Route<dynamic> route) => false);
    }

  }
  _checkLocationDistance(var loginResponse) async{
    APIDialog.showAlertDialog(context, "Please wait checking location..");
    bool isLocationMatched=false;
    if(locationList.isEmpty){
      isLocationMatched=true;
    }
    else{
      for(int i=0;i<locationList.length;i++){

        String locLat=locationList[i]['latitude'].toString();
        String locLong=locationList[i]['longitude'].toString();
        String radius=locationList[i]['threshold'].toString();
        String str = locLat;
        num value = num.parse(str);
        double doubleValuelat = value.toDouble();

        String strlong = locLong;
        num valuelong = num.parse(strlong);
        double doubleValuelong = valuelong.toDouble();

        String radi=radius;
        num valueRadi=num.parse(radi);
        double doubleRadius=valueRadi.toDouble();

        var _distanceInMeters= Geolocator.distanceBetween(doubleValuelat,doubleValuelong,_currentPosition!.latitude,_currentPosition!.longitude);

        print("distance $_distanceInMeters");

        if(_distanceInMeters<=doubleRadius){
          isLocationMatched=true;
          break;
        }

      }

    }

    Navigator.of(context).pop();
    if(isLocationMatched){
      prepairCamera(loginResponse);
    }else{
     // prepairCamera(loginResponse);

      APIDialog.showErrorDialog("You are not in an authorized location. Please move to an allowed location and try logging in again.", context);
      /* Toast.show(
          "Your are not in the Allowed Location !!! Please go to allowed location and try to Login.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);*/
    }
  }
  Future<void> prepairCamera(var loginResponse) async{

    // imageSelector(context);
    if(Platform.isAndroid){
      final imageData=await Navigator.push(context,MaterialPageRoute(builder: (context)=>MarkAttendanceScreen(1)));
      if(imageData!=null)
      {
        capturedImage=imageData;
        capturedFile=File(capturedImage!.path);
        _faceFromCamera(loginResponse);
        //_showCameraImageDialog();
      }else{
        Toast.show("Unable to capture Image. Please try Again...",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    }else{
      imageSelector(context,loginResponse);
    }


  }
  _faceFromCamera(var loginResponse) async{
    APIDialog.showAlertDialog(context, "Detecting Face....");
    final image=InputImage.fromFile(capturedFile!);
    final faces=await _faceDetector.processImage(image);
    print("faces in image ${faces.length}");
    Navigator.pop(context);
    if(faces.isNotEmpty){
      submitReimbursmentWithImage("camera", loginResponse);
    }else{
      Toast.show("Face not detected in captured image. Please capture a selfie.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      _showFaceErrorCustomDialog();
    }
  }
  imageSelector(BuildContext context,var loginResponse) async{

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
        _faceDetection(loginResponse);
      } else {
        print("You have not taken image");
      }
    }else{
      Toast.show("Unable to capture Image. Please try Again...",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }


  }
  _faceDetection(var loginResponse) async{
    APIDialog.showAlertDialog(context, "Detecting Face....");

    final image=InputImage.fromFile(file!);
    final faces=await _faceDetector.processImage(image);
    print("faces in image ${faces.length}");
    Navigator.pop(context);
    if(faces.isNotEmpty){
      submitReimbursmentWithImage("iOS", loginResponse);

    }else{
      Toast.show("Face not detected in captured image. Please capture a selfie.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      _showFaceErrorCustomDialog();
    }

  }
  _showFaceErrorCustomDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
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
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close_rounded,color: Colors.red,size: 20,),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text(
                      "Please capture Selfie!!!",
                      style: TextStyle(color: Colors.red,fontWeight: FontWeight.w900,fontSize: 18),),
                    SizedBox(height: 20,),

                    Text(
                      "Face not detected in captured Image. Please capture Selfie.",
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontSize: 14),),
                    SizedBox(height: 20,),
                    TextButton(
                        onPressed: (){
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
                          child: const Center(child: Text("OK",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
                        )
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
  ValueNotifier<double> uploadProgressNotifier = ValueNotifier<double>(0.0);
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
                "Verying your details",
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
  oldSubmitReimbursmentWithImage(String from,var loginResponse) async{
    uploadProgressNotifier.value = 0.0;
    showUploadDialog(context, "Login Image");
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
      "mobile_number":widget.mobile,
      "latitude":_currentPosition!.latitude.toString(),
      "longitude":_currentPosition!.longitude.toString(),
      "Orignal_Name":fileName,
      "ext":extension,
      "image": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl=baseUrl+"login";
    print(apiUrl);
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    try {
      var response = await dio.post(apiUrl, data: formData,
        onSendProgress: (int sent, int total) {
          double percentage = (sent / total) * 100;
          uploadProgressNotifier.value = percentage;
        },
      );
      print(response.data);
      Navigator.pop(context);
      if (response.statusCode == 200) {
        Toast.show("Login Successfully",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.green);
        _saveUerDetailsAndRedirect(loginResponse);

      }else{
        Toast.show(response.data['message'],
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
  submitReimbursmentWithImage(String from,var loginResponse) async{
    uploadProgressNotifier.value = 0.0;
    showUploadDialog(context, "Login Image");
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
      "mobile_number":widget.mobile,
      "latitude":_currentPosition!.latitude.toString(),
      "longitude":_currentPosition!.longitude.toString(),
      "Orignal_Name":fileName,
      "ext":extension,
      "image": await MultipartFile.fromFile(filePath,
          filename: fileName),
    });
    String apiUrl=baseUrl+"vi_login";
    print(apiUrl);
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    try {
      var response = await dio.post(apiUrl, data: formData,
        onSendProgress: (int sent, int total) {
          double percentage = (sent / total) * 100;
          uploadProgressNotifier.value = percentage;
        },
      );
      print(response.data);
      Navigator.pop(context);
      if (response.data['status'] == 1) {
        Toast.show("Login Successfully",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.green);
        _saveUerDetailsAndRedirect(loginResponse);
      }else{
        String msg= response.data['message']?.toString()??"";
        APIDialog.showErrorDialog(msg, context);
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

}