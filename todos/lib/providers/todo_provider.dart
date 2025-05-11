import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoProvider extends ChangeNotifier {
  final TodoService _service = TodoService();
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    _todos = await _service.fetchTodos();
    notifyListeners();
  }

  Future<void> addTodo(String title) async {
    final newTodo = await _service.createTodo(title);
    _todos.add(newTodo);
    notifyListeners();
  }

  Future<void> toggleComplete(int index) async {
    final todo = _todos[index];
    final updated = Todo(id: todo.id, title: todo.title, completed: !todo.completed);
    final todoFromApi = await _service.updateTodo(updated);
    _todos[index] = todoFromApi;
    notifyListeners();
  }

  Future<void> editTodoTitle(int index, String newTitle) async {
    final updated = Todo(id: _todos[index].id, title: newTitle, completed: _todos[index].completed);
    final todoFromApi = await _service.updateTodo(updated);
    _todos[index] = todoFromApi;
    notifyListeners();
  }

  Future<void> deleteTodo(int index) async {
    await _service.deleteTodo(_todos[index].id);
    _todos.removeAt(index);
    notifyListeners();
  }
}
