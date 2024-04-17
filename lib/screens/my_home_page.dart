import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final List<String> tasks = <String>[];

  final List<bool> checkboxes = List.generate(8, (index) => false);

  bool isChecked = false;

  FocusNode _textFieldFocusNode = FocusNode();

  /*
  The TextEditingController class allows us to 
  grab the input from the TextField() widget
  This will be used later on to store the value
  in the database.
  */

  TextEditingController nameController = TextEditingController();

  void addItemToList() async {
    final String taskName = nameController.text;

    //Add to the Firestore collection
    await db.collection('tasks').add({
      'name': taskName,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      tasks.insert(0, taskName);
      checkboxes.insert(0, false);
    });
  }

  void removeItem(int index) async{
    //get the task name to be removed
    String taskNameToRemove = tasks[index];

    //Remove the task from the Firestore database
    QuerySnapshot querySnapshot = await db
    .collection('tasks')
    .where('name', isEqualTo: taskNameToRemove)
    .get();

    if(querySnapshot.size > 0){
      //get a reference to the first matching document
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

      //update the completed field to the new completion status
      await documentSnapshot.reference.delete();
    }

    //remove task from the task list and the checkboxes list
    setState(() {
      tasks.removeAt(index);
      checkboxes.removeAt(index);
    });

  }

  void clearTextField(){
    setState(() {
      nameController.clear();
    });
  }

  Future<void> fetchTasksFromFirestore() async {
    
    //get a reference to the 'tasks' collection in Firestore
    CollectionReference tasksCollection = db.collection('tasks');

    //Fetch the documents (tasks) from the collection
    QuerySnapshot querySnapshot = await tasksCollection.get();

    //create an empty list to stre the fetched task names
    List<String> fetchedTasks = [];


    //Loop through each doc (task) in the querySnapshot object
    for(QueryDocumentSnapshot docSnapshot in querySnapshot.docs){
      
      //getting the task name from the document's data
      String taskName = docSnapshot.get('name');

      //getting the completion status of the task
      bool completed = docSnapshot.get('completed');

      //add the task name to the list of fetched tasks
      fetchedTasks.add(taskName);
    }

    //updating the state to reflect the fetched tasks
    setState(() {
      tasks.clear();  //clear the existing task list
      tasks.addAll(fetchedTasks);
    });

  }

  //asynchronous function to update the completion status of the task in Firestore
  Future<void> updateTaskCompletionStatus(String taskName, bool completed) async{
    
    //get a reference to the 'tasks' collection in Firestore
    CollectionReference tasksCollection = db.collection('tasks');

    //query Firestore for documents (tasks) with the given task name
    QuerySnapshot querySnapshot = await tasksCollection.where('name',isEqualTo: taskName).get();

    //if a matching task document is found
    if(querySnapshot.size > 0){
      //get a reference to the first matching document
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

      //update the completed field to the new completion status
      await documentSnapshot.reference.update({'completed': completed});
    }

    setState(() {
      //find the index of the task in the task list
      int taskIndex = tasks.indexWhere((task) => task == taskName);

      //update the corresponding checkbox value in the checkboxes list
      checkboxes[taskIndex] = completed;
    });

  }

  //override the initState method of the State class
  @override
  void initState(){
    super.initState();

    //call the function to fetch the task from the database
    fetchTasksFromFirestore();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*
            Rows() and Columns() both have the mainAxisAlignment 
            property we can utilize to space out their child 
            widgets to our desired format.
           */
        backgroundColor: const Color.fromARGB(255, 255, 148, 184),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              /*
            SizedBox allows us to control the vertical 
            and horizontal dimensions by manipulating the 
            height or width property, or both.
            */
              height: 70,
              child: Image.asset('assets/rdplogo.png'),
            ),
            Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: 300,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child:
                      /*
          The TableCalendar() widget below is installed via 
          "flutter pub get table_calendar" or by adding the package 
          to the pubspec.yaml file.  We then import it and implement using
          configuration properties.  You can set a range and a focus day. 
          The particulars of implementation for any package can be gleaned 
          from pub.dev: https://pub.dev/packages/table_calendar.
          */
                      SingleChildScrollView(
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
            ),
            ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(4),
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: checkboxes[index]
                            ? Colors.green.withOpacity(0.7)
                            : Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(                        
                          children: [
                            Icon(
                              !checkboxes[index]
                                ? Icons.manage_history
                                : Icons.playlist_add_check_circle,
                              size: 32,
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              child: Text('${tasks[index]}',
                                style: checkboxes[index]
                                  ? TextStyle(decoration: TextDecoration.lineThrough, fontSize: 20, color: Colors.black.withOpacity(0.5))
                                  : TextStyle(fontSize: 20)
                                ),
                            ),
                              Checkbox(value: checkboxes[index], onChanged: (newValue){
                                setState(() {
                                  checkboxes[index] = newValue!;
                                });
                                updateTaskCompletionStatus(
                                  tasks[index], newValue!
                                );
                              }),
                              IconButton(
                                onPressed: (){removeItem(index);}, icon: Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 25, right: 25),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        controller: nameController,
                        focusNode: _textFieldFocusNode,
                        style: TextStyle(fontSize: 18),
                        maxLength: 20,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Add To-Do List Item',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                          hintText: 'Enter your task here',
                          hintStyle:
                              TextStyle(fontSize: 16, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: (){
                      clearTextField();
                    }
                    ,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  addItemToList();
                  //this will unfocus the keyboard, closing it
                  _textFieldFocusNode.unfocus();
                  clearTextField();
                },
                child: Text('Add To-Do Item'),
              ),
            )
          ],
        ),
      ),
    );
  }
}