import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/components/notification_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/app_widgets.dart';
import '../models/notification_response.dart';

class NotificationFragment extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationFragment> {
  late Future<NotificationResponse> future;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getNotification({NotificationKey.type: ""});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> readNotification({String? id}) async {
    Map request = {CommonKeys.bookingId: id};

    //appStore.setLoading(true);

    await bookingDetail(request).then((value) {
      init();
    }).catchError((e) {
      log(e.toString());
    });

    //appStore.setLoading(false);
  }

  Widget listIterate(List<NotificationData> list) {
    return AnimatedListView(
      shrinkWrap: true,
      itemCount: list.length,
      padding: EdgeInsets.all(8),
      physics: NeverScrollableScrollPhysics(),
      slideConfiguration: SlideConfiguration(duration: 400.milliseconds, delay: 50.milliseconds),
      itemBuilder: (context, index) {
        NotificationData data = list[index];

        return GestureDetector(
          onTap: () async {
            if (data.data!.type != ADD_WALLET && data.data!.type != UPDATE_WALLET && data.data!.type != WALLET_PAYOUT_TRANSFER && data.data!.type == PAYOUT) {
              readNotification(id: data.data!.id.toString());
            } else if (isUserTypeHandyman) {
              if (data.data!.notificationType.validate() == NOTIFICATION_TYPE_BOOKING) {
                readNotification(id: data.data!.id.toString());
                BookingDetailScreen(bookingId: data.data!.id).launch(context);
              } else {
                //
              }
            } else if (isUserTypeProvider) {
              if (data.data!.type != ADD_WALLET && data.data!.type != UPDATE_WALLET && data.data!.type != WALLET_PAYOUT_TRANSFER) {
                if (data.data!.notificationType.validate() == NOTIFICATION_TYPE_BOOKING) {
                  readNotification(id: data.data!.id.toString());
                  BookingDetailScreen(bookingId: data.data!.id).launch(context);
                } else if (data.data!.notificationType.validate() == NOTIFICATION_TYPE_POST_JOB) {
                  //
                } else {
                  //
                }
              } else {
                init();
              }
            }
          },
          child: NotificationWidget(data: data),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navigator.canPop(context)
          ? appBarWidget(
              languages!.notification,
              showBack: true,
              textColor: white,
              elevation: 0.0,
              color: context.primaryColor,
              backWidget: BackWidget(),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          init();
          return await 2.seconds.delay;
        },
        child: SnapHelperWidget<NotificationResponse>(
          future: future,
          loadingWidget: LoaderWidget(),
          onSuccess: (res) {
            if (res.unReadNotificationList!.isEmpty && res.readNotificationList!.isEmpty)
              return BackgroundComponent(
                text: languages!.noNotificationTitle,
                subTitle: languages!.noNotificationSubTitle,
              );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Column(
                children: [
                  if (res.unReadNotificationList!.isNotEmpty)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(languages!.lblUnreadNotification, style: boldTextStyle(color: appStore.isDarkMode ? white : black, size: LABEL_TEXT_SIZE)).expand(),
                            TextButton(
                              child: Text(languages!.lblMarkAllAsRead, style: primaryTextStyle(size: 12)),
                              onPressed: () async {
                                appStore.setLoading(true);

                                await getNotification({NotificationKey.type: MARK_AS_READ}).then((value) {
                                  init();
                                }).catchError((e) {
                                  log(e.toString());
                                });

                                appStore.setLoading(false);
                              },
                            )
                          ],
                        ),
                        listIterate(res.unReadNotificationList!),
                      ],
                    ).paddingAll(8),
                  16.height,
                  if (res.readNotificationList!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages!.notification, style: boldTextStyle(color: appStore.isDarkMode ? white : black, size: LABEL_TEXT_SIZE)).paddingAll(8),
                        8.height,
                        listIterate(res.readNotificationList!),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
