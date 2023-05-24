import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/dashed_rect.dart';
import 'package:handyman_provider_flutter/utils/extensions/color_extension.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingHistoryListWidget extends StatelessWidget {
  const BookingHistoryListWidget(
      {Key? key, required this.data, required this.index, required this.length})
      : super(key: key);

  final BookingActivity data;
  final int index;
  final int length;

  @override
  Widget build(BuildContext context) {
    var activityM = "";
    final json = data.toJson();
    final activityMessage = data.activityMessage;
    if (activityMessage == "Booking status has been changed from  to .") {
      var oldStatus = "";
      var newStatus = "";
      final Map activityData = jsonDecode(json["activity_data"]) as Map;
      if (activityData.containsKey("old_status") &&
          activityData.containsKey("status")) {
        oldStatus = activityData["old_status"];
        newStatus = activityData["status"];
      }
      activityM =
          "Booking status has been changed from $oldStatus to $newStatus .";
    } else {
      log("Activity Message: False");
      activityM = activityMessage ?? "";
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            data.datetime.toString().validate().isNotEmpty
                ? Text(
                    formatDate(data.datetime.toString().validate(),
                        format: DATE_FORMAT_3),
                    style: secondaryTextStyle(),
                  ).fit()
                : SizedBox(),
            8.height,
            data.datetime.toString().validate().isNotEmpty
                ? Text(
                    formatDate(data.datetime.toString().validate(),
                        format: DATE_FORMAT_4),
                    style: primaryTextStyle(size: 14),
                  )
                : SizedBox(),
          ],
        ).withWidth(55),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color:
                    data.activityType.validate().getBookingActivityStatusColor,
                borderRadius: radius(16),
              ),
            ),
            SizedBox(
              height: 65,
              child: DashedRect(
                  gap: 3,
                  color: data.activityType
                      .validate()
                      .getBookingActivityStatusColor,
                  strokeWidth: 1.5),
            ).visible(index != length - 1),
          ],
        ),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextIcon(
              expandedText: true,
              edgeInsets: EdgeInsets.only(right: 4, left: 4, bottom: 4),
              text: data.activityType
                  .validate()
                  .replaceAll('_', ' ')
                  .capitalizeFirstLetter(),
            ),
            Text(
              activityM.validate().replaceAll('_', ' ').capitalizeFirstLetter(),
              style: secondaryTextStyle(),
            ).paddingOnly(left: 4),
          ],
        ).paddingOnly(bottom: 18).expand()
      ],
    );
  }
}
