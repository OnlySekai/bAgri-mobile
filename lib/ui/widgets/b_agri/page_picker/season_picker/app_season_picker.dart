import 'package:flutter/material.dart';
import 'package:flutter_base/commons/app_colors.dart';
import 'package:flutter_base/commons/app_text_styles.dart';
import 'package:flutter_base/models/entities/season/season_entity.dart';
import 'package:flutter_base/utils/validators.dart';


import 'app_season_picker_page.dart';

class SeasonPickerController extends ValueNotifier<SeasonEntity?> {
  SeasonPickerController({SeasonEntity? seasonEntity}) : super(seasonEntity);

  SeasonEntity? get seasonEntity => value;

  set seasonEntity(SeasonEntity? seasonValue) {
    value = seasonValue;
    notifyListeners();
  }
}

class AppPageSeasonPicker extends StatelessWidget {
  final SeasonPickerController controller;
  final ValueChanged<SeasonEntity?>? onChanged;
  final bool enabled;

  AppPageSeasonPicker({
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, SeasonEntity? seasonEntity, child) {
        String text = seasonEntity?.name ?? "";
        return GestureDetector(
          onTap: enabled
              ? () {
            _showMyProjectPicker(context: context);
          }
              : null,
          child: Stack(
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
              ),
              TextFormField(
                enabled: false,
                controller: TextEditingController(text: text),
                validator: (value){
                  if(Validator.validateNullOrEmpty(value!))
                    return "Vui lòng chọn mùa";
                  else
                    return null;
                },
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),
                  hintText: 'Chọn mùa',
                  suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.keyboard_arrow_down)),
                  suffixIconConstraints:
                  BoxConstraints(maxHeight: 32, maxWidth: 32),
                  contentPadding: const EdgeInsets.only(
                    left: 20,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.redTextButton),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.lineGray),
                  ),
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.main),
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.main),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.main),
                      borderRadius: BorderRadius.circular(10)),
                  // focusedErrorBorder: OutlineInputBorder(
                  //   // borderRadius: BorderRadius.circular(10),
                  //   borderSide: BorderSide(color: AppColors.lineGray),
                  // ),
                  hintStyle: AppTextStyle.greyS14,
                ),
                style: AppTextStyle.blackS16,

              ),
            ],
          ),
        );
      },
    );
  }

  _showMyProjectPicker({
    required BuildContext context,
  }) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return AppSeasonPickerPage(
            selectedSeasonId: controller.seasonEntity?.seasonId ?? "",

          );
        },
      ),
    );
    if (result is SeasonEntity) {
      controller.seasonEntity = result;
      onChanged?.call(result);
    }
  }
}
