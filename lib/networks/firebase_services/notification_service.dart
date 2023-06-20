import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constant.dart';
import '../../utils/key.dart';

class NotificationService {
  //---------------Sent To Specific User about Booking------//
  Future<void> sendPushToUser(
    String title,
    String content, {
    required String receiverPlayerID,
    required Map<String, dynamic> data,
  }) async {
    log("-----------------Notificatoin Content: $content \n User Player ID: $receiverPlayerID");
    /* Map req = {
      'headings': {
        'en': '$title',
      },
      'contents': {
        'en': content,
      },
      "language": "en",
      'small_icon': appLogo,
      'data': data,
      'android_visibility': 1,
      'app_id':
          getStringAsync(ONESIGNAL_API_KEY, defaultValue: ONESIGNAL_APP_ID),
      'android_channel_id': getStringAsync(ONESIGNAL_CHANNEL_KEY,
          defaultValue: ONESIGNAL_CHANNEL_ID),
      "include_player_ids": [receiverPlayerID],
    };

    log(req);
    var header = {
      HttpHeaders.authorizationHeader:
          'Basic ${getStringAsync(ONESIGNAL_REST_API_KEY, defaultValue: ONESIGNAL_REST_KEY)}',
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };

    log("===============Pushing Noti To Provider========");

    Response res = await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      body: jsonEncode(req),
      headers: header,
    );

    log(res.statusCode);
    log(res.body);

    if (res.statusCode.isSuccessful()) {
      log("==================Notification Push Successful=================");
    } else {
      throw errorSomethingWentWrong;
    }*/
    final jsonBody = <String, dynamic>{
      "notification": <String, dynamic>{
        "title": title,
        "body": content,
      },
      "data": <String, dynamic>{
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "bookingId": data["id"],
      },
      "to": receiverPlayerID,
    };
    var res = await Dio().post("https://fcm.googleapis.com/fcm/send",
        data: jsonBody,
        options: Options(headers: {
          "Authorization": "key=$fcmKey",
          "Content-Type": "application/json"
        }));

    log(res.statusCode);

    if (res.statusCode.isSuccessful()) {
      log("==================Notification Push Successful=================");
    } else {
      throw errorSomethingWentWrong;
    }
  }
}
