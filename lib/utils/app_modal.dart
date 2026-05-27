
class AppModel{


  static bool isLogin=false;
  static String token='';
  static String userID='';
  static String temFilePath='';


  static bool setLoginToken(bool value)
  {
    isLogin=value;
    return isLogin;
  }
  static String setTokenValue(String value)
  {
    token=value;
    return token;
  }

  static String setTempFilePath(String value)
  {
    temFilePath=value;
    return temFilePath;
  }
  static String setUserID(String id)
  {
    userID=id;
    return userID;
  }


}
