import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/commons/app_colors.dart';
import 'package:flutter_base/commons/app_images.dart';
import 'package:flutter_base/commons/app_text_styles.dart';
import 'package:flutter_base/configs/app_config.dart';
import 'package:flutter_base/models/entities/task/temporary_task.dart';
import 'package:flutter_base/repositories/temporary_task_repository.dart';
import 'package:flutter_base/ui/pages/task/temporary_task_management/temporary_task_add/temporary_task_add_cubit.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_button.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_text_field.dart';
import 'package:flutter_base/utils/validators.dart';
import 'package:flutter_base/utils/date_utils.dart' as Util;
import 'package:flutter_bloc/flutter_bloc.dart';

class ModalAddDailyTaskWidget extends StatefulWidget {
  ModalAddDailyTaskWidget(
      {Key? key, this.name, this.start, required this.onPressed, this.onDelete, this.cubit})
      : super(key: key);
  final void Function(
          String name,  String fee, String workQuantity, String start)
      onPressed;
  final String? name;

  // final String? description;
  final VoidCallback? onDelete;
  String? start;
  TemporaryTaskAddCubit? cubit;

  @override
  _ModalAddDailyTaskWidgetState createState() {
    return _ModalAddDailyTaskWidgetState();
  }
}

class _ModalAddDailyTaskWidgetState extends State<ModalAddDailyTaskWidget> {
  final _modalKey = GlobalKey<FormState>();
  late double heightResize = 0.5;
  TextEditingController nameController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController workerQuantityController = TextEditingController();
  String startTime =  DateTime.now().toString().substring(0,10);
  // TemporaryTaskAddCubit? cubit;

  @override
  void initState() {
    super.initState();
    // cubit = BlocProvider.of<TemporaryTaskAddCubit>(context);
    // nameController = TextEditingController(text: widget.name);
    // descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    nameController.dispose();
    // descriptionController.dispose();
    feeController.dispose();
    workerQuantityController.dispose();
    super.dispose();
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
    return BlocProvider(
        create: (context) {
      TemporaryTaskRepository temporaryTaskRepository =
      RepositoryProvider.of<TemporaryTaskRepository>(context);
      return TemporaryTaskAddCubit(
          temporaryTaskRepository: temporaryTaskRepository);
    },
    child: SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                      child: Text('Th??m c??ng vi???c')),
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
              height: 10,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Form(
                  key: _modalKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'T??n c??ng vi???c:',
                          style: AppTextStyle.greyS16,
                        ),
                        SizedBox(height: 5),
                        AppTextField(
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          hintText: 'Nh???p t??n c???a c??ng vi???c',
                          controller: nameController,
                          validator: (value) {
                            if (Validator.validateNullOrEmpty(value!))
                              return "Ch??a nh???p t??n c??ng vi???c";
                            else
                              return null;
                          },
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'S??? n??ng d??n th???c hi???n:',
                          style: AppTextStyle.greyS16,
                        ),
                        SizedBox(height: 5),
                        AppTextField(
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          hintText: 'Nh???p s??? n??ng d??n',
                          controller: workerQuantityController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (Validator.validateNullOrEmpty(value!))
                              return "Ch??a nh???p s??? n??ng d??n";
                            else
                              return null;
                          },
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Chi ph??:',
                          style: AppTextStyle.greyS16,
                        ),
                        SizedBox(height: 5),
                        AppTextField(
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          hintText: 'Chi ph??',
                          controller: feeController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (Validator.validateNullOrEmpty(value!))
                              return "Ch??a nh???p chi ph??";
                            else
                              return null;
                          },
                        ),
                        SizedBox(height: 5),
                      /*  BlocBuilder<TemporaryTaskAddCubit,
                                TemporaryTaskAddState>(
                            buildWhen: (prev, current) =>
                                prev.startTime != current.startTime,
                            builder: (context, state) {
                              return */Column(children: [
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
                                            fieldHintText: "yyyy/mm/dd",
                                            initialDate: widget.start!= null
                                                ? Util.DateUtils.fromString(
                                                    widget.start,
                                                    format: AppConfig
                                                        .dateDisplayFormat)!
                                                : DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2024));
                                        if (result != null) {
                                          // widget.start =
                                          //     Util.DateUtils.toDateString(
                                          //         result);

                                          startTime = Util.DateUtils.toDateString(
                                                      result);
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
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        color: AppColors.redButton,
                                        title: 'H???y b???',
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          widget.onDelete!();
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: AppButton(
                                          color: AppColors.main,
                                          title: 'X??c nh???n',
                                          onPressed: () {
                                            if (_modalKey.currentState!
                                                .validate()) {
                                              Navigator.of(context).pop();
                                              widget.onPressed(
                                                  nameController.text,
                                                  feeController.text,
                                                  workerQuantityController
                                                      .text, startTime);
                                            }
                                          }),
                                    ),
                                  ],
                                ),
                              ])/*;
                            })*/,
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  Theme _buildCalendarTheme(Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
            primary: AppColors.main,
            surface: AppColors.main,
            onSurface: AppColors.main,
            background: AppColors.main,
            onPrimary: Colors.white),
      ),
      child: SingleChildScrollView(child: child!),
    );
  }
}
