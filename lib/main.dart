import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'note.dart';
import 'DBOps.dart';
import 'dart:async';
import 'package:basic_utils/basic_utils.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(),
      home: NotesHomePage(title: 'Notes'),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  NotesHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  int _counter = 0;
  final myController = TextEditingController();
  Future<List<Note>> notesList;
  DBOps ops = DBOps.db;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    notesList = ops.noteslist();
  }

  void _getNotes(context) async {
    bool refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDialog()),
    );
    if (refresh) {
      setState(() {
        print("setting state" + refresh.toString());
        notesList = ops.noteslist();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w300),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        elevation: 0,
        brightness: Brightness.dark,
      ),
      body: FutureBuilder<List<Note>>(
        future: notesList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final note = snapshot.data[index];
                  return InkWell(
                    onTap: () {},
                    onLongPress: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext bc) {
                            return Container(
                              child: new Wrap(
                                children: <Widget>[
                                  /*new ListTile(
                                      leading: new Icon(Icons.update),
                                      title: new Text('Update'),
                                      onTap: () => {}
                                  ),*/
                                  new ListTile(
                                    leading: new Icon(Icons.delete),
                                    title: new Text('Delete'),
                                    onTap: (){
                                      print("Note id :" + note.id.toString()+"deleted");
                                      ops.deleteNote(note.id);
                                      notesList = ops.noteslist();
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );;
                          });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.2, color: Colors.brown),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  StringUtils.capitalize(note.title),
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  note.note,
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getNotes(context);
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NoteDialog extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  Note note = new Note();
  DBOps ops = DBOps.db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("New Note"),
        backgroundColor: Colors.brown,
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: EdgeInsets.all(10),
          child: new Wrap(
            children: <Widget>[
              Column(children: <Widget>[
                Form(
                  key: _formKey,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }

                            return null;
                          },
                          onSaved: (String value) {
                            this.note.title = value;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Note',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onSaved: (String value) {
                            this.note.note = value;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: RaisedButton(
                            onPressed: () async {
                              // Validate will return true if the form is valid, or false if
                              // the form is invalid.
                              if (_formKey.currentState.validate()) {
                                // Process data.
                                _formKey.currentState
                                    .save(); // Save our form now.

                                print('Printing the Notes');
                                print('Title: ${note.title}');
                                print('Note: ${note.note}');
                                await ops.createDB();
                                await ops.insertNote(note);
                                print(await ops.noteslist());
                                Navigator.pop(context, true);
                              }
                            },
                            child: Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ])
            ],
          ),
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
