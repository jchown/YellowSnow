import 'dart:io';

import 'package:YellowSnow/annotations_file.dart';
import 'package:YellowSnow/line.dart';
import 'package:YellowSnow/timeline.dart';
import 'package:YellowSnow/top_row.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'annotations.dart';
import 'annotate_git.dart';
import 'annotation_map.dart';
import 'workspace.dart';
import 'color_schemes.dart';
import 'color_scheme.dart' as cs;

void main(List<String> arguments) {
  String path = Directory.current.absolute.toString();
  if (arguments.length > 0) path = arguments[1];
  runApp(YellowSnowApp.ofPath("S:\\Work\\vTime\\vTag-Android\\bin\\prebuild.xml"));
}

class YellowSnowApp extends StatelessWidget {
  final String initialPath;

  YellowSnowApp() : initialPath = null;

  YellowSnowApp.ofPath(this.initialPath);

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
  cs.ColorScheme colorScheme;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final GlobalKey listKey = GlobalKey();
  final ScrollController linesViewController = ScrollController();

  ListView lines;
  AnnotationMap map;
  AnnotationZone zone;

  _MainPageState(this.filename) {
    annotations = Annotations.pending();
    workspace = null;
    colorScheme = null;
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

  void _handleFilenameChanged(String filename) {
    load(filename);
  }

  Future<void> load(String filename) async {
    var prefs = SharedPreferences.getInstance();
    var newWorkspace = await Workspace.find(filename);
    this.filename = filename;

    stdout.writeln("Workspace: ${newWorkspace.rootDir}");

    setState(() {
      workspace = newWorkspace;
      annotations = Annotations.pending();
      colorScheme = null;
    });

    var newAnnotations = await AnnotateGit.getAnnotations(newWorkspace, filename);
    var newTheme = ColorSchemes.get(await prefs);

    setState(() {
      workspace = newWorkspace;
      annotations = newAnnotations;
      colorScheme = newTheme;
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
                    onTap: () => handleLineClick(line), child: line.getWidget(annotations, colorScheme));
              }),
        ),
      ),
      SizedBox(
          width: 60,
          child: Listener(
              onPointerDown: (pd) => handleMapTap(pd.localPosition),
              onPointerMove: (pm) => {if (pm.buttons != 0) handleMapTap(pm.localPosition)},
              behavior: HitTestBehavior.opaque,
              child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(fit: StackFit.expand, children: <Widget>[
                    map = AnnotationMap(annotations, colorScheme),
                    zone = AnnotationZone(annotations, colorScheme)
                  ]))))
    ]);

    var topRow = TopRow(
        workspace: this.workspace,
        filename: this.filename,
        onChangedFilename: _handleFilenameChanged,
        onTappedMenu: _handleTappedMenu);

    var rows = List<Widget>();
    rows.add(topRow);
    rows.add(Expanded(child: mainView));

    if (annotations is AnnotationsFile) {
//      var bottomRow = SizedBox(height: 30, child: Timeline((annotations as AnnotationsFile).getRoot().changes, onTimelineChanged));
      var bottomRow = Container(color: Colors.blueGrey, child: Timeline((annotations as AnnotationsFile).getRoot().changes, onTimelineChanged));
      rows.add(bottomRow);
    }

    return Scaffold(key: scaffoldKey, drawer: drawerItems, body: Column(children: rows));
  }

  Future<void> setTheme(String themeID) async {
    var oldWorkspace = workspace;
    var oldAnnotations = annotations;
    var newColorScheme = ColorSchemes.set(await SharedPreferences.getInstance(), themeID);

    setState(() {
      workspace = oldWorkspace;
      annotations = oldAnnotations;
      colorScheme = newColorScheme;
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

  void handleLineClick(Line line) {
    if (line.getFilename() != null) load(line.getFilename());
  }

  handleMapTap(Offset position) {
    final box = listKey.currentContext.findRenderObject() as RenderBox;
    var height = box.size.height;
    var extent = linesViewController.position.maxScrollExtent;
    var pos = extent * position.dy / height;

    linesViewController.position.jumpTo(pos.clamp(0, extent.toInt()));
  }

  void _handleTappedMenu() {
    scaffoldKey.currentState.openDrawer();
  }

  void onTimelineChanged(String sha) async {
    var childAnnotations = await (annotations as AnnotationsFile).getChildAnnotations(sha);

    setState(() {
      workspace = workspace;
      annotations = childAnnotations;
      colorScheme = colorScheme;
    });

  }
}
