import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  final String title;
  final String description;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
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
            MaterialPageRoute(builder: (context) => const ToDoList()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ToDoList extends StatelessWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Liste'),
      ),
      body: const AddTaskForm(),
    );
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
  final List<Task> tasks = [];

  void addTask() {
    final title = titleController.text;
    final description = descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      setState(() {
        tasks.add(Task(title: title, description: description));
        titleController.clear();
        descriptionController.clear();
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
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return CheckboxListTile(
            value: widget.tasks[index].isCompleted,
            onChanged: (bool? value) {
              setState(() {
                widget.tasks[index].isCompleted = value ?? false;
              });
            },
            title: Text(widget.tasks[index].title),
            subtitle: Text(widget.tasks[index].description),
          );
        },
      ),
    );
  }
}
