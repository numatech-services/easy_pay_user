import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/cash_out/cash_out_controller.dart';
import 'package:viserpay/data/controller/home/home_controller.dart'; 
import 'package:viserpay/data/repo/cashout/cashout_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
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
  String? type;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // On déclare une variable pour accéder au HomeController
  late HomeController homeController;

  @override
  void initState() {
    super.initState();
    
    // 1. On récupère le HomeController existant
    // Comme il a été chargé au démarrage de l'app, il contient déjà les infos utilisateur
    if(Get.isRegistered<HomeController>()){
       homeController = Get.find<HomeController>();
    } else {
       // Cas de secours (peu probable si l'app est bien lancée)
       // Vous devrez peut-être instancier le repo ici si nécessaire, mais Get.find devrait suffire
    }

    final args = Get.arguments;
    type = MyUtils().generateTransactionId();

    timer.startTimer(context);
    
    String transactionId = type ?? "";

    if (transactionId.isNotEmpty) {
      listenToTransaction(transactionId).listen((transaction) {
        if (transaction.exists) {
          final data = transaction.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('idTrans')) {
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
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialValue();
      // Plus besoin de getIsicNum() ni getMatricule() ici car on utilise homeController
    });
  }

  Stream<DocumentSnapshot> listenToTransaction(String transactionId) {
    return firestore.collection('transactions').doc(transactionId).snapshots();
  }

  // 2. Correction de la génération du QR Code
  String _generateQRData() {
    // On récupère les infos directement du controlleur
    String isic = homeController.isicNum; 
    String username = homeController.username;
    
    // On choisit l'identifiant (ISIC en priorité, sinon username/matricule)
    String identifier = isic.isNotEmpty ? isic : username;

    if (identifier.isNotEmpty && type != null) {
      // Format: NUMERO_ISIC-ID_TRANSACTION
      return "$identifier-$type";
    }
    
    // Si pas d'identifiant, on retourne juste l'ID transaction ou vide
    return type ?? "";
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
                      print("Données QR générées : $qrData"); // Pour le debug

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
    // 3. Vérification simplifiée
    // Si qrData contient juste un tiret ou est vide, c'est qu'il manque des infos
    if (qrData.isEmpty || qrData.startsWith("-")) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 10),
          Text(
            'Récupération des données ISIC...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'EasyPay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12),

          Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 280,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                gapless: false,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                errorStateBuilder: (context, error) {
                  return Container(
                    width: 280,
                    height: 280,
                    child: Center(child: Text("Erreur QR")),
                  );
                },
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[700]!, width: 2),
                ),
                child: Text(
                  'EasyPay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}