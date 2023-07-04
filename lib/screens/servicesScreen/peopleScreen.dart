import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Person {
  final String name;
  final String details;
  final Uint8List? picture;

  Person({required this.name, required this.details, this.picture});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': details,
      'picture': picture != null ? base64Encode(picture!) : null,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      details: json['details'],
      picture: json['picture'] != null ? base64Decode(json['picture']) : null,
    );
  }
}

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<Person> _people = [];
  bool _dataLoaded = false;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _loadPeople();
    startScanForSmartWatch();
  }

  void startScanForSmartWatch() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == 'SmartWatch') {
          flutterBlue.stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    setState(() {
      connectedDevice = device;
    });
  }

  void sendDataToSmartWatch(List<int> data) async {
    if (connectedDevice != null) {
      List<BluetoothService> services = await connectedDevice!.discoverServices();
      services.forEach((service) {
        service.characteristics.forEach((characteristic) async {
          if (characteristic.uuid.toString() == 'your_characteristic_uuid') {
            await characteristic.write(data);
          }
        });
      });
    }
  }

  void _loadPeople() async {
    if (!_dataLoaded) {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? peopleJson = prefs.getStringList('people');

      if (peopleJson != null) {
        setState(() {
          _people = peopleJson
              .map((json) => Person.fromJson(jsonDecode(json) as Map<String, dynamic>))
              .toList();
        });
      }

      setState(() {
        _dataLoaded = true;
      });
    }
  }

  void _savePerson(Person person) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> peopleJson =
    _people.map((person) => jsonEncode(person.toJson())).toList();

    prefs.setStringList('people', peopleJson);

    setState(() {
      _people.add(person);
    });

    sendDataToSmartWatch(jsonEncode(person.toJson()).codeUnits);
  }
  Future<Person?> _addPerson(BuildContext context) async {
    String name = '';
    String details = '';
    Uint8List? picture;

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final pickedImageBytes = await pickedImage.readAsBytes();
      picture = Uint8List.fromList(pickedImageBytes);
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Details'),
                onChanged: (value) {
                  details = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(
                    Person(
                      name: name,
                      details: details,
                      picture: picture,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    return picture != null ? Person(name: name, details: details, picture: picture) : null;
  }

  void _updatePerson(BuildContext context, int index) async {
    final person = await _addPerson(context);
    if (person != null) {
      setState(() {
        _people[index] = person;
      });
      _savePeopleToPrefs();
    }
  }


  void _deletePerson(int index) {
    setState(() {
      _people.removeAt(index);
    });
    _savePeopleToPrefs();
  }

  void _savePeopleToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> peopleJson =
    _people.map((person) => jsonEncode(person.toJson())).toList();

    prefs.setStringList('people', peopleJson);
  }

  void _showPersonDialog(BuildContext context, Person person, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Person Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (person.picture != null)
                CircleAvatar(
                  backgroundImage: MemoryImage(person.picture!),
                  radius: 40,
                ),
              SizedBox(height: 8),
              Text('Name: ${person.name}'),
              Text('Details: ${person.details}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updatePerson(context, index);
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePerson(index);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'الاشخاص المقربين',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: _people.isEmpty
          ? Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/alarmEmpty.png'),
          ),
        ),
      )
          : ListView.builder(
        itemCount: _people.length,
        itemBuilder: (BuildContext context, int index) {
          final person = _people[index];
          return GestureDetector(
            onTap: () {
              _showPersonDialog(context, person, index);
            },
            child: ListTile(
              leading: person.picture != null
                  ? CircleAvatar(
                backgroundImage: MemoryImage(person.picture!),
              )
                  : CircleAvatar(),
              title: Text(person.name),
              subtitle: Text(person.details),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          _addPerson(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alzheimer Helper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PeopleScreen(),
    );
  }
}
