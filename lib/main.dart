import 'dart:io';

import 'package:YellowSnow/annotate_git.dart';
import 'package:YellowSnow/workspace.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'annotations.dart';
import 'themes.dart';
import 'theme.dart' as Theme;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yellow Snow',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
          filename: 'S:\\Work\\Dominators\\src\\main\\kotlin\\League.kt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.filename}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String filename;

  @override
  _MyHomePageState createState() => _MyHomePageState(filename);
}

class _MyHomePageState extends State<MyHomePage> {
  Workspace workspace;
  Annotations annotations;
  Theme.Theme theme;

  final ScrollController linesViewController = ScrollController();

  _MyHomePageState(String filename) {
    workspace = Workspace.pending();
    annotations = Annotations.pending();
    theme = null;
    load(filename);
  }

  Future<void> load(String filename) async {
    var prefs = SharedPreferences.getInstance();
    var newWorkspace = await Workspace.find(filename);
    stdout.writeln("Workspace: ${newWorkspace.rootDir}");
    var newAnnotations =
        await AnnotateGit.getAnnotations(newWorkspace, filename);
    var newTheme = Themes.get(await prefs);

    setState(() {
      workspace = newWorkspace;
      annotations = newAnnotations;
      theme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    var drawerItems = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          ExpansionTile(
            title: Text("Theme"),
            children: <Widget>[
              ListTile(
                title: Text('Yellow Snow'),
                onTap: () {
                  setTheme("YS");
                },
              ),
              ListTile(
                title: Text('Purple Stain'),
                onTap: () {
                  setTheme("PS");
                },
              )
            ],
          ),
          ListTile(
            title: Text('Font Size'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.filename),
      ),
      drawer: drawerItems,
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: DraggableScrollbar.rrect(
          alwaysVisibleScrollThumb: true,
          controller: linesViewController,
          child: ListView.builder(
              itemCount: annotations.lines.length,
              controller: linesViewController,
              itemBuilder: (context, i) {
                return annotations.lines[i].getWidget(annotations, theme);
              }),
        ),
      ),
    );
  }

  Future<void> setTheme(String themeID) async {
    var oldWorkspace = workspace;
    var oldAnnotations = annotations;
    var newTheme = Themes.set(await SharedPreferences.getInstance(), themeID);

    setState(() {
      workspace = oldWorkspace;
      annotations = oldAnnotations;
      theme = newTheme;
    });
  }
}
