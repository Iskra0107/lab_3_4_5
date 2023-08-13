import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lab_3_4_5/login_screen.dart';
import 'package:lab_3_4_5/register_screen.dart';
import 'package:lab_3_4_5/slot_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as timeZone;

late User loggedInUser;
late FirebaseMessaging _firebaseMessaging;
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance channel',
  'Потсетник за Испити',
  description: 'Наскоро имате испит! Допрете за да го видите вашиот распоред',
  importance: Importance.high,
  playSound: true,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _firebaseMessaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Организатор на Испити',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      initialRoute: '$LoginScreen.id',
      routes: {
        '/': (context) => const MyAppClass(),
        '$LoginScreen.id': (context) => const LoginScreen(),
        '$RegistrationScreen.id': (context) => const RegistrationScreen(),
      },
    );
  }
}

class MyAppClass extends StatefulWidget {
  const MyAppClass({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppClass> {
  final _auth = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;

  final subjectController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  List<Map<String, String>> elements = [];
  List<Map<String, String>> _selectedElements = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void getCurrentUserAndData() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        _store
            .collection('Exams')
            .where('UserEmail', isEqualTo: user.email)
            .get()
            .then((value) {
          for (var element in value.docs) {
            Map<String, String> slot = {
              "subject": element.data()['Predmet'] as String,
              "termin": element.data()['Termin'] as String,
              "time": element.data()['Vreme'] as String
            };
            setState(() {
              elements.add(slot);
            });
          }
        });
      }
    } catch (e) {}
  }

  void addSubject() async {
    String name = subjectController.text;
    String termin = dateController.text;
    String time = timeController.text;

    Map<String, String> newSlot = {
      "Predmet": name,
      "Termin": termin,
      "Vreme": time,
      "UserEmail": loggedInUser.email.toString()
    };
    await _store.collection('Exams').doc().set(newSlot);
    setState(() {
      elements.add({"subject": name, "termin": termin, "time": time});
    });

    var parser = DateFormat('dd.MM.yyyy');
    var terminParsed = parser.parse("${termin}T07:00");

    flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Организатор на Испити',
      'Наскоро имате испит! Допрете за да го видите вашиот распоред',
      timeZone.TZDateTime.from(terminParsed, timeZone.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          color: const Color(0xff676FA3),
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
    );
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    List<Map<String, String>> filteredElements = [];
    elements.forEach((element) {
      var parser = DateFormat('dd.MM.yyyy');
      var termin = parser.parse(element['termin'] as String);

      if (termin.toString() == day.toString().replaceAll("Z", "")) {
        filteredElements.add(element);
      }
    });
    return filteredElements;
  }

  _MyAppState();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;

      if (notification != null && androidNotification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: const Color(0xff676FA3),
            playSound: true,
            icon: '@mipmap/ic_launcher',
          )),
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;

      if (notification != null && androidNotification != null) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title != null
                  ? notification.title!
                  : 'Организатор на Испити'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body != null
                        ? notification.body!
                        : 'Наскоро имате испит! Допрете за да го видите вашиот распоред')
                  ],
                ),
              ),
            );
          },
        );
      }
    });
    getCurrentUserAndData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          direction: Axis.vertical,
          clipBehavior: Clip.hardEdge,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = selectedDay;
                    _selectedElements = _getEventsForDay(selectedDay);
                  });
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SingleChildScrollView(
                    child: Container(
                      height: 400,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: SlotsView(
                        elements: _selectedElements,
                      ),
                    ),
                  ),
                );
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
            ),
            Expanded(
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Внеси податоци',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Име на предмет',
                        ),
                        controller: subjectController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Датум полагање',
                            hintText: 'Пр: 25.02.2022'),
                        controller: dateController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Време полагање',
                        ),
                        controller: timeController,
                      ),
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Color.fromARGB(255, 93, 100, 143),
                      child: MaterialButton(
                        onPressed: () => addSubject(),
                        child: const Text(
                          'Додај',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
