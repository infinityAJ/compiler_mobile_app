import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:cookbook/database.dart';
import 'package:share/share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online compiler',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
        fontFamily: 'Georgia',
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(primary: Colors.black38),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Cat(),
      routes: {
        '/cat': (context) => Cat(),
        '/file': (context) => File(),
        '/filelist': (context) => FileList(),
        '/compiler': (context) => Compiler(),
        '/output': (context) => Output(),
      },
    );
  }
}

class Cat extends StatefulWidget {
  _CatState createState() => _CatState();
}

class _CatState extends State<Cat> {
  int i = 0;
  List<String> lang = ["C", "C++", "Java", "Python"];
  List<String> images = [
    "images/C.png",
    "images/cpp.png",
    "images/java.png",
    "images/python.png"
  ];

  _pre() {
    setState(() {
      i = i <= 0 ? 3 : i - 1;
    });
  }

  _next() {
    setState(() {
      i = i >= 3 ? 0 : i + 1;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 170, bottom: 80),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  TextButton(
                    child: Text(
                      "<",
                      style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    onPressed: _pre,
                  ),
                  Expanded(
                    child: Image.asset(images[i]),
                  ),
                  TextButton(
                    child: Text(
                      ">",
                      style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    onPressed: _next,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 50,
                padding: EdgeInsets.all(80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black38),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(15)),
                          minimumSize: MaterialStateProperty.all(Size(100, 50)),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ))),
                      child: Text("New File",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                      onPressed: () {
                        print("new file");
                        Navigator.pushNamed(context, '/compiler',
                            arguments:
                                Entry(id: null, lang: lang[i], program: ""));
                      },
                    ),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black38),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(15)),
                            minimumSize:
                                MaterialStateProperty.all(Size(100, 50)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                        child: Text(
                          "Saved File",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/filelist',
                              arguments: lang[i]);
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileList extends StatelessWidget {
  final List<String> langs = ['C', 'C++', 'Java', 'Python'];

  Widget file(Entry pro, BuildContext context) {
    final last = pro.program.length >= 30
        ? pro.program.substring(0, 30) + "..."
        : pro.program;
    return InkWell(
      child: Container(
        height: 125,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pro.id.toString(),
              style: Theme.of(context).textTheme.headline6,
              textDirection: TextDirection.ltr,
            ),
            Text(last)
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, '/file', arguments: pro);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments;
    Future result() => DBprovider.db.langFiles(args);
    return Scaffold(
        appBar: AppBar(
          title: Text(args),
          backgroundColor: Colors.black45,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: FutureBuilder(
              future: result(),
              builder: (context, AsyncSnapshot result) {
                if (result.hasData) {
                  List<Entry> datas = result.data;
                  if (datas.isEmpty) {
                    return Center(
                        child: Text(
                      "Nothing here yet",
                      style: Theme.of(context).textTheme.bodyText2,
                    ));
                  }
                  return ListView.separated(
                      itemBuilder: (context, i) {
                        return file(datas[i], context);
                      },
                      separatorBuilder: (context, i) => Divider(),
                      itemCount: datas.length);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ));
  }
}

class Output extends StatefulWidget {
  _OutputState createState() => _OutputState();
}

class _OutputState extends State<Output> {
  final List lang = ["C", "C++", "Java", "Python"];
  final List langid = [50, 54, 62, 71];

  _getReq(String token) async {
    print(token);
    String getUrl = 'https://judge0.p.rapidapi.com/submissions/$token';
    Map<String, String> getheaders = {
      'x-rapidapi-key': 'a9ce3a6528msha46d7051a63941cp10573djsn01a18be119cc',
      'x-rapidapi-host': 'judge0.p.rapidapi.com'
    };
    Response getres = await get(getUrl, headers: getheaders);
    Map<String, dynamic> getbody = jsonDecode(getres.body);
    print(getbody);
    return getbody;
  }

  @override
  Widget build(BuildContext context) {
    String args = ModalRoute.of(context).settings.arguments;

    Widget _out(String key, String value) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(
            color: Colors.white54,
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Text(value,
                  style: TextStyle(fontSize: 15, color: Colors.white)),
            )
          ],
        ),
      );
    }

    Future result() => _getReq(args);
    return Scaffold(
      appBar: AppBar(
        title: Text("Output"),
        backgroundColor: Colors.black45,
      ),
      body: Container(
        padding: EdgeInsets.all(18),
        child: FutureBuilder(
            future: result(),
            builder: (context, AsyncSnapshot result) {
              if (result.hasData) {
                final res = result.data;
                List key = [
                  "stdout",
                  "stderr",
                  "memory",
                  "time",
                  "compile_output",
                  "message"
                ];
                List str = [
                  'Output',
                  'errors',
                  'memory',
                  'Execution time',
                  'compiler Output',
                  'Mesage'
                ];
                return ListView.separated(
                  separatorBuilder: (context, i) => Divider(),
                  itemCount: 6,
                  itemBuilder: (context, i) =>
                      _out(str[i], res[key[i]].toString()),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

class Compiler extends StatefulWidget {
  _CompilerState createState() => _CompilerState();
}

class _CompilerState extends State<Compiler> {
  int i;
  final ide = TextEditingController();
  final List<String> titles = [
    "C Compiler",
    "C++ Compiler",
    "Java Compiler",
    "Python IDE"
  ];
  final List<String> langs = ["C", "C++", "Java", "Python"];
  final List<int> id = [50, 54, 62, 71];

  @override
  Widget build(BuildContext context) {
    final Entry args = ModalRoute.of(context).settings.arguments;
    ide.text = args.program;
    this.i = langs.indexOf(args.lang);

    _postReq(String program) async {
      String postUrl = 'https://judge0.p.rapidapi.com/submissions';

      Map<String, String> postheaders = {
        'Content-type': 'application/json',
        'x-rapidapi-key': 'a9ce3a6528msha46d7051a63941cp10573djsn01a18be119cc',
        'x-rapidapi-host': 'judge0.p.rapidapi.com'
      };

      String payload = jsonEncode(<String, dynamic>{
        'language_id': id[i],
        'source_code': program,
      });

      Response postres =
          await post(postUrl, headers: postheaders, body: payload);
      Map<String, dynamic> postbody = jsonDecode(postres.body);
      return postbody['token'];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args.lang),
        backgroundColor: Colors.black45,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText2,
                maxLines: null,
                controller: ide,
                decoration: InputDecoration(
                  hintText: "start typing..",
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black45),
                  ),
                  onPressed: () async {
                    print("save clicked");
                    if (args.id != null) {
                      print("inside if");
                      await DBprovider.db.updateEntry(Entry(
                        id: args.id,
                        lang: args.lang,
                        program: ide.text,
                      ));
                    } else {
                      print("inside else");
                      await DBprovider.db.newEntry(
                          Entry(id: 1, lang: args.lang, program: ide.text));
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black45),
                  ),
                  child: Text(
                    "Run",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  onPressed: () async {
                    String token = await _postReq(ide.text);
                    Navigator.pushNamed(context, '/output', arguments: token);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class File extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Entry args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.id.toString()),
        backgroundColor: Colors.black54,
        actions: [
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () => Share.share(args.toMap().toString()))
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                  child: Text(args.program,
                      style: TextStyle(
                        fontSize: 20,
                      ))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.black54),
                    ),
                    onPressed: () async {
                      await DBprovider.db.deleteEntry(args.id);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    )),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.black54),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/compiler',
                        arguments: args,
                      );
                    },
                    child: Text(
                      "Edit",
                      style: TextStyle(color: Colors.white),
                    )),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.black54),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/output',
                        arguments: args,
                      );
                    },
                    child: Text(
                      "Run",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
