import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:yaml/yaml.dart';
import 'package:yellow_snow/render_style.dart';
import 'package:win32/win32.dart';

import 'annotations.dart';
import 'annotate_git.dart';
import 'annotation_map.dart';
import 'history.dart';
import 'workspace.dart';
import 'annotations_file.dart';
import 'line.dart';
import 'timeline.dart';
import 'top_row.dart';

typedef GCL_Native = IntPtr Function();
typedef GCL_Dart = int Function();

typedef CL2A_Native = IntPtr Function(IntPtr cmdLine, IntPtr numArgs);
typedef CL2A_Dart = int Function(int cmdLine, int numArgs);

void main(List<String> arguments) async {
  if (Platform.isWindows) {
    // TODO: Remove when arguments are passed correctly

    developer.log("Args: " + arguments.join(","), name: 'yellowsnow.init');

    arguments = getArgsWin32();
  }

  developer.log("Args: " + arguments.join(","), name: 'yellowsnow.init');

  final path = arguments.length > 1 ? arguments[1] : Directory.current.absolute.path + Workspace.dirChar;

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  initializeDateFormatting(null, null);
  var renderStyle = await RenderStyle.load();

  runApp(EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('en', 'GB')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: YellowSnowApp(renderStyle: renderStyle, initialPath: path)));
}

/// Read command line arguments using Win32 API.

List<String> getArgsWin32() {
  final _kernel32 = DynamicLibrary.open('kernel32.dll');
  final _shell32 = DynamicLibrary.open('shell32.dll');

  final getCommandLineW = _kernel32.lookupFunction<GCL_Native, GCL_Dart>('GetCommandLineW');
  var cmdLine = Pointer<Uint16>.fromAddress(getCommandLineW());

  final numArgs = calloc<Uint32>(1);
  final commandLineToArgvW = _shell32.lookupFunction<CL2A_Native, CL2A_Dart>('CommandLineToArgvW');
  var argV = Pointer<Pointer<Uint16>>.fromAddress(commandLineToArgvW(cmdLine.address, numArgs.address));

  developer.log("Win32 num args: " + numArgs.value.toString(), name: 'yellowsnow.init');

  List<String> args = [];
  for (int i = 0; i < numArgs.value; i++) {
    var lpwstr = argV.elementAt(i).value;
    args.add(fromLPWSTR(lpwstr));
  }

  free(numArgs);
  free(argV);
  return args;
}

/// Read a null terminated wide string into Dart.

String fromLPWSTR(Pointer<Uint16> lpwstr) {
  String s = "";
  int c;
  int i = 0;
  while ((c = lpwstr.elementAt(i++).value) != 0) {
    s += String.fromCharCode(c);
  }
  return s;
}

class YellowSnowApp extends StatelessWidget {
  final String initialPath;
  final RenderStyle renderStyle;

  YellowSnowApp({required this.renderStyle, required this.initialPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yellow Snow',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(filename: initialPath, renderStyle: renderStyle),
    );
  }
}

class FileOpenIntent extends Intent {
  const FileOpenIntent();
}

class MainPage extends StatefulWidget {
  MainPage({Key? key, required this.filename, required this.renderStyle}) : super(key: key);

  final History _history = new History();
  final String filename;
  final RenderStyle renderStyle;

  @override
  _MainPageState createState() => _MainPageState(filename, _history, renderStyle);
}

class _MainPageState extends State<MainPage> {
  History _history;
  String filename;
  Workspace? workspace;
  Annotations? annotations;

  RenderStyle renderStyle;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final GlobalKey listKey = GlobalKey();
  final ScrollController linesViewController = ScrollController();
  var _shortcutManager = ShortcutManager();

  ListView? lines;
  AnnotationMap? map;
  late AnnotationZone zone;
  String? annotatingSha;
  String? annotatingNextSha;

  _MainPageState(this.filename, this._history, this.renderStyle) {
    annotations = Annotations.pending();
    workspace = null;
    linesViewController.addListener(onScrollChanged);
    load(filename);
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => onLayout());
  }

  void onLayout() {
    updateZone();
    WidgetsBinding.instance!.addPostFrameCallback((_) => onLayout());
  }

  void _handleChangedFilename(String filename) {
    load(filename);
  }

  void _handleHistoryChangedFilename() {
    load(_history.getCurrent(), addToHistory: false);
  }

  Future<void> load(String filename, {bool addToHistory = true}) async {
    var history = _history;
    var newWorkspace = await Workspace.find(filename);
    if (newWorkspace == null) throw new Exception();

    this.filename = filename;
    if (addToHistory) {
      _history.push(filename);
    }
    stdout.writeln("Loading: $filename");

    setState(() {
      workspace = newWorkspace;
      annotations = Annotations.pending();
      annotatingSha = null;
      annotatingNextSha = null;
      linesViewController.position.jumpTo(0);
      _history = history;
    });

    var newAnnotations = await AnnotateGit.getAnnotations(newWorkspace, filename);

    setState(() {
      workspace = newWorkspace;
      annotations = newAnnotations;
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(color: Colors.white, fontSize: 20);
    var subtitleStyle = TextStyle(color: Colors.white, fontSize: 12);
    var currentFontSize = renderStyle.fontSize;
    var drawerItems = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
              height: 100.0,
              child: DrawerHeader(
                child: Column(children: <Widget>[
                  Text('Yellow Snow', style: titleStyle),
                  Align(
                      child: Text('\nSee where your fellow developers left their mark',
                          style: subtitleStyle, textAlign: TextAlign.center))
                ]),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
              )),
          ListTile(leading: Icon(Icons.folder_open), title: Text('Open File'), onTap: onOpenFile),
          ExpansionTile(
            leading: Icon(Icons.color_lens),
            title: Text("t_ColorScheme").tr(),
            children: <Widget>[
              ListTile(
                title: Text('Yellow Snow'),
                leading: Image(image: AssetImage("assets/images/YS.png"), width: 20, height: 20),
                onTap: () {
                  setColourScheme("YS");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Image(image: AssetImage("assets/images/PS.png"), width: 20, height: 20),
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
                    onChanged: (double value) => setFontHeight((value * 10).floorToDouble() / 10))
              ]),
          ListTile(leading: Icon(Icons.info), title: Text('About YellowSnow'), onTap: onAbout),
        ],
      ),
    );

    var mainView = Container(
        color: renderStyle.colorScheme.getBGColor(0),
        child: Row(children: <Widget>[
          Expanded(
            child: DraggableScrollbar.semicircle(
              alwaysVisibleScrollThumb: true,
              controller: linesViewController,
              child: lines = ListView.builder(
                  key: listKey,
                  itemCount: annotations!.lines.length,
                  controller: linesViewController,
                  itemBuilder: (context, i) {
                    var line = annotations!.lines[i];
                    return GestureDetector(
                        onTap: () => handleLineClick(line), child: line.getWidget(annotations!, renderStyle));
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
                        map = AnnotationMap(annotations!, renderStyle.colorScheme),
                        zone = AnnotationZone(annotations!, renderStyle.colorScheme)
                      ]))))
        ]));

    var topRow = TopRow(
        history: _history,
        workspace: workspace,
        filename: filename,
        onChangedFilename: _handleChangedFilename,
        onHistoryChangedFilename: _handleHistoryChangedFilename,
        onTappedMenu: _handleTappedMenu);

    var rows = List<Widget>.empty(growable: true);
    rows.add(topRow);
    rows.add(Expanded(child: mainView));

    if (annotations is AnnotationsFile) {
      var bottomRow = Container(
          color: Colors.blueGrey,
          child: Timeline((annotations as AnnotationsFile).getRoot().getChanges(), onTimelineChanged));
      rows.add(bottomRow);
    }

    return Scaffold(
        key: scaffoldKey,
        drawer: drawerItems,
        body: Shortcuts(
            manager: _shortcutManager,
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO): FileOpenIntent()
            },
            child: Actions(actions: <Type, Action<Intent>>{
              FileOpenIntent: CallbackAction<FileOpenIntent>(onInvoke: (FileOpenIntent intent) => onOpenFile()),
            }, child: Focus(autofocus: true, child: Column(children: rows)))));
  }

  Future<void> setColourScheme(String schemeID) async {
    setState(() {
      renderStyle = renderStyle.withColorSchemeID(schemeID);
    });
  }

  Future<void> setFontHeight(double fontSize) async {
    var rs = await renderStyle.setFontHeight(fontSize);

    setState(() {
      renderStyle = rs;
    });
  }

  void onScrollChanged() {
    updateZone();
  }

  void updateZone() {
    final box = listKey.currentContext!.findRenderObject() as RenderBox;
    var height = box.size.height;
    var extent = linesViewController.position.maxScrollExtent;
    var offset = linesViewController.offset;
    zone.update(extent + height, offset, height);
  }

  Future<void> onHome() async {}

  Future<void> onOpenFile() async {
    var picker = OpenFilePicker()..title = "Choose File";
//      ..folder = filename != null ? filename.substring(0, filename.lastIndexOf(Workspace.dirChar)) : null;

    var file = picker.getFile();
    if (file != null && file.existsSync()) load(file.path);
  }

  Future<void> onAbout() async {
    var pubspec = await rootBundle.loadString("pubspec.yaml");
    var yaml = loadYaml(pubspec);
    var version = yaml["version"];

    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      title: 'About YellowSnow',
      desc: '\nAuthor: Jason Chown\n\nVersion: $version\n',
      btnOkOnPress: () {},
    )..show();
  }

  void handleLineClick(Line line) {
    load(line.getFilename());
  }

  handleMapTap(Offset position) {
    final box = listKey.currentContext!.findRenderObject() as RenderBox;
    var height = box.size.height;
    var extent = linesViewController.position.maxScrollExtent;
    var pos = extent * position.dy / height;

    linesViewController.position.jumpTo(pos.clamp(0.0, extent.floorToDouble()));
  }

  void _handleTappedMenu() {
    scaffoldKey.currentState!.openDrawer();
  }

  void onTimelineChanged(String? sha) async {
    if (annotatingSha != null) {
      //  Already doing something, we'll be next
      annotatingNextSha = sha;
      return;
    }

    try {
      annotatingSha = sha;

      var childAnnotations = await (annotations as AnnotationsFile).getChildAnnotations(sha);

      if (annotatingSha != sha) {
        throw Exception("Overtaken");
      }

      //  We're still the required sha

      setState(() {
        annotations = childAnnotations;
        annotatingSha = null;
      });
    } catch (e) {
      //  Failed or overtaken

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
