import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/service_widget.dart';
import 'package:handyman_provider_flutter/provider/services/add_services.dart';
import 'package:handyman_provider_flutter/provider/services/service_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceListScreen extends StatefulWidget {
  final int? categoryId;
  final String categoryName;

  ServiceListScreen({this.categoryId, this.categoryName = ''});

  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  ScrollController scrollController = ScrollController();

  TextEditingController searchList = TextEditingController();

  int page = 1;
  int providerId = 0;
  int? categoryId = 0;

  List<ServiceData> services = [];

  bool changeList = false;

  bool isEnabled = false;
  bool isLastPage = false;
  bool isApiCalled = false;

  Future<List<ServiceData>>? future;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isLastPage) {
          page++;
          init();
        }
      }
    });
  }

  Future<void> init() async {
    //afterBuildCreated(() => appStore.setLoading(true));
    future = getSearchList(page, search: searchList.text, providerId: appStore.userId, services: services, lastPageCallback: (b) {
      isLastPage = b;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.categoryName.isEmpty ? languages!.lblAllService : widget.categoryName.validate(),
        textColor: white,
        color: context.primaryColor,
        backWidget: BackWidget(),
        actions: [
          IconButton(
            onPressed: () {
              changeList = !changeList;
              setState(() {});
            },
            icon: Image.asset(changeList ? list : grid, height: 20, width: 20),
          ),
          IconButton(
            onPressed: () async {
              bool? res;

              res = await AddServices().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);

              if (res ?? false) {
                appStore.setLoading(true);
                page = 1;
                init();
              }
            },
            icon: Icon(Icons.add, size: 28, color: white),
            tooltip: languages!.hintAddService,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          init();
          setState(() {});
        },
        child: SizedBox(
          width: context.width(),
          height: context.height(),
          child: Stack(
            children: [
              SnapHelperWidget<List<ServiceData>>(
                future: future,
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    retryText: languages!.tryAgain,
                    onRetry: () {
                      page = 1;
                      init();
                      setState(() {});
                    },
                  );
                },
                loadingWidget: LoaderWidget(),
                onSuccess: (list) {

                  if (list.isEmpty) {
                    return BackgroundComponent(text: languages!.noServiceFound, subTitle: languages!.noServiceSubTitle);
                  }

                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        AppTextField(
                          textFieldType: TextFieldType.OTHER,
                          controller: searchList,
                          onFieldSubmitted: (s) {
                            page = 1;
                            init();
                          },
                          decoration: InputDecoration(
                            hintText: languages!.lblSearchHere,
                            prefixIcon: Icon(Icons.search, color: context.iconColor, size: 20),
                            hintStyle: secondaryTextStyle(),
                            border: OutlineInputBorder(
                              borderRadius: radius(8),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            fillColor: appStore.isDarkMode ? cardDarkColor : cardColor,
                          ),
                        ).paddingOnly(left: 16, right: 16, top: 24, bottom: 8),

                        if (services.isNotEmpty)
                          Container(
                            alignment: Alignment.topLeft,
                            child: AnimatedWrap(
                              spacing: 16.0,
                              runSpacing: 16.0,
                              scaleConfiguration: ScaleConfiguration(duration: 400.milliseconds, delay: 50.milliseconds),
                              listAnimationType: ListAnimationType.Scale,
                              alignment: WrapAlignment.start,
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                return ServiceComponent(
                                  data: services[index],
                                  width: changeList ? context.width() : context.width() * 0.5 - 24,
                                ).onTap(() async {
                                  await ServiceDetailScreen(serviceId: services[index].id.validate()).launch(context);
                                }, borderRadius: radius());
                              },
                            ).paddingSymmetric(horizontal: 16, vertical: 24),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
