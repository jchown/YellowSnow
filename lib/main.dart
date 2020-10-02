import 'dart:io';

import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'annotations.dart';
import 'annotate_git.dart';
import 'annotation_map.dart';
import 'workspace.dart';
import 'themes.dart';
import 'theme.dart' as Theme;

void main() {
  runApp(YellowSnowApp());
}

class YellowSnowApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yellow Snow',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(
//          filename: 'S:\\Work\\vTime\\mvr.api\\src\\main\\java\\starship\\mvr\\model\\db\\FriendsDB.java'),
          filename: "S:\\Work\\vTime\\vTag-Android\\bin\\prebuild.xml"),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.filename}) : super(key: key);

  final String filename;

  @override
  _MainPageState createState() => _MainPageState(filename);
}

class _MainPageState extends State<MainPage> {
  Workspace workspace;
  Annotations annotations;
  Theme.Theme theme;

  final ScrollController linesViewController = ScrollController();

  _MainPageState(String filename) {
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Purple Stain'),
                onTap: () {
                  setTheme("PS");
                  Navigator.pop(context);
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
      body: Row(children: <Widget>[
        Expanded(
          child: DraggableScrollbar.semicircle(
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
        SizedBox(
            width: 80,
            child: Container(
                height: double.infinity,
                width: double.infinity,
                child: AnnotationMap(annotations, theme)))
      ]),
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
