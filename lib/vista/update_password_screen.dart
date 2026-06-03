import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vista/network/Utils.dart';
import 'package:vista/network/api_dialog.dart';
import 'package:vista/network/api_helper.dart';
import 'package:vista/utils/app_theme.dart';
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}
class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
  TextEditingController();
  final TextEditingController newPasswordController =
  TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool hideCurrentPassword = true;
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  var sRemeberToken="";
  var sUserId="";
  var baseUrl="";

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.trim().length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }
  Future<void> updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      APIDialog.showErrorDialog("New password and confirm password do not match", context);
      return;
    }

    if (currentPasswordController.text.trim() ==
        newPasswordController.text.trim()) {
      APIDialog.showErrorDialog("New password must be different from current password", context);

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var data = {
        "auth_key": sRemeberToken,
        "user_id": sUserId,
        "old_password":currentPasswordController.text,
        "new_password":newPasswordController.text,
        "confirm_password":confirmPasswordController.text,
      };
      ApiBaseHelper helper = ApiBaseHelper();
      var response = await helper.postAPI(baseUrl,'vi_change_password', data, context);
      var responseJSON = json.decode(response.body);
      print(responseJSON);

      if(responseJSON['status']!=null && responseJSON['status']==1){
        String message=responseJSON['message']?.toString()??"Password changed successfully.";
        APIDialog.showResponseDialog(message, context);
        currentPasswordController.text="";
        newPasswordController.text="";
        confirmPasswordController.text="";

      }else{
        String message=responseJSON['message']?.toString()??"Something went wrong. Please try again later";
        APIDialog.showErrorDialog(message, context);
      }




    } catch (e) {
      APIDialog.showErrorDialog("Something went wrong. Please Try again", context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Widget passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: passwordValidator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppTheme.themeColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Update Password",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Icon(
                      Icons.lock_reset,
                      size: 60,
                      color: AppTheme.themeColor,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Change Your Password",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    passwordField(
                      label: "Current Password",
                      hint: "Enter current password",
                      controller: currentPasswordController,
                      obscureText: hideCurrentPassword,
                      onToggle: () {
                        setState(() {
                          hideCurrentPassword =
                          !hideCurrentPassword;
                        });
                      },
                    ),

                    passwordField(
                      label: "New Password",
                      hint: "Enter new password",
                      controller: newPasswordController,
                      obscureText: hideNewPassword,
                      onToggle: () {
                        setState(() {
                          hideNewPassword = !hideNewPassword;
                        });
                      },
                    ),

                    passwordField(
                      label: "Confirm Password",
                      hint: "Re-enter new password",
                      controller: confirmPasswordController,
                      obscureText: hideConfirmPassword,
                      onToggle: () {
                        setState(() {
                          hideConfirmPassword =
                          !hideConfirmPassword;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                        isLoading ? null : updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppTheme.themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "UPDATE PASSWORD",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    setState(() {
    });

  }
}