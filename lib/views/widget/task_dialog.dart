import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/todo_provider.dart';
import '../../models/task_model.dart';
import '../../service/notification_service.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final NotificationService _notificationService = NotificationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _detailsController = TextEditingController(text: widget.task?.details ?? '');
    if (widget.task != null) {
      _selectedDate = widget.task!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey, // Add a GlobalKey<FormState> _formKey = GlobalKey<FormState>(); to your state class
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title*',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: 'Details*',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Details are required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Due Date*'),
                subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {

            // Validate all fields
            if (_formKey.currentState!.validate()) {
              final task = Task(
                id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
                title: _titleController.text.trim(),
                details: _detailsController.text.trim(),
                dueDate: _selectedDate,
              );

              try {
                if (widget.task == null) {
                  Provider.of<TodoProvider>(context, listen: false).addTask(task);
                  await _notificationService.scheduleNotifications(task);
                } else {
                  Provider.of<TodoProvider>(context, listen: false).updateTask(task);
                  await _notificationService.scheduleNotifications(task);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving task: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}