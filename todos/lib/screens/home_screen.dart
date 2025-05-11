import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider()..loadTodos(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Todo App'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Consumer<TodoProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: 'New task',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.add),
                        color: Colors.blueAccent,
                        onPressed: () {
                          final title = _controller.text.trim();
                          if (title.isNotEmpty) {
                            provider.addTodo(title);
                            _controller.clear();
                          }
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.loadTodos,
                    child: ListView.builder(
                      itemCount: provider.todos.length,
                      itemBuilder: (context, index) {
                        final todo = provider.todos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                decoration: todo.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: todo.completed ? Colors.grey : Colors.black,
                              ),
                            ),
                            leading: Checkbox(
                              value: todo.completed,
                              onChanged: (_) => provider.toggleComplete(index),
                              activeColor: Colors.blueAccent,
                            ),
                            onTap: () => _showEditDialog(context, provider, index, todo.title),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => provider.deleteTodo(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final newTaskTitle = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddTaskScreen()),
                      );
                      if (newTaskTitle != null && newTaskTitle.isNotEmpty) {
                        provider.addTodo(newTaskTitle);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Add New Task',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TodoProvider provider, int index, String currentTitle) {
    final TextEditingController editController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Task'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Enter new task title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = editController.text.trim();
              if (newTitle.isNotEmpty) {
                provider.editTodoTitle(index, newTitle);
              }
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          )
        ],
      ),
    );
  }
}
