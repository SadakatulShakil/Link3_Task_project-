import 'package:flutter/material.dart';

import '../../models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  TaskItem({
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: task.isCompleted ? Colors.green.shade300 : null,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggleComplete(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.details.isNotEmpty)
              Text(task.details),
            Text(
              'Due: '+'${task.dueDate.toLocal()}'.split(' ')[0],
              style: TextStyle(
                color: task.dueDate.isBefore(DateTime.now()) && !task.isCompleted
                    ? Colors.red
                    : null,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Shrinks the row to fit its contents
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit, // Trigger onEdit callback
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}