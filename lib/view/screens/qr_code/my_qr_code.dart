import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/extensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/account/profile_controller.dart';
import 'package:viserpay/data/controller/qr_code/qr_code_controller.dart';
import 'package:viserpay/data/repo/account/profile_repo.dart';
import 'package:viserpay/data/repo/qr_code/qr_code_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/global/history_icon_widget.dart';
import 'package:viserpay/view/components/image/my_image_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../components/app-bar/custom_appbar.dart';

class MyQrCodeScreen extends StatefulWidget {
  const MyQrCodeScreen({super.key});

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  final InActivityTimer timer = InActivityTimer();
  String? transactionId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    print("Transaction reçue:================= $transactionId");

    transactionId = MyUtils().generateTransactionId();
    print("Transaction reçue:================= $transactionId");

    super.initState();

    timer.startTimer(context);
    if (transactionId!.isNotEmpty) {
      listenToTransaction(transactionId!).listen((transaction) {
        if (transaction.exists) {
          final data = transaction.data() as Map<String, dynamic>?;

          print("Transaction reçue: $data");

          if (data != null && data.containsKey('idTrans')) {
            if (data['idTrans'] == transactionId) {
              double amount = double.tryParse(data['amount'].toString()) ?? 0.0;

              double newAmount = amount - (amount * 0.3);
              MyUtils().showSuccessDialog(
                  context, data['title'], data['msg'], newAmount);
            }
          }
        }
      }, onError: (error) {
        print("Erreur Firestore: $error");
      });
    }
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(ProfileController(profileRepo: Get.find()));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadProfileInfo();
    });
  }

  Stream<DocumentSnapshot> listenToTransaction(String transactionId) {
    return firestore.collection('transactions').doc(transactionId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => NotificationListener<ScrollNotification>(
        onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
        child: GestureDetector(
          onTap: () => timer.handleUserInteraction(context),
          onPanUpdate: (_) => timer.handleUserInteraction(context),
          child: Scaffold(
            appBar: CustomAppBar(
              title: MyStrings.myqrCode.toSentenceCase(),
              isShowBackBtn: true,
              isTitleCenter: true,
              action: [
                HistoryWidget(routeName: RouteHelper.receiveMoneyHistoryScreen),
                const SizedBox(
                  width: Dimensions.space20,
                ),
              ],
            ),
            body: controller.isLoading
                ? const CustomLoader(loaderColor: MyColor.primaryColor)
                : Container(
                    margin: const EdgeInsets.all(Dimensions.space20),
                    decoration: BoxDecoration(
                        color: MyColor.colorWhite,
                        borderRadius:
                            BorderRadius.circular(Dimensions.defaultRadius)),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: Dimensions.space60),

                          // Titre EasyPay au-dessus du QR code
                          Text(
                            'EasyPay',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 20),

                          // QR Code avec texte superposé
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                QrImageView(
                                  data:
                                      "${controller.model.data?.user?.isic_num}-$transactionId",
                                  version: 5,
                                  size: 300,
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  gapless: false,
                                  errorStateBuilder: (cxt, err) {
                                    return Container(
                                      child: Center(
                                        child: Text(
                                          "Une erreur s'est produit lors de le scannage",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Texte EasyPay superposé au centre du QR code
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.blue[700]!, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'EasyPay',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.space60),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
