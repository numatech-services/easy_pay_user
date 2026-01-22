import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viserpay/core/helper/shared_preference_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/messages.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/controller/auth/login_controller.dart';
import 'package:viserpay/data/controller/isic/ticket_balance_controller.dart';
import 'package:viserpay/data/controller/localization/localization_controller.dart';
import 'package:viserpay/data/repo/auth/login_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/data/services/isic_auth_service.dart';
import 'package:viserpay/data/services/isic_cache_service.dart';
import 'package:viserpay/data/services/isic_card_service.dart';
import 'package:viserpay/data/services/isic_token_manager.dart';
import 'package:viserpay/push_notification_service.dart';
import 'core/di_service/di_services.dart' as di_service;
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  sharedPreferences.setBool(SharedPreferenceHelper.hasNewNotificationKey, true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient(sharedPreferences: sharedPreferences);
  final loginRepo = LoginRepo(apiClient: apiClient);
  Get.put(LoginController(loginRepo: loginRepo));

  // Initialiser les services ISIC dans le bon ordre
  await initIsicServices();
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.none) {
    await Firebase.initializeApp();
  } else {
    print("Pas de connexion Internet - Firebase non initialisé");
  }

  Map<String, Map<String, String>> languages = await di_service.init();
  MyUtils.allScreen();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await PushNotificationService(apiClient: Get.find()).setupInteractedMessage();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  HttpOverrides.global = MyHttpOverrides();

Get.put(TicketBalanceController(), permanent: true);
// Enregistrement du controller
  // Get.put(TicketBalanceController());
  // Après login réussi
  final ticketCtrl = Get.put(TicketBalanceController());
  ticketCtrl.fetchBalances();
  Obx(() {
    final ticketCtrl = Get.find<TicketBalanceController>();
    return Column(
      children: [
        Text("Petit-déjeuner: ${ticketCtrl.getBalance('petit_dejeuner')}"),
        Text("Déjeuner: ${ticketCtrl.getBalance('dejeuner')}"),
        Text("Dîner: ${ticketCtrl.getBalance('diner')}"),
        Text("Transport: ${ticketCtrl.getBalance('transport')}"),
      ],
    );
  });

  runApp(MyApp(languages: languages));
}

/// Initialise tous les services ISIC
Future<void> initIsicServices() async {
  // 1. Token Manager
  Get.put(IsicTokenManager(), permanent: true);
  await Get.find<IsicTokenManager>().init();

  // 2. Cache Service
  Get.put(IsicCacheService(), permanent: true);
  await Get.find<IsicCacheService>().init();

  // 3. Auth Service
  Get.put(IsicAuthService(), permanent: true);

  // 4. Card Service
  Get.put(IsicCardService(), permanent: true);
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>> languages;
  const MyApp({super.key, required this.languages});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizeController) => GetMaterialApp(
        title: MyStrings.appName,
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.noTransition,
        transitionDuration: const Duration(milliseconds: 100),
        initialRoute: RouteHelper.splashScreen,
        navigatorKey: Get.key,

        // ===== AJOUT DES LOCALISATIONS =====
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        // ===================================

        theme: ThemeData(
          indicatorColor: MyColor.primaryColor,
          scaffoldBackgroundColor: MyColor.colorWhite,
          splashColor: MyColor.primaryButtonColor.withOpacity(0.1),
          dialogTheme: const DialogThemeData(
            surfaceTintColor: MyColor.transparentColor,
            elevation: 0,
            backgroundColor: MyColor.colorWhite,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            surfaceTintColor: MyColor.transparentColor,
            color: MyColor.getCardBgColor(),
          ),
          snackBarTheme:
              const SnackBarThemeData(backgroundColor: MyColor.colorWhite),
          colorSchemeSeed: MyColor.primaryColor,
          drawerTheme: const DrawerThemeData(
            backgroundColor: MyColor.colorWhite,
            elevation: 0,
            surfaceTintColor: MyColor.transparentColor,
          ),
        ),
        getPages: RouteHelper().routes,
        locale: localizeController.locale,
        translations: Messages(languages: widget.languages),
        fallbackLocale: Locale(
          localizeController.locale.languageCode,
          localizeController.locale.countryCode,
        ),
      ),
    );
  }

}

