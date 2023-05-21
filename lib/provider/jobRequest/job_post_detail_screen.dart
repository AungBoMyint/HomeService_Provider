import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/bid_price_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import 'models/bidder_data.dart';
import 'models/post_job_data.dart';

class JobPostDetailScreen extends StatefulWidget {
  final PostJobData postJobData;

  JobPostDetailScreen({required this.postJobData});

  @override
  _JobPostDetailScreenState createState() => _JobPostDetailScreenState();
}

class _JobPostDetailScreenState extends State<JobPostDetailScreen> {
  late Future<PostJobDetailResponse> future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getPostJobDetail({PostJob.postRequestId: widget.postJobData.id.validate()});
  }

  Widget titleWidget({required String title, required String detail, bool isReadMore = false, required TextStyle detailTextStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.validate(), style: secondaryTextStyle()),
        8.height,
        if (isReadMore) ReadMoreText(detail, style: detailTextStyle) else Text(detail.validate(), style: detailTextStyle),
        16.height,
      ],
    );
  }

  Widget postJobDetailWidget({required PostJobData data}) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.title.validate().isNotEmpty)
            titleWidget(
              title: languages!.postJobTitle,
              detail: data.title.validate(),
              detailTextStyle: boldTextStyle(),
            ),
          if (data.description.validate().isNotEmpty)
            titleWidget(
              title: languages!.postJobDescription,
              detail: data.description.validate(),
              detailTextStyle: primaryTextStyle(),
              isReadMore: true,
            ),
          Text(data.status.validate() == JOB_REQUEST_STATUS_ACCEPTED ? languages!.jobPrice : languages!.estimatedPrice, style: secondaryTextStyle()),
          8.height,
          PriceWidget(
            price: data.status.validate() == JOB_REQUEST_STATUS_ACCEPTED ? data.jobPrice.validate() : data.price.validate(),
            isHourlyService: false,
            color: textPrimaryColorGlobal,
            isFreeService: false,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget postJobServiceWidget({required List<ServiceData> serviceList}) {
    if (serviceList.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Text(languages!.lblServices, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingOnly(left: 16, right: 16),
        AnimatedListView(
          itemCount: serviceList.length,
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.imageAttachments.validate().isNotEmpty ? data.imageAttachments!.first.validate() : "",
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(data.name.validate(), style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget providerWidget(List<BidderData> bidderList) {
    try {
      BidderData? bidderData = bidderList.firstWhere((element) => element.providerId == appStore.userId);
      UserData? user = bidderData.provider;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Text(languages!.myBid, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          Container(
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(16))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CachedImageWidget(
                      url: user!.profileImage.validate(),
                      fit: BoxFit.cover,
                      height: 60,
                      width: 60,
                      circle: true,
                    ),
                    16.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName.validate(),
                          style: boldTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.height,
                        PriceWidget(price: bidderData.price.validate()),
                      ],
                    ).expand(),
                  ],
                ),
              ],
            ),
          ),
          16.height,
        ],
      ).paddingOnly(left: 16, right: 16);
    } catch (e) {
      print(e);
    }

    return Offstage();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        init();
        setState(() {});
        return await 2.seconds.delay;
      },
      child: Scaffold(
        appBar: appBarWidget(
          '${widget.postJobData.title}',
          textColor: white,
          color: context.primaryColor,
        ),
        body: SnapHelperWidget<PostJobDetailResponse>(
          future: future,
          onSuccess: (data) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 60),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      postJobDetailWidget(data: data.postRequestDetail!).paddingAll(16),
                      providerWidget(data.bidderData.validate()),
                      postJobServiceWidget(serviceList: data.postRequestDetail!.service.validate()),
                    ],
                  ),
                ).makeRefreshable,
                if (data.postRequestDetail!.canBid.validate())
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: AppButton(
                      child: Text(languages!.bid, style: boldTextStyle(color: white)),
                      color: context.primaryColor,
                      width: context.width(),
                      onTap: () async {
                        bool? res = await showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          hideSoftKeyboard: true,
                          backgroundColor: context.cardColor,
                          builder: (_) => BidPriceDialog(data: widget.postJobData),
                        );

                        if (res ?? false) {
                          init();
                          setState(() {});
                        }
                      },
                    ),
                  ),
              ],
            );
          },
          loadingWidget: LoaderWidget(),
        ),
      ),
    );
  }
}
