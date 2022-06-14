import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_base/configs/app_config.dart';
import 'package:flutter_base/models/entities/garden/garden_entity.dart';
import 'package:flutter_base/models/entities/process/list_process.dart';
import 'package:flutter_base/models/entities/process/process_detail.dart';
import 'package:flutter_base/models/entities/process/stage_entity.dart';
import 'package:flutter_base/models/entities/process/step_entity.dart';
import 'package:flutter_base/models/entities/season/season_entity.dart';
import 'package:flutter_base/models/entities/tree/list_tree_response.dart';
import 'package:flutter_base/models/enums/load_status.dart';
import 'package:flutter_base/models/params/season/create_season_param.dart';
import 'package:flutter_base/models/response/object_response.dart';
import 'package:flutter_base/repositories/process_repository.dart';
import 'package:flutter_base/repositories/season_repository.dart';
import 'package:flutter_base/utils/date_utils.dart' as Util;
part 'season_adding_state.dart';

class SeasonAddingCubit extends Cubit<SeasonAddingState> {
  SeasonRepository seasonRepository;
  ProcessRepository processRepository;
  SeasonAddingCubit(
      {required this.seasonRepository, required this.processRepository})
      : super(SeasonAddingState());

  Future<void> createSeason(int treeQuantity) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      SeasonEntity param = SeasonEntity(
          name: state.seasonName,
          gardenId: state.gardenEntity!.garden_id,
          process: state.processEntity!,
          tree: state.treeEntity!,
          start_date: state.startTime ,
          end_date: state.endTime ,
          treeQuantity: treeQuantity
          );
      var result =
          await seasonRepository.createSeason(param);

      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> changeDuration(String processId) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      // ObjectResponse<ProcessDetailResponse> result =


      ProcessEntity processResult =/* result.data!.process!;*/
      await processRepository.getProcessById(processId);
      int duration = 0;
      if (processResult.stages != null) {
        for (StageEntity stage in processResult.stages!) {
          if (stage.steps != null) {
            for (StepEntity step in stage.steps!) {
              duration += step.from_day ?? 0;
            }
          }
        }
      }
      String? endTime;
      if (state.startTime != null) {
        DateTime startDateTime = Util.DateUtils.fromString(state.startTime,
            format: AppConfig.dateDisplayFormat)!;
        DateTime endDateTime = startDateTime.add(Duration(days: duration));
        endTime = Util.DateUtils.toDateString(endDateTime);
      }
      print(endTime ?? "null endtime in change duration");
      emit(state.copyWith(
        loadStatus: LoadStatus.SUCCESS,
        duration: duration,
        endTime: endTime,
        processDetail: processResult,
      ));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  void changeSeasonName(String name) {
    emit(state.copyWith(seasonName: name));
  }

  void changeGarden(GardenEntity value) {
    emit(state.copyWith(gardenEntity: value));
  }

  void changeProcess(ProcessEntity? value) {
    emit(state.copyWith(processEntity: value));
  }

  void changeTree(TreeEntity value) {
    print("beffore delete end time ${state.endTime ?? "null"}");
    emit(state.resetDuration(treeEntity: value, duration: null, endTime: null));
    print("after delete end time ${state.endTime ?? "null"}");
  }

  void changeStartTime(String startTime) {
    // DateTime startDateTime = Util.DateUtils.fromString(startTime,
    //     format: AppConfig.dateDisplayFormat)!;
    emit(state.copyWith(startTime: startTime));
    // String? endTime;
    // if (state.duration != null) {
    //   DateTime endDateTime =
    //       startDateTime.add(Duration(days: state.duration ?? 0));
    //   endTime = Util.DateUtils.toDateString(endDateTime);
    // }

    // print(endTime ?? "null endtime in change startTime");
    // emit(state.copyWith(startTime: startTime, endTime: endTime));
  }
  void changeEndTime(String endTime) {
    // DateTime endDateTime = Util.DateUtils.fromString(endTime,
    //     format: AppConfig.dateDisplayFormat)!;
    emit(state.copyWith(endTime: endTime));
    // String? endTime;
    // if (state.duration != null) {
    //   DateTime endDateTime =
    //       startDateTime.add(Duration(days: state.duration ?? 0));
    //   endTime = Util.DateUtils.toDateString(endDateTime);
    // }

    // print(endTime ?? "null endtime in change startTime");
    // emit(state.copyWith(startTime: startTime, endTime: endTime));
  }
}
