import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vista/utils/app_modal.dart';
import 'package:vista/vista/vi_login_screen.dart';
import 'app_exceptions.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

class ApiBaseHelper {
  final String _baseUrl = AppConstant.appBaseURL;
  final String _clientBaseUrl=AppConstant.clientInfoUrl;
  Future<dynamic> get(String url, BuildContext context) async {
    var responseJson;
    print(url+'  API CALLED');
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept':'application/json',
        'X-Requested-With':'XMLHttpRequest'
      });
      var decodedJson=jsonDecode(response.body.toString());
      print(decodedJson);

      responseJson = _returnResponse(response, context);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }


  Future<dynamic> getWithToken(String baseUrl,String url,String token, BuildContext context) async {
    var responseJson;
    print(baseUrl+url+'  API CALLED');
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        'Content-Type': 'application/json',
        'Accept':'application/json',
        'X-Requested-With':'XMLHttpRequest',
        'x-auth-token':token
      });
      var decodedJson=jsonDecode(response.body.toString());
      print(decodedJson);

      responseJson = _returnResponse(response, context);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
  Future<dynamic> postAPIClientInfo(
      String url, var apiParams, BuildContext context) async {
    print("API CALLED");
    print(_clientBaseUrl + url);
    print(apiParams.toString());

    var responseJson;
    try {
      final response = await http.post(Uri.parse(_clientBaseUrl + url),
          body: json.encode(apiParams),
          headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
            'X-Requested-With':'XMLHttpRequest'
          }
      );
      var decodedJson=jsonDecode(response.body.toString());
      print(decodedJson);

      if(decodedJson["message"]=="User not found")
      {
        _logOut(context);
      }
      else
      {
        responseJson = _returnResponse(response, context);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
  Future<dynamic> postAPI(String baseUrl,
      String url, var apiParams, BuildContext context) async {
    print("API CALLED");
    print(baseUrl + url);
    print(apiParams.toString());
    print(json.encode(apiParams));

    var responseJson;
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          body: json.encode(apiParams),
          headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
            'X-Requested-With':'XMLHttpRequest'
          }
          );
      var decodedJson=jsonDecode(response.body.toString());
      print(decodedJson);

      if(decodedJson["message"]=="User not found")
      {
        _logOut(context);
      }
      else
      {
        responseJson = _returnResponse(response, context);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> postAPIWithHeader(String url, var apiParams, BuildContext context) async {
    print(_baseUrl+url+'  API CALLED');
    print("Token");
    print(AppModel.token);
    print(apiParams.toString());
    var responseJson;
    try {
      final response = await http.post(Uri.parse(_baseUrl + url),
          body: json.encode(apiParams),
          headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
            'Authorization':AppModel.token
          }
      );
      var decodedJson=jsonDecode(response.body.toString());
      print(decodedJson);

      if(decodedJson["message"]=="User not found")
      {
        _logOut(context);
      }
      else
      {
        responseJson = _returnResponse(response, context);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }


  Future<dynamic> postAPIWithHeaderProd(String url, var apiParams, BuildContext context) async {
    print(AppConstant.productionBaseUrl+url+'  API CALLED');
    print("Token");
    print(AppModel.token);
    print(apiParams.toString());
    var responseJson;
    try {
      final response = await http.post(Uri.parse(AppConstant.productionBaseUrl + url),
          body: json.encode(apiParams),
          headers: {
             'Content-Type': 'application/json',
            'Accept':'application/json',
            'Authorization':AppModel.token
          }
      );
      var decodedJson=jsonDecode(response.body.toString());
      print(decodedJson);

      if(decodedJson["message"]=="User not found")
        {
          _logOut(context);
        }
      else
        {
          responseJson = _returnResponse(response, context);
        }

    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }




  Future<dynamic> aadhaarOTPAPI(String url, var apiParams, BuildContext context,String authKey) async {
    print(url+'  API CALLED');
    print(apiParams.toString());
    var responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode(apiParams),
          headers: {
             'Content-Type': 'application/json',
            'Accept':'application/json',
            'Authorization':authKey
          }
      ).timeout(Duration(seconds: 8));
      var decodedJson=jsonDecode(response.body.toString());
      print(decodedJson);

      responseJson = _returnResponse(response, context);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }





  dynamic _returnResponse(http.Response response, BuildContext context) {
   // var responseJson = jsonDecode(response.body.toString());
    print(response.statusCode.toString() +'Status Code******* ');

   // log('api helper response $response');
    switch (response.statusCode) {
      case 200:
        log(response.body.toString());
        return response;
      case 302:
        print(response.body.toString());
        return response;
      case 201:
        print(response.body.toString());
        return response;
      case 400:
        print(response.body.toString());
        return response;
      case 404:
        print(response.body.toString());
        return response;
      case 401:
        Toast.show('Unauthorized User!!',
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundColor: Colors.black);
        print(response.body.toString());
        return response;
      case 403:
        Toast.show('Internal server error !!',
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundColor: Colors.black);
        _logOut(context);
        throw UnauthorisedException(response.body.toString());
      case 500:
        Toast.show('Internal server error!!',
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundColor: Colors.black);
        break;
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
  _logOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    Toast.show("Your session has expired, Please login again",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
        backgroundColor: Colors.blue);


    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ViLoginScreen()),
            (Route<dynamic> route) => false);
  }
}
