import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vista/issue_admin/issue_admin_dashboard_screen.dart';
import 'package:vista/network/Utils.dart';
import 'package:vista/network/api_dialog.dart';
import 'package:vista/network/api_helper.dart';
import 'package:vista/utils/app_version_checker.dart';
import 'package:vista/vista/landing_screen.dart';
import 'package:vista/vista/vi_login_screen.dart';
class SplashScreen extends StatefulWidget{
  final String token;
  SplashScreen(this.token);

  splashState createState()=>splashState();
}
class splashState extends State<SplashScreen>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),

          Center(
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(top: 30,left: 25,right: 25),
              child: Center(
                child: Image.asset("assets/vista_logo.png"),
              ),
            ),
          )
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _checkUserConditions();

  }


  /*_checkUserConditions()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseUrl = prefs.getString('base_url') ?? '';
    String? empRoleId=prefs.getString("emp_role_id")??'1';
    String? clientCode=prefs.getString("client_code")??"";
    if(baseUrl!=''){
      if(widget.token!='')
      {
        Timer(
            Duration(seconds: 2),
                () =>
            empRoleId=="18"||empRoleId=="19"||empRoleId=="20"||empRoleId=="24"?
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => IssueAdminDashboard())):
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LandingScreen()))
        );
      }
      else{
        Timer(
            const Duration(seconds: 2),
                () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => ViLoginScreen())));
      }
    }else
    {
      _getClientInfo(context);
    }

  }*/



  _getClientInfo(BuildContext context) async{
    FocusScope.of(context).unfocus();
    APIDialog.showAlertDialog(context, 'Please wait...');
    var data = {
      "client_code": "VISTA",
    };
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPIClientInfo('client_info', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    String sMsg = responseJSON['message'].toString();
    int  sStatus = responseJSON['status'];
    if (sStatus!=1) {
      if(sMsg.contains("Client Code not found.")){
        APIDialog.showErrorDialog("Sorry! Organization code provided is not correct, Kindly contact your admin", context);
      }else{
        APIDialog.showErrorDialog(sMsg, context);
      }


    }else{
      String clientCode=responseJSON['data']['client_code'].toString();
      String clientName=responseJSON['data']['client_name'].toString();
      String baseUrl=responseJSON['data']['base_url'].toString();
      String createTask=responseJSON['data']['create_task'].toString();
      String assignTask=responseJSON['data']['assign_task'].toString();
      String editTask=responseJSON['data']['edit_task'].toString();
      _saveClientInfo(clientCode, clientName, baseUrl,createTask,assignTask,editTask);
    }
  }
  _saveClientInfo(String clientCode, String clientName,String baseUrl, String createTask,String assignTask,String editTask){
    MyUtils.saveSharedPreferences("base_url", baseUrl);
    MyUtils.saveSharedPreferences("client_name", clientName);
    MyUtils.saveSharedPreferences("client_code", clientCode);
    MyUtils.saveSharedPreferences("create_task", createTask);
    MyUtils.saveSharedPreferences("assign_task", assignTask);
    MyUtils.saveSharedPreferences("edit_task", editTask);
    _checkAppVersionAndProceed();
  }
  Future<void> _checkUserConditions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String baseUrl = prefs.getString('base_url') ?? '';

    if (baseUrl.isNotEmpty) {
      await _checkAppVersionAndProceed();
    } else {
      await _getClientInfo(context);
    }
  }
  Future<void> _checkAppVersionAndProceed() async {

    bool updateAvailable = await AppVersionChecker.checkForUpdate(context);

    if (!updateAvailable) {
      _navigateNext();
    }
  }
  Future<void> _navigateNext() async {

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();
    String empRoleId =
        prefs.getString("emp_role_id") ?? "1";
    if (widget.token.isNotEmpty) {
      Timer(
        const Duration(seconds: 2),
            () {

          if (empRoleId == "18" ||
              empRoleId == "19" ||
              empRoleId == "20" ||
              empRoleId == "24") {

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => IssueAdminDashboard(),
              ),
            );

          } else {

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LandingScreen(),
              ),
            );
          }
        },
      );

    } else {

      Timer(
        const Duration(seconds: 2),
            () {

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ViLoginScreen(),
            ),
          );
        },
      );
    }
  }

}