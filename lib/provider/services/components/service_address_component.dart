import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceAddressComponent extends StatefulWidget {
  final List<int>? selectedList;
  final Function(List<int> val) onSelectedList;

  ServiceAddressComponent({this.selectedList, required this.onSelectedList});

  @override
  State<ServiceAddressComponent> createState() => _ServiceAddressComponentState();
}

class _ServiceAddressComponentState extends State<ServiceAddressComponent> {
  List<AddressResponse> addressList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getServiceAddresses();
  }

  Future<void> getServiceAddresses() async {
    await getAddresses(providerId: appStore.userId).then((value) {
      addressList = value.addressResponse.validate();

      if (widget.selectedList != null) {
        addressList.forEach((element) {
          log("${element.id}" + "${element.address.validate()}");

          element.isSelected = widget.selectedList!.contains(element.id.validate());
        });

        widget.onSelectedList.call(addressList.where((element) => element.isSelected == true).map((e) => e.id.validate()).toList());
      }

      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius(),
        color: context.scaffoldBackgroundColor,
        // border: Border.all(color: addressList.where((element) => element.isSelected == true).isEmpty ? Colors.red : Colors.transparent),
      ),
      child: ExpansionTile(
        iconColor: context.iconColor,
        initiallyExpanded: widget.selectedList.validate().isNotEmpty,
        title: Text(languages!.selectAddress, style: secondaryTextStyle()),
        trailing: Icon(Icons.arrow_drop_down),
        children: List.generate(
          addressList.length,
          (index) {
            AddressResponse data = addressList[index];
            bool isSelected = data.isSelected.validate();
            return Container(
              margin: EdgeInsets.only(bottom: 8.0),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  addressList[index].address.validate(),
                  style: secondaryTextStyle(color: context.iconColor),
                ),
                autofocus: false,
                activeColor: primaryColor,
                checkColor: context.cardColor,
                value: isSelected,
                onChanged: (bool? val) {
                  data.isSelected = !data.isSelected.validate();
                  widget.onSelectedList.call(addressList.where((element) => element.isSelected == true).map((e) => e.id.validate()).toList());

                  setState(() {});
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
