import 'package:flutter/material.dart';
import 'package:link3_task/views/widget/item_widget.dart';
import 'package:link3_task/views/widget/task_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../controller/todo_provider.dart';
import '../models/task_model.dart';
import '../service/notification_service.dart';

class TodoListView extends StatefulWidget {
  @override
  _TodoListViewState createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadTasks();
  }
  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.init();
      final hasPermission = await _notificationService.requestPermissions();

      if (hasPermission) {
        _loadTasks();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      print('Error initializing notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing notifications'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Permission Required'),
          content: Text(
              'To receive task reminders, please enable notifications for this app in your device settings.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _loadTasks() async {
    await Provider.of<TodoProvider>(context, listen: false).loadTasks();
    _checkDueTasks();
  }

  void _checkDueTasks() async{
    final dueTasks = Provider.of<TodoProvider>(context, listen: false).getDueTasks();
    for (var task in dueTasks) {
      await _notificationService.scheduleNotifications(task);
    }
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return ListView.builder(
            itemCount: todoProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = todoProvider.tasks[index];
              return TaskItem(
                task: task,
                onToggleComplete: () async{
                  final updatedTask = Task(
                    id: task.id,
                    title: task.title,
                    details: task.details,
                    dueDate: task.dueDate,
                    isCompleted: !task.isCompleted,
                  );
                  todoProvider.updateTask(updatedTask);
                  await _notificationService.scheduleNotifications(updatedTask);
                },
                onDelete: () async{
                  todoProvider.deleteTask(task.id);
                  await _notificationService.cancelNotification(task.id);
                },
                onEdit: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskDialog(task: task,),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }
}