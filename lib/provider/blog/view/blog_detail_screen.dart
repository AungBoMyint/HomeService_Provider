import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/blog/blog_repository.dart';
import 'package:handyman_provider_flutter/provider/blog/component/blog_detail_header_component.dart';
import 'package:handyman_provider_flutter/provider/blog/model/blog_detail_response.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  BlogDetailScreen({required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
  }

  Widget buildBodyWidget(AsyncSnapshot<BlogDetailResponse> snap) {
    if (snap.hasData) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlogDetailHeaderComponent(blogData: snap.data!.blogDetail!),
            16.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snap.data!.blogDetail!.title.validate(), style: boldTextStyle(size: 24)),
                8.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text('${languages!.authorBy}: ', style: secondaryTextStyle()),
                        Text(snap.data!.blogDetail!.authorName.validate(), style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ).expand(),
                    if (snap.data!.blogDetail!.totalViews != 0)
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye, size: 24, color: context.iconColor),
                          8.width,
                          Text('${snap.data!.blogDetail!.totalViews.validate()} ', style: boldTextStyle()),
                          Text(languages!.views, style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                  ],
                ),
                if (snap.data!.blogDetail!.createdAt.validate().isNotEmpty)
                  Column(
                    children: [
                      8.height,
                      Row(
                        children: [
                          Text('${languages!.published}: ', style: secondaryTextStyle()),
                          Text(snap.data!.blogDetail!.createdAt.validate(), style: primaryTextStyle(size: 14), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                        ],
                      ),
                    ],
                  ),
                12.height,
                Text(snap.data!.blogDetail!.description.validate(), style: primaryTextStyle(color: textSecondaryColorGlobal)),
              ],
            ).paddingSymmetric(horizontal: 16)
          ],
        ),
      );
    }

    return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BlogDetailResponse>(
      future: getBlogDetailAPI({AddBlogKey.blogId: widget.blogId.validate()}),
      builder: (context, snap) {
        return Scaffold(
          body: buildBodyWidget(snap),
          floatingActionButton: (snap.hasData && snap.data!.blogDetail!.isFeatured.validate(value: 0) == 1)
              ? FloatingActionButton(
                  elevation: 0.0,
                  child: Image.asset(featured, height: 22, width: 22, color: white),
                  backgroundColor: context.primaryColor,
                  onPressed: () {
                    toast(languages!.lblFeatureProduct);
                  },
                )
              : Offstage(),
        );
      },
    );
  }
}
