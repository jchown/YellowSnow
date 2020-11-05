import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'annotations.dart';
import 'annotate_git.dart';
import 'annotation_map.dart';
import 'history.dart';
import 'workspace.dart';
import 'annotations_file.dart';
import 'line.dart';
import 'timeline.dart';
import 'top_row.dart';
import 'color_schemes.dart';
import 'color_scheme.dart' as cs;

void main(List<String> arguments) {
  String path = Directory.current.absolute.toString();
  if (arguments.length > 0) path = arguments[1];

  path =
      "S:\\Work\\vTime\\vTag-Android\\Assets\\vTime\\Projects\\vTimeNow\\ConversationEvents.cs";
//  path = "S:\\Work\\vTime\\vTag-Android\\bin\\";

  if (path.endsWith(Workspace.dirChar))
    path = path.substring(0, path.length - 1);
  runApp(YellowSnowApp.ofPath(path));
}

class YellowSnowApp extends StatelessWidget {
  final String initialPath;

  YellowSnowApp() : initialPath = null;

  YellowSnowApp.ofPath(this.initialPath);

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(null, null);
    return EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('en', 'GB')],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        child: MaterialApp(
          title: 'Yellow Snow',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MainPage(filename: initialPath),
        ));
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.filename}) : super(key: key);

  final History _history = new History();
  final String filename;

  @override
  _MainPageState createState() => _MainPageState(filename, _history);
}

class _MainPageState extends State<MainPage> {
  History _history;
  String filename;
  Workspace workspace;
  Annotations annotations;
  cs.ColorScheme _colorScheme;

  static const String fontSizePrefsKey = "fontSize";
  static const double defaultFontSize = 12;
  double _fontSize;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final GlobalKey listKey = GlobalKey();
  final ScrollController linesViewController = ScrollController();

  ListView lines;
  AnnotationMap map;
  AnnotationZone zone;
  String annotatingSha;
  String annotatingNextSha;

  _MainPageState(this.filename, this._history) {
    annotations = Annotations.pending();
    workspace = null;
    _colorScheme = null;
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

  void _handleChangedFilename(String filename) {
    load(filename);
  }

  void _handleHistoryChangedFilename() {
    load(_history.getCurrent(), addToHistory: false);
  }

  Future<void> load(String filename, {bool addToHistory = true}) async {
    var history = _history;
    var fPrefs = SharedPreferences.getInstance();
    var newWorkspace = await Workspace.find(filename);
    this.filename = filename;
    if (addToHistory) {
      _history.push(filename);
    }
    stdout.writeln("Loading: $filename");

    setState(() {
      workspace = newWorkspace;
      annotations = Annotations.pending();
      _colorScheme = null;
      annotatingSha = null;
      annotatingNextSha = null;
      linesViewController.position.jumpTo(0);
      _history = history;
    });

    var newAnnotations =
        await AnnotateGit.getAnnotations(newWorkspace, filename);
    var prefs = await fPrefs;
    var newTheme = ColorSchemes.get(prefs);
    _fontSize = prefs.containsKey(fontSizePrefsKey)
        ? prefs.getDouble(fontSizePrefsKey)
        : defaultFontSize;

    setState(() {
      workspace = newWorkspace;
      annotations = newAnnotations;
      _colorScheme = newTheme;
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(color: Colors.white, fontSize: 20);
    var subtitleStyle = TextStyle(color: Colors.white, fontSize: 12);
    var currentFontSize = _fontSize ?? defaultFontSize;
    var drawerItems = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
              height: 140.0,
              child: DrawerHeader(
                child: Column(children: <Widget>[
//              Image()
                  Text('Yellow Snow', style: titleStyle),
                  Align(
                      child: Text(
                          '\nSee where your\nfellow developers\nleft their mark',
                          style: subtitleStyle,
                          textAlign: TextAlign.center))
                ]),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
              )),
          ListTile(
              leading: Icon(Icons.folder_open),
              title: Text('Open File'),
              onTap: onOpenFile),
          ExpansionTile(
            leading: Icon(Icons.color_lens),
            title: Text("t_ColorScheme").tr(),
            children: <Widget>[
              ListTile(
                title: Text('Yellow Snow'),
                leading: Image(
                    image: AssetImage("assets/images/YS.png"),
                    width: 20,
                    height: 20),
                onTap: () {
                  setColourScheme("YS");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Image(
                    image: AssetImage("assets/images/PS.png"),
                    width: 20,
                    height: 20),
                title: Text('Purple Stain'),
                onTap: () {
                  setColourScheme("PS");
                  Navigator.pop(context);
                },
              )
            ],
          ),
          ExpansionTile(
              leading: Icon(Icons.format_size),
              title: Text('Font Size ${currentFontSize}pt'),
              children: <Widget>[
                Slider(
                    value: currentFontSize,
                    min: 6,
                    max: 20,
                    onChanged: (double value) =>
                        setFontHeight((value * 10).floorToDouble() / 10))
              ]),
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
                    onTap: () => handleLineClick(line),
                    child:
                        line.getWidget(annotations, _colorScheme, _fontSize));
              }),
        ),
      ),
      SizedBox(
          width: 60,
          child: Listener(
              onPointerDown: (pd) => handleMapTap(pd.localPosition),
              onPointerMove: (pm) =>
                  {if (pm.buttons != 0) handleMapTap(pm.localPosition)},
              behavior: HitTestBehavior.opaque,
              child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(fit: StackFit.expand, children: <Widget>[
                    map = AnnotationMap(annotations, _colorScheme),
                    zone = AnnotationZone(annotations, _colorScheme)
                  ]))))
    ]);

    var topRow = TopRow(
        history: _history,
        workspace: workspace,
        filename: filename,
        onChangedFilename: _handleChangedFilename,
        onHistoryChangedFilename: _handleHistoryChangedFilename,
        onTappedMenu: _handleTappedMenu);

    var rows = List<Widget>();
    rows.add(topRow);
    rows.add(Expanded(child: mainView));

    if (annotations is AnnotationsFile) {
      var bottomRow = Container(
          color: Colors.blueGrey,
          child: Timeline(
              (annotations as AnnotationsFile).getRoot().getChanges(),
              onTimelineChanged));
      rows.add(bottomRow);
    }

    return Scaffold(
        key: scaffoldKey, drawer: drawerItems, body: Column(children: rows));
  }

  Future<void> setColourScheme(String schemeID) async {
    var oldWorkspace = workspace;
    var oldAnnotations = annotations;
    var newColorScheme =
        ColorSchemes.set(await SharedPreferences.getInstance(), schemeID);
    var history = _history;

    setState(() {
      workspace = oldWorkspace;
      annotations = oldAnnotations;
      _colorScheme = newColorScheme;
      _history = history;
    });
  }

  Future<void> setFontHeight(double fontSize) async {
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setDouble(fontSizePrefsKey, fontSize));

    setState(() {
      _fontSize = fontSize;
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
    if (annotatingSha != null) {
      //  Already doing something, we'll be next
      annotatingNextSha = sha;
      return;
    }

    try {
      annotatingSha = sha;
      var history = _history;

      var childAnnotations =
          await (annotations as AnnotationsFile).getChildAnnotations(sha);

      if (annotatingSha != sha) {
        throw Exception("Overtaken");
      }

      //  We're still the required sha

      setState(() {
        workspace = workspace;
        annotations = childAnnotations;
        _colorScheme = _colorScheme;
        annotatingSha = null;
        _history = history;
      });
    } catch (e) {
      //  Failed or overtkane

      annotatingSha = null;

      if (annotatingNextSha == null) {
        var nextSha = annotatingNextSha;
        annotatingNextSha = null;
        onTimelineChanged(nextSha);
      }

      return;
    }
  }
}
