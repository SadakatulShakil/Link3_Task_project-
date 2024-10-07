import 'package:flutter/foundation.dart';

import '../helper/database_helper.dart';
import '../models/task_model.dart';

class TodoProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper.instance.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final newTask = await DatabaseHelper.instance.create(task);
    _tasks.add(newTask);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.update(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.delete(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  List<Task> getDueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) =>
    !task.isCompleted &&
        task.dueDate.year == now.year &&
        task.dueDate.month == now.month &&
        task.dueDate.day == now.day
    ).toList();
  }
}