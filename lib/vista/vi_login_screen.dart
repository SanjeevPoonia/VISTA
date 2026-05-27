import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/vista/vi_verify_otp_screen.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';

class ViLoginScreen extends StatefulWidget{
  _viLoginScreen createState()=> _viLoginScreen();
}
class _viLoginScreen extends State<ViLoginScreen>{
  var mobileNoController = TextEditingController();
  var emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  var baseUrl;
  Position? _currentPosition;
  List<dynamic> locationList=[];
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
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
          Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 18),
                  Container(
                    height: 470,
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
                            child: Text('Login to your Account.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                )),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            child: TextFormField(
                              controller: mobileNoController,
                              validator: checkEmptyString,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "Enter Mobile Number",
                                label: Text("Mobile Number"),
                                suffixIcon: Icon(Icons.phone_android_outlined,color: AppTheme.themeColor,),
                                enabledBorder: UnderlineInputBorder( borderSide: BorderSide(color:AppTheme.orangeColor)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            child: TextFormField(
                              controller: emailController,
                              validator: emailValidator,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: "Enter Email Address",
                                label: Text("Email Address"),
                                suffixIcon: Icon(Icons.mail_outline,color: AppTheme.themeColor,),
                                enabledBorder: UnderlineInputBorder( borderSide: BorderSide(color:AppTheme.orangeColor)),
                              ),
                            ),
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
                                  child: Text('Login',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                )),
                          ),
                          const SizedBox(height: 40,),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                            child: SvgPicture.asset("assets/powered_by.svg",height: 30),),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).viewInsets.bottom)
                ],
              ))

        ],
      )),
    );
  }

  void _submitHandler() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _getCurrentPosition();
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
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Toast.show(
          "Location permissions are permanently denied, we cannot request permissions.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      return false;
    }

    return true;
  }
  Future<void> _getCurrentPosition() async {
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
      validateUserMobileEmail(context);

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
  @override
  void initState() {
    super.initState();
    _getClientInfo();
  }
  _getClientInfo() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base = prefs.getString('base_url') ?? '';

    if(base!=''){
      baseUrl=base.toString();
    }

    print("base url $baseUrl");

  }
  String? checkEmptyString(String? value) {
    String val=value!.trim();
    if (val.isEmpty || val.length!=10) {
      return 'Please enter Your 10 digit mobile number';
    }
    return null;
  }
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email address';
    if (!emailRegex.hasMatch(value.trim())) return 'Please enter your valid email address';
    return null;
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
  validateUserMobileEmail(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Validating...');
    var data = {
      "mobile_number": mobileNoController.text,
      "email": emailController.text,
      "fcm_token": "",
      "latitude": _currentPosition!.latitude,
      "longitude": _currentPosition!.longitude,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'vi_login_employee', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);

    if(responseJSON["status"]==1)
    {
      Toast.show(responseJSON["message"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);

      String userId=responseJSON['data']?["user_id"]?.toString()??"";
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            VerifyOtp(emailController.text, mobileNoController.text, userId)
        ),);

    }
    else
    {
      String errorStr=responseJSON["message"]?.toString()??"";
      APIDialog.showErrorDialog(errorStr, context);
    }





    print(responseJSON);

  }

}