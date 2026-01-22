import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';

class GlobalKYCForm {
  GlobalKYCForm({List<FormModel>? list}) {
    _list = list;
  }

  List<FormModel>? _list = [];
  List<FormModel>? get list => _list;

  GlobalKYCForm.fromJson(dynamic json) {
    var map = Map.from(json).map((key, value) => MapEntry(key, value));
    try {
      List<FormModel>? list = map.entries
          .map(
            (e) => FormModel(
              name: e.value['name'],
              label: e.value['label'],
              isRequired: e.value['is_required'].toString(),
              extensions: e.value['extensions'],
              instruction: e.value['instruction'],
              options: (e.value['options'] as List).map((e) => e as String).toList(),
              type: e.value['type'].toString(),
              textEditingController: TextEditingController(),
            ),
          )
          .toList();

      if (list.isNotEmpty) {
        list.removeWhere((element) => element.toString().isEmpty);
        _list?.addAll(list);
      }
      _list;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}

// class GlobalFormModle {
//   String? name;
//   String? label;
//   String? isRequired;
//   String? extensions;
//   String? instruction;
//   List<String>? options;
//   String? type;
//   dynamic selectedValue;
//   TextEditingController? textEditingController;
//   File? imageFile;
//   List<String>? cbSelected;

//   GlobalFormModle({
//     this.name,
//     this.label,
//     this.isRequired,
//     this.instruction,
//     this.extensions,
//     this.options,
//     this.type,
//     this.selectedValue,
//     this.cbSelected,
//     this.imageFile,
//     this.textEditingController,
//   });
// }
