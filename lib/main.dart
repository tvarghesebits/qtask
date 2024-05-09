import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'UXdmzyiCSixlgr3DWMBNqPenb75lpLQBIYrmHBiI',
    'https://parseapi.back4app.com/',
    clientKey: 'TfG0HjDaKfsih2ajiq1UOfYWS4KCtq6uwhtlEngb',
    autoSendSessionId: true,
    debug: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to registration screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register(BuildContext context) async {
    final user = ParseUser(_usernameController.text, _passwordController.text, null);
    final response = await user.signUp(allowWithoutEmail: true);

    if (response.success) {
      // Registration successful, navigate to todo list screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListScreen()),
      );
    } else {
      // Registration failed, show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(response.error!.message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    final response = await ParseUser(_usernameController.text, _passwordController.text, null).login();

    if (response.success) {
      // Login successful, navigate to todo list screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListScreen()),
      );
    } else {
      // Login failed, show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(response.error!.message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to add todo screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTodoScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
             // await ParseUser.currentUser().logout();
              // Logout successful, navigate back to authentication screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthenticationScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder<List<dynamic>>(
          future: _fetchTodos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final todos = snapshot.data;
              return ListView.builder(
                itemCount: todos!.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return ListTile(
                    leading: IconButton(
                      icon: Icon( (!todo.get('complete')) ? Icons.check_box_outline_blank_outlined : Icons.check_box),
                      onPressed: () async {
                        todo.set('complete', !todo.get('complete'));
                        await todo.save();
                        // Refresh todo list after deletion
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TodoListScreen()),
                        );
                      },
                    ),
                    title: Text(todo.get('title'), style: (todo.get('complete')) ? TextStyle(decoration: TextDecoration.lineThrough) : TextStyle(decoration: TextDecoration.none)),
                    subtitle: Text(todo.get('duedate') ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await todo.delete();
                        // Refresh todo list after deletion
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TodoListScreen()),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<dynamic>> _fetchTodos() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('ToDo'));
    final response = await queryBuilder.query();
    if (response.success) {
      return response.results ?? [];
    } else {
      throw Exception('Failed to fetch todos: ${response.error!.message}');
    }
  }
}

class AddTodoScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  void _addTodo(BuildContext context) async {
    final todoItem = new ParseObject("ToDo");
    todoItem.set('title',  _titleController.text);
    todoItem.set('duedate', _dateController.text);

    // _titleController.text
    // ParseUser.currentUser()

    final response = await todoItem.save();

    if (response.success) {
      // Todo added successfully, navigate back to todo list screen
     // Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListScreen()),
      );

    } else {
      // Todo creation failed, show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(response.error!.message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Todo Title'),
            ),
            TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  // You can add more specific validation for the date format here
                  return null;
                },
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addTodo(context),
              child: Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }
}
