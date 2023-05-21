import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:nb_utils/nb_utils.dart';

class SlotsComponent extends StatefulWidget {
  final List<String> timeSlotList;

  SlotsComponent({required this.timeSlotList});

  @override
  SlotsComponentState createState() => SlotsComponentState();
}

class SlotsComponentState extends State<SlotsComponent> {
  int selectTimeSlotIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Container(
          width: context.width(),
          padding: EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(languages!.lblTime, style: boldTextStyle()).paddingOnly(top: 8, bottom: 16, left: 8, right: 16),
              widget.timeSlotList.isNotEmpty
                  ? Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.timeSlotList.map((slot) {
                        return Container(
                          alignment: Alignment.center,
                          width: context.width() / 3 - 24,
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          padding: EdgeInsets.only(top: 12, bottom: 12, left: 8, right: 8),
                          child: Text(
                            slot.validate().splitBefore(':'),
                            style: boldTextStyle(),
                          ),
                        ).onTap(() {
                          //selectTimeSlotIndex = index;
                          setState(() {});
                        });
                      }).toList(),
                    )
                  : Text(languages!.noSlotsAvailable, style: secondaryTextStyle()).paddingAll(16).center(),
            ],
          ),
        ).visible(!appStore.isLoading);
      },
    );
  }
}
