import 'package:dio/dio.dart';
import 'package:example_webview/techsauce_webview.dart';
import 'package:flutter/material.dart';

import 'example_webview.dart';
import 'techsauce_webview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Example"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url = "";

  void getData() async {
    final dio = Dio();
    final response = await dio.get(
        'https://storage.googleapis.com/techsauce-webview-conf/webview-config.json');
    setState(() {
      // _url =  response.data['base_url'];
      // _url =  "https://zipeventapp.com/";
      // _url = "https://ts.fivenet.sixprotocol.com/";
      _url = "https://tswv.sixprotocol.com/";
      // _url =  "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=eVRVM051V3NKcUh2Y21WcG92OWY6MTpjaQ&redirect_uri=https://ts.fivenet.sixprotocol.com/register&scope=tweet.read%20users.read%20follows.read%20follows.write&state=state&code_challenge=challenge&code_challenge_method=plain";
      // _url =  "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=eVRVM051V3NKcUh2Y21WcG92OWY6MTpjaQ&scope=follows.read%20tweet.read%20users.read%20offline.access&redirect_uri=https://ts.fivenet.sixprotocol.com/register&code_challenge=challenge&code_challenge_method=plain&state=states";
      // _url =  "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=eVRVM051V3NKcUh2Y21WcG92OWY6MTpjaQ&scope=follows.read%20tweet.read%20users.read%20offline.access&redirect_uri=https://194d-110-49-44-82.ngrok-free.app/register&code_challenge=challenge&code_challenge_method=plain&state=states";
      // _url =  "https://accounts.google.com/o/oauth2/v2/auth?access_type=offline&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&response_type=code&client_id=593361572149-69eg9gffia1bo62ccbm37igkq2jh9tjj.apps.googleusercontent.com&redirect_uri=https%3A%2F%2F7c4a-124-122-175-110.ngrok-free.app%2Fregister";
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    // getData();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                child: const Text('Refresh'),
                onPressed: () {
                  getData();
                  // Navigate to second route when tapped.
                }),
            SizedBox(height: 30),
            const Text(
              'Endpoint',
            ),
            Text(
              '$_url',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            ElevatedButton(
                child: const Text('Open Webview'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TechSauceWebView(
                              url: _url,
                            )),
                  );
                  // Navigate to second route when tapped.
                }),
          ],
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
