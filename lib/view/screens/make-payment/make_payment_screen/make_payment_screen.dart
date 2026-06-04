import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/cash_out/cash_out_controller.dart';
import 'package:viserpay/data/repo/cashout/cashout_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/global/history_icon_widget.dart';

import '../../../../core/route/route.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final InActivityTimer timer = InActivityTimer();
  String? storedValue;
  String? matriculeValue;
  String? type;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    final args = Get.arguments;
    type = MyUtils().generateTransactionId();

    timer.startTimer(context);
    print("Transactions reçue================: $type");

    String transactionId = type ?? "";

    if (transactionId.isNotEmpty) {
      listenToTransaction(transactionId).listen((transaction) {
        if (transaction.exists) {
          final data = transaction.data() as Map<String, dynamic>?;

          print("DATA reçue: $data");

          if (data != null) {
            if (data['idTrans'] == transactionId) {
              double amount = data['amount']?.toDouble() ?? 0.0;

              MyUtils().showSuccessDialog(
                  context, data['title'], data['msg'], amount);
            }
          }
        }
      }, onError: (error) {
        print("Erreur Firestore: $error");
      });
    }

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(CashoutRepo(apiClient: Get.find()));
    final controller = Get.put(CashOutController(cashoutRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialValue();
      getIsicNum();
      getMatricule();
    });
  }

  Stream<DocumentSnapshot> listenToTransaction(String transactionId) {
    return firestore.collection('transactions').doc(transactionId).snapshots();
  }

  void getIsicNum() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? value = sharedPreferences.getString('isic_num');

      // Validate the stored value
      if (value != null && value.isNotEmpty) {
        setState(() {
          storedValue = value.trim(); // Remove any whitespace
        });
      } else {
        print("Warning: No ISIC number found in SharedPreferences");
        setState(() {
          storedValue = null;
        });
      }
    } catch (e) {
      print("Error retrieving ISIC number: $e");
      setState(() {
        storedValue = null;
      });
    }
  }

  //ajout de la methode qui gere le chargement du matricule
  void getMatricule() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? value = sharedPreferences.getString('matricule');

      // Validate the stored value
      if (value != null && value.isNotEmpty) {
        setState(() {
          matriculeValue = value.trim(); // Remove any whitespace
        });
      } else {
        print("Warning: No Matricule found in SharedPreferences");
        setState(() {
          matriculeValue = null;
        });
      }
    } catch (e) {
      print("Error retrieving Matricule: $e");
      setState(() {
        matriculeValue = null;
      });
    }
  }

//generation du code qr en utilisant soit le matricule, soit le num isic
  String _generateQRData() {
    String? identifier =
        matriculeValue ?? storedValue; // priorité au matricule si dispo
    if (identifier != null && type != null) {
      return "$identifier-$type";
    }
    return "";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        timer.handleUserInteraction(context);
        return false;
      },
      child: WillPopScope(
        onWillPop: () async {
          setState(() {});
          return true;
        },
        child: GestureDetector(
          onTap: () => timer.handleUserInteraction(context),
          onPanUpdate: (_) => timer.handleUserInteraction(context),
          child: Scaffold(
            backgroundColor: MyColor.colorWhite,
            appBar: CustomAppBar(
              title: "Paiement",
              isTitleCenter: true,
              elevation: 0.03,
              action: [
                HistoryWidget(routeName: RouteHelper.cashOutHistoryScreen),
                const SizedBox(
                  width: Dimensions.space20,
                ),
              ],
            ),
            body: GetBuilder<CashOutController>(builder: (controller) {
              return controller.isLoading
                  ? const CustomLoader()
                  : StatefulBuilder(builder: (context, setState) {
                      final qrData = _generateQRData();

                      return SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              Text(
                                'Scannez ce code QR pour effectuer le paiement',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 100),
                              _buildQRCode(qrData),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  timer.startTimer(context);
                                  Navigator.pop(context);
                                },
                                child: Text('Retour'),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode(String qrData) {
    if (storedValue == null || matriculeValue == null) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 10),
          Text(
            'Chargement des données...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }

    if (qrData.isEmpty) {
      return Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red),
              SizedBox(height: 10),
              Text(
                'Erreur: Données QR invalides',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Le QR code avec un Stack pour superposer le texte
        Stack(
          alignment: Alignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 350,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              gapless: true,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              errorStateBuilder: (context, error) {
                print("QR Code Error: $error");
                return Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2, size: 50, color: Colors.red),
                        SizedBox(height: 10),
                        Text(
                          "Erreur lors de la génération du code QR",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 5),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Texte EasyPay superposé au centre du QR code
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[700]!, width: 2),
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
      ],
    );
  }
}
