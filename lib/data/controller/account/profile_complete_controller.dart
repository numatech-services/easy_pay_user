import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route_middle_ware.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/model/authorization/authorization_response_model.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/model/profile/profile_response_model.dart';
import 'package:viserpay/data/model/user_post_model/user_post_model.dart';
import 'package:viserpay/data/repo/account/profile_repo.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class ProfileCompleteController extends GetxController {
  ProfileRepo profileRepo;

  ProfileResponseModel model = ProfileResponseModel();

  ProfileCompleteController({required this.profileRepo});

  bool isLoading = false;
  TextEditingController userNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  FocusNode userNameFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();

  bool submitLoading = false;
  updateProfile() async {
    String username = userNameController.text;
    String address = addressController.text.toString();
    String city = cityController.text.toString();
    String zip = zipCodeController.text.toString();
    String state = stateController.text.toString();

    submitLoading = true;
    update();

    UserPostModel model = UserPostModel(
      image: null,
      firstname: '',
      lastName: '',
      mobile: '',
      isic_num: '',
      email: '',
      username: username,
      //ajout de matricule
      matricule: '',
      countryCode: '',
      country: '',
      mobileCode: '',
      address: address,
      state: state,
      zip: zip,
      city: city,
    );

    ResponseModel responseModel = await profileRepo.completeProfile(model);
    if (responseModel.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          jsonDecode(responseModel.responseJson));
      if (model.status?.toLowerCase() == "success") {
        RouteMiddleWare.checkUserStatusAndGoToNextStep(user: model.data?.user);
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    submitLoading = false;
    update();
  }
}
