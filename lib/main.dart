import 'package:flutter/material.dart';

// import 'package:background_locator/background_locator.dart';

import 'package:location_permissions/location_permissions.dart'
    as locationPermission;
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Location Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _locationService = false;
  PermissionStatus _locationPermission;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      var _status = await Permission.location.status;
      setState(() {
        _locationPermission = _status;
      });
      if (await Permission.location.request().isGranted) {}
    }
  }

  void _init() async {
    //listen state gps service
    final Stream<locationPermission.ServiceStatus> statusStream =
        locationPermission.LocationPermissions().serviceStatus;

    statusStream.listen((locationPermission.ServiceStatus data) {
      setState(() {
        _locationService = data.index == 2 ? true : false;
      });

      if (data.index != 2) {
        //show local notification ongoing
        _showLocalNotificationOngoing(title: "Oh tidak!", body: "Aktifkan GPS Anda agar aplikasi dapat berfungsi secara normal", payload: "");
      }else{
        //destroy local notification ongoing id -1
        flutterLocalNotificationsPlugin.cancel(-1);

        //show other notification
        _showLocalNotification(title: "Mantaap", body: "GPS sekarang sudah aktif", payload: "");

      }
    });
    if (await Permission.location.request().isGranted) {}
  }

  //localnotification
  void _initLocalNotif() async {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {}

  _showLocalNotification(
      {String title = "", String body = "", payload = ""}) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'dev.andiksetyawan.location_base',
      'Notifikasi Umum',
      '',
      importance: Importance.Max,
      priority: Priority.High,
      icon: '@mipmap/ic_launcher', //launcher_icon
      //color: Theme.of(context).primaryColor
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: payload);
        
  }

  _showLocalNotificationOngoing(
      {String title = "", String body = "", payload = ""}) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'dev.andiksetyawan.location_base',
      'Notifikasi Ongoing',
      '',
      importance: Importance.Max,
      priority: Priority.High,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher', //launcher_icon
      //color: Theme.of(context).primaryColor
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .show(-1, title, body, platformChannelSpecifics, payload: payload);
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    _init();
    _initLocalNotif();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'gps service is:',
            ),
            Text(
              '$_locationService',
            ),
            Text(
              '$_locationPermission',
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}