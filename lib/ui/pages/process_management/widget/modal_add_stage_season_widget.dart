import 'package:flutter/material.dart';
import 'package:flutter_base/commons/app_colors.dart';
import 'package:flutter_base/commons/app_images.dart';
import 'package:flutter_base/commons/app_text_styles.dart';
import 'package:flutter_base/configs/app_config.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_button.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_text_field.dart';
import 'package:flutter_base/utils/validators.dart';
import 'package:flutter_base/utils/date_utils.dart' as Util;
import 'package:intl/intl.dart';

class ModalAddStageSeasonWidget extends StatefulWidget {
  const ModalAddStageSeasonWidget(
      {Key? key,
        this.name,this.description,
        this.start,
        required this.onPressed,
        this.onDelete})
      : super(key: key);
  final Future<void> Function(String name, String description, String start) onPressed;
  final String? name;
  final String? start;
  final String? description;
  final VoidCallback? onDelete;

  @override
  State<ModalAddStageSeasonWidget> createState() => _ModalAddStageSeasonWidgetState();
}

class _ModalAddStageSeasonWidgetState extends State<ModalAddStageSeasonWidget> {
  final _formKey = GlobalKey<FormState>();
  DateFormat _dateFormat = DateFormat("dd-MM-yyyy");
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController descriptionController = TextEditingController(text: '');
  late double heightResize = 0.5;
  late String startTime;

  @override
  void initState() {
    super.initState();
    startTime = _dateFormat.format(DateTime.now());
    nameController = TextEditingController(text: widget.name);
    descriptionController = TextEditingController(text: widget.description);
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentScope = FocusScope.of(context);
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if (viewInsetsBottom == 0 || currentScope.hasPrimaryFocus == true) {
      setState(() {
        heightResize = 0.75;
      });
    } else {
      setState(() {
        heightResize = 0.95;
      });
    }
    return Container(
      height: MediaQuery.of(context).size.height * heightResize,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20))),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Color(0xFFECE5D5),
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20))),
            height: 40,
            child: Stack(
              children: [
                Container(
                    height: 40,
                    padding: EdgeInsets.all(10),
                    child: Text('Th??m giai ??o???n')),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        AppImages.icCloseCircleShadow,
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  AppTextField(
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    hintText: 'Nh???p t??n c???a giai ??o???n',
                    controller: nameController,
                    validator: (value) {
                      if (Validator.validateNullOrEmpty(value!))
                        return "Ch??a nh???p t??n giai ??o???n";
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  AppTextAreaField(
                    hintText: 'M?? t???',
                    // maxLines: 8,
                    enable: true,
                    controller: descriptionController,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'Ng??y b???t ?????u:',
                        style: AppTextStyle.greyS18,
                      ),
                      SizedBox(width: 15),
                      Text(
                        startTime,
                        style: AppTextStyle.blackS16.copyWith(
                            decoration: TextDecoration.underline),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          final result = await showDatePicker(
                              context: context,
                              locale: Locale('vi'),
                              initialEntryMode:
                              DatePickerEntryMode.input,
                              builder: (context, child) {
                                return _buildCalendarTheme(child);
                              },
                              fieldHintText: "dd-MM-yyyy",
                              initialDate: widget.start!= null
                                  ? Util.DateUtils.fromString(
                                  widget.start,
                                  format: AppConfig
                                      .dateDisplayFormat)!
                                  : DateTime.now(),
                              firstDate: /*widget.start!= null
                                  ? Util.DateUtils.fromString(
                                  widget.start,
                                  format: AppConfig
                                      .dateDisplayFormat)!
                                  :*/ DateTime.now(),
                              lastDate: DateTime(2024));
                          if (result != null) {
                            // widget.start =
                            //     Util.DateUtils.toDateString(
                            //         result);

                            startTime = Util.DateUtils.toDateString(
                                result, format: AppConfig.dateAPIFormatStrikethrough);
                            setState(() {

                            });
                          }
                        },
                        child: SizedBox(
                          height: 26,
                          width: 26,
                          child: Image.asset(
                            AppImages.icCalendar,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AppButton(
                          color: AppColors.redButton,
                          title: 'H???y b???',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: AppButton(
                            color: AppColors.main,
                            title: 'X??c nh???n',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                DateTime time = Util.DateUtils.fromString(
                                    startTime,
                                    format: AppConfig
                                        .dateAPIFormatStrikethrough)!;
                                startTime = Util.DateUtils.toDateString(
                                    time, format: AppConfig.dateDisplayFormat);
                                await widget.onPressed(nameController.text, descriptionController.text, startTime);
                                Navigator.pop(context, true);
                              }
                            }),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Theme _buildCalendarTheme(Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
            primary: AppColors.main,
            surface: AppColors.main,
            // onSurface: AppColors.main,
            background: AppColors.main,
            onPrimary: Colors.white),
      ),
      child: SingleChildScrollView(child: child!),
    );
  }
}
