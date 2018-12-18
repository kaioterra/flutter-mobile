import 'package:memoize/memoize.dart';
import 'package:built_collection/built_collection.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/ui/list_ui_state.dart';

var memoizedDropdownTaskList = memo2(
    (BuiltMap<int, TaskEntity> taskMap, BuiltList<int> taskList) =>
        dropdownTasksSelector(taskMap, taskList));

List<int> dropdownTasksSelector(
    BuiltMap<int, TaskEntity> taskMap, BuiltList<int> taskList) {
  final list =
      taskList.where((taskId) => taskMap[taskId].isActive).toList();

  list.sort((taskAId, taskBId) {
    final taskA = taskMap[taskAId];
    final taskB = taskMap[taskBId];
    return taskA.compareTo(taskB, TaskFields.updatedAt, false);
  });

  return list;
}

var memoizedFilteredTaskList = memo3((BuiltMap<int, TaskEntity> taskMap,
        BuiltList<int> taskList, ListUIState taskListState) =>
    filteredTasksSelector(taskMap, taskList, taskListState));

List<int> filteredTasksSelector(BuiltMap<int, TaskEntity> taskMap,
    BuiltList<int> taskList, ListUIState taskListState) {
  final list = taskList.where((taskId) {
    final task = taskMap[taskId];
    if (!task.matchesStates(taskListState.stateFilters)) {
      return false;
    }
    if (taskListState.filterEntityId != null &&
        task.clientId != taskListState.filterEntityId) {
      return false;
    }
    if (taskListState.custom1Filters.isNotEmpty &&
        !taskListState.custom1Filters.contains(task.customValue1)) {
      return false;
    }
    if (taskListState.custom2Filters.isNotEmpty &&
        !taskListState.custom2Filters.contains(task.customValue2)) {
      return false;
    }
    /*
    if (taskListState.filterEntityId != null &&
        task.entityId != taskListState.filterEntityId) {
      return false;
    }
    */
    return task.matchesFilter(taskListState.filter);
  }).toList();

  list.sort((taskAId, taskBId) {
    final taskA = taskMap[taskAId];
    final taskB = taskMap[taskBId];
    return taskA.compareTo(
        taskB, taskListState.sortField, taskListState.sortAscending);
  });

  return list;
}
