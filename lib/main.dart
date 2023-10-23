import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Task {
  final int id;
  final String title;
  final String description;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}

class TaskManager {
  static const String storageKey = 'tasks';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = prefs.getString(storageKey);
    if (taskJson != null) {
      final taskList = json.decode(taskJson) as List<dynamic>;
      return taskList.map((taskMap) => Task.fromJson(taskMap)).toList();
    } else {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((task) => task.toJson()).toList();
    final taskJson = json.encode(taskList);
    await prefs.setString(storageKey, taskJson);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'To do list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TaskManager taskManager = TaskManager();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await taskManager.loadTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ToDoList(tasks: tasks, taskManager: taskManager)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ToDoList extends StatelessWidget {
  final List<Task> tasks;
  final TaskManager taskManager;

  const ToDoList({Key? key, required this.tasks, required this.taskManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle Liste'),
        ),
        body: const AddTaskForm(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await taskManager.saveTasks(tasks);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          },
          child: const Icon(Icons.save),
        ));
  }
}

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddTaskFormState createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int taskId = 0;
  final List<Task> tasks = [];

  void addTask() {
    final title = titleController.text;
    final description = descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      setState(() {
        tasks.add(Task(id: taskId, title: title, description: description));
        titleController.clear();
        descriptionController.clear();
        taskId++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Titre'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: addTask,
              child: const Text('Ajouter la tâche'),
            ),
          ),
          ListItems(tasks: tasks),
        ],
      ),
    );
  }
}

class ListItems extends StatefulWidget {
  final List<Task> tasks;

  const ListItems({Key? key, required this.tasks}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  void deleteTask(int taskId) {
    setState(() {
      widget.tasks.removeWhere((task) => task.id == taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = widget.tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  task.isCompleted = value ?? false;
                });
              },
            ),
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteTask(task.id);
              },
            ),
          );
        },
      ),
    );
  }
}
