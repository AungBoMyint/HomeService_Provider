import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/locale/applocalizations.dart';
import 'package:handyman_provider_flutter/locale/base_language.dart';
import 'package:handyman_provider_flutter/models/add_extra_charges_model.dart';
import 'package:handyman_provider_flutter/models/file_model.dart';
import 'package:handyman_provider_flutter/models/remote_config_data_model.dart';
import 'package:handyman_provider_flutter/models/revenue_chart_data.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/auth_services.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/chat_messages_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/notification_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/user_services.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/screens/splash_screen.dart';
import 'package:handyman_provider_flutter/store/AppStore.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'app_theme.dart';
import 'networks/firebase_services/firebase_messaging_service.dart';
import 'provider/timeSlots/timeSlotStore/time_slot_store.dart';

//region Mobx Stores
AppStore appStore = AppStore();
TimeSlotStore timeSlotStore = TimeSlotStore();
//endregion

//region App languages
Languages? languages;
//endregion

//region Firebase Services
UserService userService = UserService();
AuthService authService = AuthService();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService();

ChatServices chatServices = ChatServices();
NotificationService notificationService = NotificationService();
//endregion

//region Chart Model
late List<FileModel> fileList = [];
List<RevenueChartData> chartData = [];
//endregion

//region Chat Variable
bool mIsEnterKey = false;
String currentPackageName = '';
//endregion

RemoteConfigDataModel remoteConfigDataModel = RemoteConfigDataModel();

//region Chat Variable
List<AddExtraChargesModel> chargesList = [];
//endregion
//Top Level Function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //---For Local Notification--------//

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();
  if (!isDesktop) {
    Firebase.initializeApp().then((value) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      setupFirebaseRemoteConfig();
    }).catchError((e) {
      log(e.toString());
    });
  }

  defaultSettings();

  await initialize();

  localeLanguageList = languageList();

  appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));

  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  await setLoginValues();

  //Get Token
  firebaseMessagingService.getToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    firebaseMessagingService.requestPermission();
    afterBuildCreated(() {
      int val = getIntAsync(THEME_MODE_INDEX);

      if (val == THEME_MODE_LIGHT) {
        appStore.setDarkMode(false);
      } else if (val == THEME_MODE_DARK) {
        appStore.setDarkMode(true);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: SplashScreen(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          supportedLocales: LanguageDataModel.languageLocales(),
          localizationsDelegates: [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(appStore.selectedLanguageCode),
        ),
      ),
    );
  }
}
