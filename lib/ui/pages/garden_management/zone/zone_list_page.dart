import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base/commons/app_colors.dart';
import 'package:flutter_base/commons/app_images.dart';
import 'package:flutter_base/commons/app_text_styles.dart';
import 'package:flutter_base/database/share_preferences_helper.dart';
import 'package:flutter_base/main.dart';
import 'package:flutter_base/models/entities/zone/zone_entity.dart';
import 'package:flutter_base/models/enums/load_status.dart';
import 'package:flutter_base/network/api_client_bagri.dart';
import 'package:flutter_base/repositories/zone_repository.dart';
import 'package:flutter_base/router/application.dart';
import 'package:flutter_base/router/routers.dart';
import 'package:flutter_base/ui/pages/garden_management/garden_list/garden_list_page.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_bar_widget.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_button.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_delete_dialog.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_emty_data_widget.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_error_list_widget.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_snackbar.dart';
import 'package:flutter_base/ui/widgets/b_agri/app_text_field.dart';
import 'package:flutter_base/ui/widgets/b_agri/custome_slidable_widget.dart';
import 'package:flutter_base/utils/validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'zone_list_cubit.dart';

class ZoneListPage extends StatefulWidget {
  @override
  _GardenListState createState() => _GardenListState();
}

class _GardenListState extends State<ZoneListPage> {
  ZoneListCubit? _cubit;
  bool isErrorMessage = false;
  bool isAdd = false;

  ApiClient? _apiClientBagri;
  ZoneRepository? zoneRepository;
  final accessToken = SharedPreferencesHelper.getToken().toString();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameZoneController = TextEditingController(text: '');
  final _nameModifyController = TextEditingController(text: '');

  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ZoneListCubit>(context);
    _cubit!.fetchZoneList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBarWidget(
          title: "Danh s??ch khu v???c",
          context: context,
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Container(
          child: BlocBuilder<ZoneListCubit, ZoneListState>(
            bloc: _cubit,
            buildWhen: (previous, current) =>
                previous.getZoneStatus != current.getZoneStatus,
            builder: (context, state) {
              if (state.getZoneStatus == LoadStatus.LOADING) {
                return Center(
                    child: CircularProgressIndicator(color: AppColors.main));
              } else if (state.getZoneStatus == LoadStatus.FAILURE) {
                return AppErrorListWidget(
                  onRefresh: _onRefreshData,
                );
              } else if (state.getZoneStatus == LoadStatus.SUCCESS) {
                return state.listZoneData!.length != 0
                    ? RefreshIndicator(
                        color: AppColors.main,
                        onRefresh: _onRefreshData,
                        child: ListView.separated(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 25),
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: state.listZoneData!.length,
                          shrinkWrap: true,
                          primary: false,
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            ZoneEntity zone = state.listZoneData![index];
                            return _buildItem(
                              name: zone.name ?? "",
                              onPressed: () async {
                                Application.router?.navigateTo(
                                    appNavigatorKey.currentContext!,
                                    Routes.gardenList,
                                    routeSettings: RouteSettings(
                                      arguments: GardenListArgument(
                                          titleScreen: zone.name,
                                          zone_id: zone.zone_id),
                                    ));
                              },
                              onDelete: () async {
                                bool isDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AppDeleteDialog(
                                          onConfirm: () async {
                                            await _cubit!
                                                .deleteZone(zone.zone_id);
                                            Navigator.pop(context, true);
                                          },
                                        ));

                                if (isDelete) {
                                  _onRefreshData();
                                  showSnackBar(
                                      'X??a khu v???c th??nh c??ng!', "success");
                                }
                              },
                              onUpdate: () async {
                                bool isModify = await showDialog(
                                    context: context,
                                    builder: (context) => _dialogModify(
                                          title: Text("Thay ?????i t??n khu"),
                                          hintText: "Nh???p v??o t??n khu",
                                          spanText: "T??n khu",
                                          textEditingController:
                                              _nameModifyController,
                                          zoneName: zone.name,
                                          validator: (value) {
                                            if (Validator.validateNullOrEmpty(
                                                value!))
                                              return "Ch??a nh???p t??n khu";
                                            else if (value == zone.name) {
                                              return "T??n ???? b??? tr??ng!";
                                            } else
                                              return null;
                                          },
                                          onConfirm: (() async => {
                                                if (_formKey.currentState!
                                                    .validate())
                                                  {
                                                    await _cubit!.modifyZone(
                                                        zone.zone_id,
                                                        _nameModifyController
                                                            .text),
                                                    if (state
                                                            .modifyZoneStatus ==
                                                        LoadStatus.SUCCESS)
                                                      {
                                                        Navigator.pop(
                                                            context, true),
                                                        // _nameZoneController.clear(),
                                                      }
                                                    else
                                                      {
                                                        Navigator.pop(
                                                            context, false),
                                                      }
                                                  }
                                              }),
                                        ));
                                if (state.modifyZoneStatus ==
                                    LoadStatus.SUCCESS) {
                                  _onRefreshData();
                                  showSnackBar(
                                      'Thay ?????i t??n th??nh c??ng!', "success");
                                } else {
                                  showSnackBar("T??n khu ???? t???n t???i", "error");
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 10);
                          },
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [EmptyDataWidget()],
                        ));
              } else {
                return Container();
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "btn2",
          onPressed: () async {
            bool isAddSuccess = await showDialog(
                context: context,
                builder: (context) => _dialogCreate(
                      title: Text("Th??m khu m???i"),
                      hintText: "Nh???p v??o t??n khu",
                      spanText: "T??n khu",
                      textEditingController: _nameZoneController,
                    ));
            if (isAddSuccess) {
              _onRefreshData();
              showSnackBar("Th??m khu th??nh c??ng", "success");
            } else {
              showSnackBar("T??n khu ???? t???n t???i", "error");
            }
          },
          backgroundColor: AppColors.main,
          child: Icon(
            Icons.add,
            size: 40,
          ),
        ),
      ),
    );
  }

  _buildItem(
      {required String name,
      String? avatarUrl,
      VoidCallback? onDelete,
      VoidCallback? onPressed,
      VoidCallback? onUpdate}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.grayEC,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Slidable(
          endActionPane: ActionPane(
            extentRatio: 1 / 3,
            motion: BehindMotion(),
            children: [
              CustomSlidableAction(
                  backgroundColor: AppColors.blueSlideButton,
                  foregroundColor: Colors.white,
                  onPressed: (BuildContext context) {
                    onUpdate?.call();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Image.asset(AppImages.icSlideEdit),
                      ),
                      SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          'S???a',
                          style: AppTextStyle.whiteS16,
                        ),
                      )
                    ],
                  )),
              CustomSlidable(
                  backgroundColor: AppColors.redSlideButton,
                  foregroundColor: Colors.white,
                  onPressed: (BuildContext context) {
                    onDelete?.call();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Image.asset(AppImages.icSlideDelete),
                      ),
                      SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          'X??a',
                          style: AppTextStyle.whiteS16,
                        ),
                      )
                    ],
                  )),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
            child: Row(
              children: [
                Image.asset(avatarUrl ?? AppImages.icZoneAvatar),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                        color: Color(0xFF5C5C5C),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogModify({
    Text? title,
    String? hintText,
    String? spanText,
    VoidCallback? onConfirm,
    final FormFieldValidator<String>? validator,
    TextEditingController? textEditingController,
    String? zoneName,
  }) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: title,
        content: Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: 28),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: spanText,
                      style: AppTextStyle.blackS14,
                    ),
                  ]),
                ),
              ),
              Container(
                  // margin: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: AppTextField(
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      hintText: hintText.toString(),
                      controller: textEditingController,
                      validator: validator,
                    ),
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                AppButton(
                    height: 40,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(16),
                    // ),
                    color: AppColors.redButton,
                    onPressed: (() => {Navigator.of(context).pop()}),
                    child: Text("H???y",
                        style: TextStyle(color: Colors.white, fontSize: 14))),
                AppButton(
                    height: 40,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(16),
                    // ),
                    color: AppColors.main,
                    onPressed: onConfirm,
                    child: Text(
                      "Th??m",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ))
              ])
            ])),
      );
    });
  }

  Widget _dialogCreate({
    Text? title,
    String? hintText,
    String? spanText,
    TextEditingController? textEditingController,
    String? zoneName,
  }) {
    return StatefulBuilder(builder: (context, state) {
      return AlertDialog(
        title: title,
        content: Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Container(
              //   alignment: Alignment.centerLeft,
              //   // margin: EdgeInsets.symmetric(horizontal: 28),
              //   child: RichText(
              //     text: TextSpan(children: [
              //       TextSpan(
              //         text: spanText,
              //         style: AppTextStyle.blackS14,
              //       ),
              //     ]),
              //   ),
              // ),
              // SizedBox(height: 15,),
              Container(
                  // margin: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: AppTextField(
                      labelText: 'T??n khu',
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      hintText: 'T??n khu' /*hintText.toString()*/,
                      controller: textEditingController,
                      validator: (value) {
                        if (Validator.validateNullOrEmpty(value!))
                          return "Ch??a nh???p t??n khu";
                        else if (value == zoneName) {
                          return "T??n ???? b??? tr??ng!";
                        } else
                          return null;
                      },
                    ),
                  )),
              SizedBox(
                height: 15,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                // FlatButton(
                //     height: 40,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(16),
                //     ),
                //     color: AppColors.redButton,
                //     onPressed: (() => {Navigator.of(context).pop()}),
                //     child: Text("H???y",
                //         style: TextStyle(color: Colors.white, fontSize: 14))),
                Expanded(
                  child: AppButton(
                    color: AppColors.redButton,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: 'H???y',
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(child: _buildConfirmCreateButton())
              ])
            ])),
      );
    });
  }

  Widget _buildConfirmCreateButton() {
    return BlocBuilder<ZoneListCubit, ZoneListState>(
      bloc: _cubit,
      buildWhen: (prev, current) {
        return (prev.createZoneStatus != current.createZoneStatus);
      },
      builder: (context, state) {
        return AppButton(
          color: AppColors.main,
          title: "Th??m",
          textStyle: AppTextStyle.whiteS16Bold,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await _cubit!.createZone(_nameZoneController.text);
              //         .then(
              //             (value) => {
              //               if(state.createZoneStatus == LoadStatus.FAILURE){
              //                 showSnackBar("T??n khu ???? t???n t???i", "error"),
              //                 Navigator.pop(context),
              //               } else {
              //                 Navigator.pop(context),
              //                 showSnackBar("Th??m khu th??nh c??ng", "success"),
              //                 _onRefreshData(),
              //   }
              // });
              if (state.createZoneStatus == LoadStatus.FAILURE) {
                //showSnackBar("T??n khu ???? t???n t???i", "error");
                Navigator.pop(context, false);
              } else {
                Navigator.pop(context, true);
                //showSnackBar("Th??m khu th??nh c??ng", "success");
                // _onRefreshData();
              }
            }
          },
        );
      },
    );
  }

  Future<void> _onRefreshData() async {
    _cubit!.fetchZoneList();
  }

  void showSnackBar(String message, String typeSnackBar) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(AppSnackBar(
      typeSnackBar: typeSnackBar,
      message: message,
    ));
  }

  void _showMessage(String message, String type) {
    _scaffoldKey.currentState!.removeCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(AppSnackBar(
      message: message,
      typeSnackBar: type,
    ));
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      // _cubit!.fetchNextGardenData();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
