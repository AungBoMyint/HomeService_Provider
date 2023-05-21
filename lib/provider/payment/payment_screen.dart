import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/provider/payment/components/cinet_pay_services.dart';
import 'package:handyman_provider_flutter/provider/payment/components/flutter_wave_services.dart';
import 'package:handyman_provider_flutter/provider/payment/components/razor_pay_services.dart';
import 'package:handyman_provider_flutter/provider/payment/components/sadad_services.dart';
import 'package:handyman_provider_flutter/provider/payment/components/stripe_services.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentScreen extends StatefulWidget {
  final ProviderSubscriptionModel selectedPricingPlan;

  const PaymentScreen(this.selectedPricingPlan);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  RazorPayServices razorPayServices = RazorPayServices();

  List<PaymentSetting> paymentList = [];

  PaymentSetting? currentTimeValue;

  bool isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    paymentList = PaymentSetting.decode(getStringAsync(PAYMENT_LIST));
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_COD);
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_PAYPAL);

    if (paymentList.isNotEmpty) {
      currentTimeValue = paymentList.first;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _handleClick() async {
    if (isPaymentProcessing) return;
    isPaymentProcessing = false;

    if (currentTimeValue!.type == PAYMENT_METHOD_STRIPE) {
      if (currentTimeValue!.isTest == 1) {
        appStore.setLoading(true);

        await stripeServices.init(
          providerData: widget.selectedPricingPlan,
          stripePaymentPublishKey: currentTimeValue!.testValue!.stripePublickey.validate(),
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          stripeURL: currentTimeValue!.testValue!.stripeUrl.validate(),
          stripePaymentKey: currentTimeValue!.testValue!.stripeKey.validate(),
          isTest: true,
        );
        await 1.seconds.delay;
        stripeServices.stripePay(onPaymentComplete: () {
          isPaymentProcessing = false;
        });
      } else {
        appStore.setLoading(true);

        await stripeServices.init(
          providerData: widget.selectedPricingPlan,
          stripePaymentPublishKey: currentTimeValue!.liveValue!.stripePublickey.validate(),
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          stripeURL: currentTimeValue!.liveValue!.stripeUrl.validate(),
          stripePaymentKey: currentTimeValue!.liveValue!.stripeKey.validate(),
          isTest: false,
        );
        await 1.seconds.delay;
        stripeServices.stripePay(onPaymentComplete: () {
          isPaymentProcessing = false;
        });
      }
    } else if (currentTimeValue!.type == PAYMENT_METHOD_RAZOR) {
      if (currentTimeValue!.isTest == 1) {
        appStore.setLoading(true);
        razorPayServices.init(razorKey: currentTimeValue!.testValue!.razorKey!, data: widget.selectedPricingPlan);

        await 1.seconds.delay;
        appStore.setLoading(false);
        razorPayServices.razorPayCheckout(widget.selectedPricingPlan.amount.validate());
      } else {
        appStore.setLoading(true);
        razorPayServices.init(razorKey: currentTimeValue!.liveValue!.razorKey!, data: widget.selectedPricingPlan);

        await 1.seconds.delay;
        appStore.setLoading(false);
        razorPayServices.razorPayCheckout(widget.selectedPricingPlan.amount.validate());
      }
    } else if (currentTimeValue!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      if (currentTimeValue!.isTest == 1) {
        appStore.setLoading(true);

        FlutterWaveServices().payWithFlutterWave(
          selectedPricingPlan: widget.selectedPricingPlan,
          flutterWavePublicKey: currentTimeValue!.testValue!.flutterwavePublic.validate(),
          flutterWaveSecretKey: currentTimeValue!.testValue!.flutterwaveSecret.validate(),
          isTestMode: true,
        );
      } else {
        appStore.setLoading(true);

        FlutterWaveServices().payWithFlutterWave(
          selectedPricingPlan: widget.selectedPricingPlan,
          flutterWavePublicKey: currentTimeValue!.liveValue!.flutterwavePublic.validate(),
          flutterWaveSecretKey: currentTimeValue!.liveValue!.flutterwaveSecret.validate(),
          isTestMode: false,
        );
      }
    } else if (currentTimeValue!.type == PAYMENT_METHOD_CINETPAY) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appStore.currencyCode)) {
        toast(languages!.lblYourCurrenciesNotSupport);
        return;
      }

      appStore.setLoading(true);

      if (currentTimeValue!.isTest == 1) {
        CinetPayServices cinetPayServices = CinetPayServices(
          cinetPayApiKey: currentTimeValue!.testValue!.cinetPublicKey.validate(),
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          planData: widget.selectedPricingPlan,
          siteId: currentTimeValue!.testValue!.cinetId.validate(),
          secretKey: currentTimeValue!.testValue!.cinetKey.validate(),
        );
        await 1.seconds.delay;

        cinetPayServices.payWithCinetPay(context: context);
      } else {
        CinetPayServices cinetPayServices = CinetPayServices(
          cinetPayApiKey: currentTimeValue!.liveValue!.cinetPublicKey.validate(),
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          planData: widget.selectedPricingPlan,
          siteId: currentTimeValue!.liveValue!.cinetId.validate(),
          secretKey: currentTimeValue!.liveValue!.cinetKey.validate(),
        );
        await 1.seconds.delay;

        cinetPayServices.payWithCinetPay(context: context);
      }
    } else if (currentTimeValue!.type == PAYMENT_METHOD_SADAD_PAYMENT) {
      if (currentTimeValue!.isTest == 1) {
        appStore.setLoading(true);
        SadadServices sadadServices = SadadServices(
          sadadId: currentTimeValue!.testValue!.sadadId.validate(),
          sadadKey: currentTimeValue!.testValue!.sadadKey.validate(),
          sadadDomain: currentTimeValue!.testValue!.sadadDomain.validate(),
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          planData: widget.selectedPricingPlan,
        );

        await 1.seconds.delay;
        await sadadServices.payWithSadad(context);
        appStore.setLoading(false);
      } else {
        appStore.setLoading(true);
        SadadServices sadadServices = SadadServices(
          sadadId: currentTimeValue!.liveValue!.sadadId.validate(),
          sadadKey: currentTimeValue!.liveValue!.sadadKey.validate(),
          sadadDomain: currentTimeValue!.liveValue!.sadadDomain.validate(),
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          planData: widget.selectedPricingPlan,
        );

        await 1.seconds.delay;
        await sadadServices.payWithSadad(context);
        appStore.setLoading(false);
      }
    }
    /*else if (currentTimeValue!.type == PAYMENT_METHOD_PAYPAL) {
      if (currentTimeValue!.isTest == 1) {
        appStore.setLoading(true);

        PaypalPayment paypalPayment = PaypalPayment(
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          planData: widget.selectedPricingPlan,
          payPalUrl: currentTimeValue!.testValue!.paypalUrl.validate(),
        );

        await 1.seconds.delay;
        paypalPayment.brainTreeDrop();
      } else {
        appStore.setLoading(true);

        PaypalPayment paypalPayment = PaypalPayment(
          totalAmount: widget.selectedPricingPlan.amount.validate(),
          planData: widget.selectedPricingPlan,
          payPalUrl: currentTimeValue!.liveValue!.paypalUrl.validate(),
        );

        await 1.seconds.delay;
        paypalPayment.brainTreeDrop();
      }
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(languages!.lblPayment, color: context.primaryColor, textColor: Colors.white, backWidget: BackWidget()),
      body: Stack(
        children: [
          if (paymentList.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(languages!.lblChoosePaymentMethod, style: boldTextStyle(size: 18)).paddingOnly(left: 16),
                16.height,
                ListView.builder(
                  itemCount: paymentList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    PaymentSetting value = paymentList[index];
                    return RadioListTile<PaymentSetting>(
                      dense: true,
                      activeColor: primaryColor,
                      value: value,
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: currentTimeValue,
                      onChanged: (PaymentSetting? ind) {
                        currentTimeValue = ind;
                        setState(() {});
                      },
                      title: Text(value.title.validate(), style: primaryTextStyle()),
                    );
                  },
                ),
                Spacer(),
                AppButton(
                  onTap: () {
                    if (currentTimeValue!.type == PAYMENT_METHOD_COD) {
                      showConfirmDialogCustom(
                        context,
                        dialogType: DialogType.CONFIRMATION,
                        title: "${languages!.lblPayWith} ${currentTimeValue!.title.validate()}",
                        primaryColor: primaryColor,
                        positiveText: languages!.lblYes,
                        negativeText: languages!.lblNo,
                        onAccept: (p0) {
                          _handleClick();
                        },
                      );
                    } else {
                      _handleClick();
                    }
                  },
                  text: languages!.lblProceed,
                  color: context.primaryColor,
                  width: context.width(),
                ).paddingAll(16),
              ],
            ),
          if (paymentList.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(notDataFoundImg, height: 150),
                16.height,
                Text(languages!.lblNoPayments, style: boldTextStyle()).center(),
              ],
            ),
          Observer(builder: (context) => LoaderWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
