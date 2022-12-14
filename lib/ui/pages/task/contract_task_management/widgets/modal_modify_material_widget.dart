import 'package:flutter/material.dart';
import 'package:flutter_base/commons/app_colors.dart';
import 'package:flutter_base/commons/app_images.dart';
import 'package:flutter_base/commons/app_text_styles.dart';
import 'package:flutter_base/models/entities/material/material.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_button.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_text_field.dart';
import 'package:flutter_base/ui/widgets/b_agri/page_picker/material_picker/app_material_picker.dart';
import 'package:flutter_base/utils/validators.dart';

class ModalModifyMaterialWidget extends StatefulWidget {
  MaterialEntity? materialEntity;
  ModalModifyMaterialWidget(
      {Key? key,
        this.name,
        this.quantity,
        this.unit,
        required this.onPressed,
        required this.materialEntity,
        this.onDelete})
      : super(key: key);
  final void Function(String name, String quantity, String unit) onPressed;
  final String? name;
  final String? quantity;
  final String? unit;
  final VoidCallback? onDelete;

  @override
  State<ModalModifyMaterialWidget> createState() => _ModalModifyMaterialWidgetState();
}

class _ModalModifyMaterialWidgetState extends State<ModalModifyMaterialWidget> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController quantityController = TextEditingController(text: '');
  TextEditingController unitController = TextEditingController(text: '');
  MaterialPickerController materialController = MaterialPickerController();
  late double heightResize = 0.5;

  @override
  void initState() {
    super.initState();
    materialController = MaterialPickerController(materialEntity: widget.materialEntity);
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentScope = FocusScope.of(context);
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if (viewInsetsBottom == 0 || currentScope.hasPrimaryFocus == true) {
      setState(() {
        heightResize = 0.5;
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
                    child: Text('Thay ?????i th??ng tin v???t t?? ???? s??? d???ng')),
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
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextLabel("V???t t??"),
                      SizedBox(
                        height: 10,
                      ),
                      _buildMaterialPicker(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextLabel("S??? l?????ng: "),
                      SizedBox(
                        height: 10,
                      ),
                      AppTextField(
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        hintText: 'Nh???p s??? l?????ng v???t t??',
                        keyboardType: TextInputType.number,
                        controller: quantityController,
                        suffixText: materialController.materialEntity?.unit,
                        suffixTextStyle: TextStyle(
                          color: AppColors.mainDarker,
                          fontSize: 18,
                        ),
                        validator: (value) {
                          if (Validator.validateNullOrEmpty(value!))
                            return "Ch??a nh???p s??? l????ng v???t t??";
                          else
                            return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AppButton(
                                color: AppColors.main,
                                title: 'X??c nh???n',
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.of(context).pop();
                                    widget.onPressed(
                                        materialController.materialEntity!.name.toString(),
                                        quantityController.text,
                                        materialController.materialEntity!.unit.toString());
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

  Widget _buildTextLabel(String text) {
    return Container(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: text,
            style: AppTextStyle.blackS14,
          ),
        ]),
      ),
    );
  }

  Widget _buildMaterialPicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: AppPageMaterialPicker(
        controller: materialController,
        onChanged: (value) {},
      ),
    );
  }
}
