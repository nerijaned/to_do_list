import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Color.fromARGB(255, 255, 163, 213),
         toolbarHeight: 70.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 90,
              child: Image.asset('assets/rdplogo.png'),
            ),
            Text('Daily Planner',
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 32,
              color: Colors.white,
            ),
            ),
          ],
        )
        ),
        body: Container(
          color: Colors.grey[200],
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 300,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: TableCalendar(
                      calendarFormat: CalendarFormat.month,
                      headerVisible: false,
                      focusedDay: DateTime.now(),
                      firstDay: DateTime(2023),
                      lastDay: DateTime(2025),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 350,
                      height: 100,
                      child: TextField(
                      maxLength: 20,
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                          labelText: 'Add To-Do List Item',
                      ),
                    )
                    ),
                  ],
                ),
              ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(onPressed: null, child: Text('Submit')),
          ),
          ],
          ),
        ),
    );
  }
}