import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vista/views/splash_screen.dart';

class MyUtils
{
  static Future<Null> saveSharedPreferences(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
    return null;
  }

  static Future<String?> getSharedPreferences(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? value =  preferences.getString(key);
    return value;
  }
  static Future<Null> saveUserDetails(String userId, String name,String mobileNo,String language,String empRoleId,String token,String shiftId,String userRole) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("user_id", userId);
    preferences.setString("name", name);
    preferences.setString("mobile_no", mobileNo);
    preferences.setString("language", language);
    preferences.setString("emp_role_id", empRoleId);
    preferences.setString("token",token);
    preferences.setString("emp_shift_id",shiftId);
    preferences.setString("user_role",userRole);
    return null;
  }
  static Future<Null> logoutUser(BuildContext context)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("user_id");
    await preferences.remove("name");
    await preferences.remove("mobile_no");
    await preferences.remove("language");
    await preferences.remove("emp_role_id");
    await preferences.remove("token");
    await preferences.remove("emp_shift_id");
    await preferences.remove("user_role");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen("")),
            (Route<dynamic> route) => false);

    return null;
  }

}