import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/blog/blog_repository.dart';
import 'package:handyman_provider_flutter/provider/blog/component/blog_item_component.dart';
import 'package:handyman_provider_flutter/provider/blog/model/blog_response_model.dart';
import 'package:handyman_provider_flutter/provider/blog/view/add_blog_screen.dart';
import 'package:nb_utils/nb_utils.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  Future<List<BlogData>>? future;

  List<BlogData> blogList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      appStore.setLoading(true);
    });
  }

  void init() async {
    future = getBlogListAPI(
      blogData: blogList,
      page: page,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages!.blogs,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 28, color: white),
            tooltip: languages!.addBlog,
            onPressed: () async {
              bool? res;

              res = await AddBlogScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);

              if (res ?? false) {
                appStore.setLoading(true);
                page = 1;
                init();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<BlogData>>(
            future: future,
            loadingWidget: LoaderWidget(),
            errorBuilder: (error) {
              return NoDataWidget(
                title: error.toString().isNotEmpty ? error.toString() : errorSomethingWentWrong,
                retryText: languages!.tryAgain,
                onRetry: () {
                  page = 1;
                  init();
                  setState(() {});
                },
              );
            },
            onSuccess: (snap) {
              if (snap.isEmpty) return BackgroundComponent(text: languages!.noBlogsFound);

              return AnimatedListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                itemCount: snap.length,
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    init();
                    setState(() {});
                  }
                },
                disposeScrollController: false,
                itemBuilder: (BuildContext context, index) {
                  BlogData data = snap[index];

                  return BlogItemComponent(
                    blogData: data,
                    callBack: () {
                      page = 1;
                      init();
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading && page != 1))
        ],
      ),
    );
  }
}
