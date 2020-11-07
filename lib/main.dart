import 'dart:io';

import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lotto/db.dart';
import 'package:flutter_lotto/home.dart';
import 'package:html/parser.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _message = '';

  @override
  void initState() {
    super.initState();
    loading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(),
              Text(
                '플러터 로또',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: Colors.white),
              ),
              Text(
                '$_message',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.white),
              ),
              Text(
                'Copyright flutter lotto.',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  loading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _message = '데이터를 가져오고 있습니다...';
    });
    final docDir = (await getApplicationDocumentsDirectory()).path;
    final savePath = '$docDir/lotto.html';
    File docFile = File(savePath);
    if (!await docFile.exists()) {
      await _downloadFile(savePath);
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => Home(),
    ));
  }

  _downloadFile(String savePath) async {
    try {
      var drwNoEnd =
          (DateTime.now().difference(DateTime(2002, 12, 7, 21, 30)).inMinutes /
                  10080)
              .ceil();
      final response = await Dio().download(
        'https://www.dhlottery.co.kr/gameResult.do?method=allWinExel&gubun=byWin&nowPage=&drwNoStart=1&drwNoEnd=$drwNoEnd',
        savePath,
        onReceiveProgress: (count, total) {
          print(count);
        },
      );
      if (response.statusCode == 200) {
        await _readFile(savePath);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  _readFile(String docPath) async {
    File docFile = File(docPath);
    var doc = await docFile.readAsBytes();
    var convert = await CharsetConverter.decode('EUC-KR', doc);
    var document = parse(convert);
    var tr = document
        .getElementsByTagName('table')[1]
        .getElementsByTagName('tbody')[0]
        .getElementsByTagName('tr');
    for (int i = 2; i < tr.length; i++) {
      var el = tr[i].getElementsByTagName('td')[0];
      if (el.attributes['rowspan'] != null) {
        var td = tr[i].getElementsByTagName('td');
        Map<String, dynamic> map = {
          'no': '${td[1].text}',
          'date': '${td[2].text}',
          'win':
              '${td[13].text},${td[14].text},${td[15].text},${td[16].text},${td[17].text},${td[18].text},${td[19].text}',
        };
        await DBHelper.db.insert(map);
      } else {
        var td = tr[i].getElementsByTagName('td');
        Map<String, dynamic> map = {
          'no': '${td[0].text}',
          'date': '${td[1].text}',
          'win':
              '${td[12].text},${td[13].text},${td[14].text},${td[15].text},${td[16].text},${td[17].text},${td[18].text}',
        };
        await DBHelper.db.insert(map);
      }
    }
  }
}
