import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*

  Final Project for SWDV 1011
  submitted by
  Nerizza Jane de Jesus

  */

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final snackBar = SnackBar(content: Text('Your task has been added'),);

  //temporary List to serve as container for the fetched tasks from Firestore
  final List<String> tasks = <String>[];

  //temporary List to serve as container for the checkbox status of each task
  final List<bool> checkboxes = List.generate(8, (index) => false);

  //bool isChecked = false;  //variable not used, commented out

  //creates an private instance of the FocusNode class named _textFieldFocusNode
  //used in hiding keyboard 
  FocusNode _textFieldFocusNode = FocusNode();

  /*
  The TextEditingController class allows us to 
  grab the input from the TextField() widget
  This will be used later on to store the value
  in the database.
  */
  TextEditingController nameController = TextEditingController();

  //method to add user input in the app to the Firestore collection
  void addItemToList() async {
    //store the user's input in this variable
    final String taskName = nameController.text;

    //Add to the Firestore collection
    await db.collection('tasks').add({
      'name': taskName,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    //lifecycle method to call whenever there is a change in the UI, to rebuild the widget tree
    setState(() {
      tasks.insert(0, taskName);  //add the taskName(user input) to the List
      checkboxes.insert(0, false); //add the default value (false) to the list
    });
  }

  //removes tasks(identified by index) from the Firestore database
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

      //deletes the first matching document from the Firestore collection
      await documentSnapshot.reference.delete();
    }

    //remove task from the task list and the checkboxes list
    setState(() {
      tasks.removeAt(index);
      checkboxes.removeAt(index);
    });

  }

  //clears text in the user input field (task name)
  void clearTextField(){
    setState(() {
      nameController.clear();
    });
  }

  //asynchronous function to retrieve existing tasks in Firestore to be displayed during the app's start-up
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
      tasks.addAll(fetchedTasks); //add all the tasks from fetchedTasks List to the local <String> list "tasks" 
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

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //override the initState method of the State class
  @override
  void initState(){
    super.initState();

    //call the function to fetch the task from the database
    fetchTasksFromFirestore();

  } 

  Drawer _buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Sign Out'),
          onTap: () {
            signOut();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
    

  @override
  Widget build(BuildContext context) {

    Future<List<Weather>> getData() async{
      String? cityName = 'Red Deer, CA';
      WeatherFactory wf = WeatherFactory('8304d958a25b1e36e2db333baee384c7');
      List<Weather> forecast = await wf.fiveDayForecastByCityName(cityName);
      return forecast;
    }

    return Scaffold(
      //appBar widget holds the contents for app's topmost contents
      appBar: AppBar(
        /*
            Rows() and Columns() both have the mainAxisAlignment 
            property we can utilize to space out their child 
            widgets to our desired format.
           */
        //sets the color on the appBar
        backgroundColor: const Color.fromARGB(255, 255, 148, 184),
        title: Row(
          //sets the free space evenly between the rdp logo and the "Daily Planner" text
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
      drawer: _buildDrawer(context),
      //body portion holds the main components of the app
      //we use container to allow the use of decoration properties
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
                      //the TableCalendar widget is wrapped in SingleChildScrollView to allow 
                      // calendar to be scrollable in the event of overflow by another components
                      SingleChildScrollView(
                        child: TableCalendar(
                                            calendarFormat: CalendarFormat.twoWeeks,
                                            headerVisible: false,
                                            focusedDay: DateTime.now(),
                                            firstDay: DateTime(2023),
                                            lastDay: DateTime(2025),
                                          ),
                      ),
                ),
              ),
            ),
            FutureBuilder<List<Weather>>(
              future: getData(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return CircularProgressIndicator();
                }else if(snapshot.hasError){
                  return Text('Error: ${snapshot.error}');
                }else if(snapshot.hasData){
                  List<Weather> forecast = snapshot.data!;

                  //Extracting weather, temp, and wind information
                  String city = 'Red Deer, CA';
                  Weather firstWeather = forecast[0];
                  String? weatherCondition = firstWeather.weatherMain;
                  double? temperature = firstWeather.temperature?.celsius;
                  double? windSpeed = firstWeather.windSpeed;

                  return SingleChildScrollView(
                    child: Container(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$city', style: TextStyle(fontSize: 24),),
                            Text('Weather Condition: $weatherCondition'),
                            Text('Temperature: $temperature'),
                            Text('Wind Speed: $windSpeed'),
                          ],
                        ),
                      ),
                    ),
                  );
                }else{
                  return Text('No data available!');
                }
              },            
            ),
            //creates children on demand, number of children based on itemCount variable below
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(4),
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.only(bottom:1.0, top: 1.0),
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
                              //the texts are wrapped in Expanded widget to allow consistent spacing irrelative to the actual length of the text
                              Expanded(
                                child: Text('${tasks[index]}',
                                //if checkbox is ticked, show lineThrough text, if not ticked, show as normal
                                  style: checkboxes[index]
                                    ? TextStyle(decoration: TextDecoration.lineThrough, fontSize: 20, color: Colors.black.withOpacity(0.5))
                                    : TextStyle(fontSize: 20)
                                  ),
                              ),
                                //updates the task with its status in the Firestore(via updateTaskCompletionStatus call) when there is change in the checkbox
                                Checkbox(value: checkboxes[index], onChanged: (newValue){
                                  setState(() {
                                    checkboxes[index] = newValue!;
                                  });
                                  updateTaskCompletionStatus(
                                    tasks[index], newValue!
                                  );
                                }),
                                IconButton(
                                  //upon pressing the delete icon, proceeds to call removeItem 
                                  //method which removes the task from the Firestore collection
                                  onPressed: (){removeItem(index);}, icon: Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
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
                        //styling for the user input field
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
                    //upon pressing the X icon, clear all the texts in the user input field
                    onPressed: (){clearTextField();},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                //upon pressing the "Add To-Do Item" perform the tasks as follows:
                onPressed: () {
                  //add task name to Firestore collection
                  addItemToList();
                  //unfocus the keyboard, closing it
                  _textFieldFocusNode.unfocus();
                  //clear text in the input field
                  clearTextField();
                  //show snackBar notification that the task has been created
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Text('Add To-Do Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}