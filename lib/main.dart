import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Колоквиуми и Испити',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyAppClass(),
    );
  }
}

class MyAppClass extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppClass> {
  void addNewSubject() {
    var subject = subjectController.text;
    var date = dateController.text;
    var time = timeController.text;

    var exam = {
      'subject': subject,
      'termin': date,
      'time': time,
    };

    setState(() {
      elements.add(exam);
    });
  }

  final subjectController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  List<Map<String, String>> elements = [];
  _MyAppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Колоквиуми и Испити"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => addNewSubject(),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          Card(
            elevation: 5,
            margin: EdgeInsets.all(15),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Додади термин',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Име на Предмет',
                    ),
                    controller: subjectController,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Датум полагање',
                    ),
                    controller: dateController,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Време на полагање',
                    ),
                    controller: timeController,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: elements.length,
              itemBuilder: (contx, index) {
                return Card(
                  elevation: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          elements[index]['subject'] as String,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(contx).primaryColorDark,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          elements[index]['termin'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          elements[index]['time'] as String,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
