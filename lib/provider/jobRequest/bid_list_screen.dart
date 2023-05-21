import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/background_component.dart';
import 'components/job_item_widget.dart';
import 'models/bidder_data.dart';

class BidListScreen extends StatefulWidget {
  @override
  _BidListScreenState createState() => _BidListScreenState();
}

class _BidListScreenState extends State<BidListScreen> {
  late Future<List<BidderData>> future;
  List<BidderData> bidList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getBidList(
      page: page,
      bidList: bidList,
      lastPageCallback: (val) {
        isLastPage = val;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages!.bidList,
        textColor: white,
        showBack: true,
        backWidget: BackWidget(),
        color: context.primaryColor,
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<BidderData>>(
            future: future,
            onSuccess: (data) {
              if (data.isEmpty) {
                return BackgroundComponent(text: languages!.noDataFound).center();
              }
              return AnimatedListView(
                itemCount: data.validate().length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                itemBuilder: (_, i) => JobItemWidget(data: data[i].postJobData),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    init();

                    setState(() {});
                  }
                },
              );
            },
            loadingWidget: LoaderWidget(),
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading && page != 1))
        ],
      ),
    );
  }
}
