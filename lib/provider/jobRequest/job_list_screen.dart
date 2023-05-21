import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:nb_utils/nb_utils.dart';

import 'components/job_item_widget.dart';
import 'models/post_job_data.dart';

class JobListScreen extends StatefulWidget {
  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  late Future<List<PostJobData>> future;
  List<PostJobData> myPostJobList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getPostJobList(page, postJobList: myPostJobList, lastPageCallback: (val) => isLastPage = val);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        page = 1;
        init();
        return await 2.seconds.delay;
      },
      child: Scaffold(
        appBar: appBarWidget(languages!.jobRequestList, color: context.primaryColor, textColor: Colors.white, backWidget: BackWidget()),
        body: Stack(
          children: [
            SnapHelperWidget<List<PostJobData>>(
              future: future,
              onSuccess: (data) {
                if (data.isEmpty) {
                  return BackgroundComponent(text: languages!.noDataFound).center();
                }

                return AnimatedListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  itemCount: data.validate().length,
                  shrinkWrap: true,
                  itemBuilder: (_, i) => JobItemWidget(data: data[i]),
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      init();
                    }
                  },
                );
              },
              loadingWidget: LoaderWidget(),
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading && page != 1)),
          ],
        ),
      ),
    );
  }
}
