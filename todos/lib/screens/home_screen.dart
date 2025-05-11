import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider()..loadTodos(),
      child: Scaffold(
        appBar: AppBar(title: Text('Todo App')),
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
                          decoration: InputDecoration(labelText: 'New task'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
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
                        return ListTile(
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          leading: Checkbox(
                            value: todo.completed,
                            onChanged: (_) => provider.toggleComplete(index),
                          ),
                          onTap: () => _showEditDialog(context, provider, index, todo.title),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => provider.deleteTodo(index),
                          ),
                        );
                      },
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
        content: TextField(controller: editController),
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
