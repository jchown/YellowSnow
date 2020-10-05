import 'dart:io';

import 'package:YellowSnow/line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'annotations.dart';
import 'annotate_git.dart';
import 'annotation_map.dart';
import 'workspace.dart';
import 'themes.dart';
import 'theme.dart' as Theme;

void main(List<String> arguments) {
  String path = Directory.current.absolute.toString();
  if (arguments.length > 0) path = arguments[1];
  runApp(YellowSnowApp("S:\\Work\\vTime\\vTag-Android\\bin")); //\\prebuild.xml"));
}

class YellowSnowApp extends StatelessWidget {
  final String initialPath;

  YellowSnowApp(this.initialPath);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yellow Snow',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(filename: initialPath),
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
  String filename;
  Workspace workspace;
  Annotations annotations;
  Theme.Theme theme;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final GlobalKey listKey = GlobalKey();
  final ScrollController linesViewController = ScrollController();

  ListView lines;
  AnnotationMap map;
  AnnotationZone zone;

  _MainPageState(this.filename) {
    annotations = Annotations.pending();
    workspace = null;
    theme = null;
    linesViewController.addListener(onScrollChanged);
    load(filename);
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLayout());
  }

  void onLayout() {
    updateZone();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLayout());
  }

  Future<void> load(String filename) async {
    var prefs = SharedPreferences.getInstance();
    var newWorkspace = await Workspace.find(filename);
    stdout.writeln("Workspace: ${newWorkspace.rootDir}");
    var newAnnotations = await AnnotateGit.getAnnotations(newWorkspace, filename);
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
          ListTile(title: Text('Open File'), onTap: onOpenFile),
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

    List<Widget> topRowWidgets = [
      IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () => scaffoldKey.currentState.openDrawer(),
      ),
      IconButton(
        icon: Icon(
          Icons.home,
          color: Colors.white,
        ),
        onPressed: () {
          // do something
        },
      ),
      IconButton(
        icon: Icon(
          Icons.settings,
          color: Colors.white,
        ),
        onPressed: () {
          // do something
        },
      ),
    ];

    if (workspace != null) {
      topRowWidgets.add(ElevatedButton(child: Text(workspace.rootDir), onPressed: () => load(workspace.rootDir)));
      var segments = workspace.getRelativePath(filename).split(Workspace.dirChar);
      for (int i = 0; i < segments.length; i++) {
        bool last = i == (segments.length - 1);
        var path = workspace.getAbsolutePath(segments.getRange(0, i + 1).join(Workspace.dirChar));
        String segment = segments[i];
        if (!last) segment += Workspace.dirChar;
        topRowWidgets.add(ElevatedButton(child: Text(segment), onPressed: () => load(path)));
      }
    }

    var topRow = Row(
        children: <Widget>[Expanded(child: Container(color: Colors.blueGrey, child: Row(children: topRowWidgets)))]);

    var mainView = Row(children: <Widget>[
      Expanded(
        child: DraggableScrollbar.semicircle(
          alwaysVisibleScrollThumb: true,
          controller: linesViewController,
          child: lines = ListView.builder(
              key: listKey,
              itemCount: annotations.lines.length,
              controller: linesViewController,
              itemBuilder: (context, i) {
                var line = annotations.lines[i];
                return GestureDetector(
                    onTap: () => onLineClick(line),
                    child: line.getWidget(annotations, theme));
              }),
        ),
      ),
      SizedBox(
          width: 60,
          child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: <Widget>[
                map = AnnotationMap(annotations, theme),
                zone = AnnotationZone(annotations, theme)
              ])))
    ]);

    return Scaffold(
        key: scaffoldKey, drawer: drawerItems, body: Column(children: <Widget>[topRow, Expanded(child: mainView)]));
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

  void onScrollChanged() {
    updateZone();
  }

  void updateZone() {
    final box = listKey.currentContext.findRenderObject() as RenderBox;
    var height = box.size.height;
    var extent = linesViewController.position.maxScrollExtent;
    var offset = linesViewController.offset;
    zone.update(extent + height, offset, height);
  }

  Future<void> onHome() async {}

  Future<void> onOpenFile() async {
    var result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result.count == 1) load(result.files[0].toString());
  }

  void onLineClick(Line line) {
    if (line.getFilename() != null)
      load(line.getFilename());
  }
}
