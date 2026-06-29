import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vista/help/raised_issuelist_screen.dart';
import 'package:vista/issue_admin/escalation_list_screen.dart';
import 'package:vista/issue_admin/list_offissues_page.dart';
import 'package:vista/main.dart';
import 'package:vista/network/constants.dart';
import 'package:vista/vista/calendraview_screen.dart';
import 'package:flutter/material.dart';

class NotificationService {

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

   AndroidNotificationChannel channel =
  AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  Future<void> initialize() async {

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _messaging.getToken();

    print("FCM Token => $token");

    await _initializeLocalNotifications();

    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        print("Foreground Notification");
        _showNotification(message);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        _handleNavigation(message.data);
      },
    );

    RemoteMessage? initialMessage =
    await _messaging.getInitialMessage();

    if (initialMessage != null) {

      _handleNavigation(initialMessage.data);
    }
  }
  void _handleNavigation(Map<String, dynamic> data)async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token') ?? '';
    print('**********************Notification: $data');
    String type = data["notification_type"] ?? "";
    if(token.isNotEmpty){
      if(type==AppConstant.NOTI_CHECKLIST_ASSIGNED ||type==AppConstant.NOTI_CHECKLIST_UPDATED || type==AppConstant.NOTI_CHECKLIST_DUE_REMINDER ){
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => CalendraViewScreen("0"),),);
      }else if(type==AppConstant.NOTI_CHECKLIST_COMPLETED ){
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => CalendraViewScreen("1"),),);
      }else if(type==AppConstant.NOTI_ARL_ALERT || type==AppConstant.NOTI_TL_ALERT){
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => EscalationListScreen(),),);
      }else if(type==AppConstant.NOTI_TICKET_CREATED || type==AppConstant.NOTI_TICKET_ASSIGNED ){
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => ListOfIssuesPage(title: "Open Issues"),),);
      }else if (type==AppConstant.NOTI_TICKET_RESOLVED ||type==AppConstant.NOTI_TICKET_CLOSED){
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => RaisedIssuePage(),),);
      }
    }
  }
  Future<void> _initializeLocalNotifications() async {

    const AndroidInitializationSettings
    androidSettings =
    AndroidInitializationSettings(
        '@mipmap/ic_launcher');

    const DarwinInitializationSettings
    iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings
    settings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin
        .initialize(
      settings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {

        if (response.payload != null) {

          Map<String, dynamic> data =
          jsonDecode(response.payload!);

          _handleNavigation(data);
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  Future<void> _showNotification(
      RemoteMessage message) async {
    RemoteNotification? notification =
        message.notification;
    if (notification == null) return;
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,

      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),

      payload: jsonEncode(message.data),
    );
  }
}