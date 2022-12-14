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

class ModalEditStepSeasonWidget extends StatefulWidget {
  const ModalEditStepSeasonWidget(
      {Key? key,
      this.name,
      this.description,
      required this.start,
      this.end,
      this.from_day,
      this.to_day,
      required this.onPressed,
      required this.onEnd,
      required this.onDelete})
      : super(key: key);
  final Future<void> Function(String name, String description, String start,
      String to_day, String from_day) onPressed;
  final void Function() onEnd;
  final String? name;
  final String start;
  final String? end;
  final int? from_day;
  final int? to_day;
  final String? description;
  final Future<void> Function() onDelete;

  @override
  State<ModalEditStepSeasonWidget> createState() =>
      _ModalEditStepSeasonWidgetState();
}

class _ModalEditStepSeasonWidgetState extends State<ModalEditStepSeasonWidget> {
  final _formKey = GlobalKey<FormState>();
  DateFormat _dateFormat = DateFormat("dd-MM-yyyy");
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController descriptionController = TextEditingController(text: '');
  TextEditingController fromDayController = TextEditingController(text: '');
  TextEditingController toDayController = TextEditingController(text: '');
  late double heightResize = 0.5;
  late String startTime = DateTime.now().toString().substring(0, 10);

  @override
  void initState() {
    super.initState();
    startTime = _dateFormat.format(DateTime.parse(widget.start/*.substring(0,10)*/) )/*?? startTime*/;
    nameController = TextEditingController(text: widget.name);
    descriptionController =
        TextEditingController(text: widget.description ?? '');
    fromDayController = TextEditingController(text: widget.from_day.toString());
    toDayController = TextEditingController(text: widget.to_day.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    toDayController.dispose();
    fromDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentScope = FocusScope.of(context);
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if (viewInsetsBottom == 0 || currentScope.hasPrimaryFocus == true) {
      setState(() {
        heightResize = 0.8;
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
                Center(
                  child: Container(
                      height: 40,
                      padding: EdgeInsets.all(10),
                      child: Text('Ch???nh s???a b?????c', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic), textAlign: TextAlign.center,)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
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
            height: 10,
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
                    height: 10,
                  ),
                  AppTextAreaField(
                    hintText: 'M?? t???',
                    // maxLines: 8,
                    enable: true,
                    controller: descriptionController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          hintText: 'T??? ... ng??y',
                          keyboardType: TextInputType.number,
                          controller: fromDayController,
                          validator: (value) {
                            if (Validator.validateNullOrEmpty(value!))
                              return "Ch??a nh???p ng??y b???t ?????u";
                            else
                              return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: AppTextField(
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          hintText: '?????n ... ng??y',
                          keyboardType: TextInputType.number,
                          controller: toDayController,
                          enable: (fromDayController.text != '') ? true : false,
                          validator: (value) {
                            if (Validator.validateNullOrEmpty(value!))
                              return "Ch??a nh???p ng??y k???t th??c";
                            else {
                              if (int.parse(value) <
                                  int.parse(fromDayController.text)) {
                                return "Ng??y b???t ?????u ph???i nh??? h??n ng??y k???t th??c";
                              } else {
                                return null;
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
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
                        style: AppTextStyle.blackS16
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          final result = await showDatePicker(
                              context: context,
                              locale: Locale('vi'),
                              initialEntryMode: DatePickerEntryMode.input,
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
                              firstDate: widget.start!= null
                                  ? Util.DateUtils.fromString(
                                  widget.start,
                                  format: AppConfig
                                      .dateDisplayFormat)!
                                  : DateTime.now(),
                              lastDate: DateTime(2024));
                          if (result != null) {
                            startTime = Util.DateUtils.toDateString(
                                result, format: AppConfig.dateAPIFormatStrikethrough);
                            setState(() {});
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
                          color: AppColors.green28,
                          title: 'X??a b?????c',
                          onPressed: () async{
                            await widget.onDelete();
                            // Navigator.of(context).pop(true);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: AppButton(
                            color: AppColors.main,
                            title: 'X??c nh???n',
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {
                                DateTime time = Util.DateUtils.fromString(
                                    startTime,
                                    format: AppConfig
                                        .dateAPIFormatStrikethrough)!;
                                startTime = Util.DateUtils.toDateString(
                                    time, format: AppConfig.dateDisplayFormat);
                                await widget.onPressed(
                                    nameController.text,
                                    descriptionController.text,
                                    startTime,
                                    fromDayController.text,
                                    toDayController.text);
                              }
                            }),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          color: AppColors.redButton,
                          title: 'K???t th??c',
                          onPressed: () {
                            widget.onEnd();
                            Navigator.of(context).pop();
                          },
                        ),
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
