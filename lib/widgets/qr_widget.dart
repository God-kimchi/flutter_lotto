import 'package:flutter/material.dart';
import 'package:flutter_lotto/db.dart';
import 'package:flutter_lotto/utils.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';

class QRWidget extends StatefulWidget {
  @override
  _QRWidgetState createState() => _QRWidgetState();
}

class _QRWidgetState extends State<QRWidget> {
  bool _isScanning = false;
  List<Widget> _widgets = List();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: QRBarScannerCamera(
              onError: (context, error) => Text(
                error.toString(),
                style: TextStyle(color: Colors.red),
              ),
              qrCodeCallback: (code) async {
                await _qrCallback(code);
              },
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            ),
            child: _isScanning
                ? Container(
                    padding: EdgeInsets.all(12),
                    child: Card(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _widgets),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 128,
                      ),
                      SizedBox(height: 12),
                      Text(
                        '로또 QR 스캔을 하십시오 휴먼',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLottoNumbers(
      List<int> qr, int index, String result, List<bool> colors) {
    List<Widget> widgets = List();
    List<String> rows = ['A', 'B', 'C', 'D', 'E'];

    widgets.add(Container(
      width: 32,
      height: 32,
      child: Center(child: Text(rows[index])),
    ));
    for (int i = 0; i < qr.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: 32,
          height: 32,
          decoration: colors[qr[i]]
              ? BoxDecoration(
                  color: makeLottoBallColor(qr[i]), shape: BoxShape.circle)
              : null,
          child: Center(
            child: Text(
              qr[i].toString(),
              style: colors[qr[i]]
                  ? TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
        ),
      ));
    }
    widgets.add(Container(
      width: 32,
      height: 32,
      child: Center(
        child: Text(result),
      ),
    ));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: widgets);
  }

  _qrCallback(String code) async {
    try {
      if (code.contains('v=')) {
        var baseStr = code.split('v=')[1];
        var strArr = baseStr.split(baseStr[4]);
        var drwNo = int.parse(strArr[0]).toString();
        var scanTrNumber = int.parse(strArr[strArr.length - 1].substring(12));

        List<Map<String, dynamic>> result = await DBHelper.db.find(drwNo);

        if (result.isNotEmpty) {
          List<Widget> widgets = List();
          widgets.add(Container(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text(
                '로또 6/45 ${drwNo}회',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ));
          var win = result[0]['win'].split(',');
          List<bool> wins = List.generate(46, (_) => false);
          int bonus = int.parse(win[6]);
          for (int i = 0; i < win.length - 1; i++) {
            wins[int.parse(win[i])] = true;
          }

          List<List<int>> qr = List();
          for (int i = 1; i < strArr.length; i++) {
            List<int> num = List();
            for (int j = 0; j < 6; j++) {
              num.add(int.parse(strArr[i].substring(j * 2, j * 2 + 2)));
            }
            qr.add(num);
          }

          for (int i = 0; i < qr.length; i++) {
            int winningCount = 0;
            int bonusCount = 0;
            for (int j = 0; j < qr[i].length; j++) {
              if (wins[qr[i][j]]) {
                winningCount++;
              }
            }
            for (int k = 0; k < qr[i].length; k++) {
              if (bonus == qr[i][k]) {
                bonusCount++;
              }
            }

            switch (winningCount) {
              case 0:
              case 1:
              case 2:
                {
                  widgets.add(_buildLottoNumbers(qr[i], i, '낙첨', wins));
                  break;
                }
              case 3:
                {
                  widgets.add(_buildLottoNumbers(qr[i], i, '5등', wins));
                  break;
                }
              case 4:
                {
                  widgets.add(_buildLottoNumbers(qr[i], i, '4등', wins));
                  break;
                }
              case 5:
                {
                  if (bonusCount > 0) {
                    widgets.add(_buildLottoNumbers(qr[i], i, '2등', wins));
                  } else {
                    widgets.add(_buildLottoNumbers(qr[i], i, '3등', wins));
                  }
                  break;
                }
              case 6:
                {
                  widgets.add(_buildLottoNumbers(qr[i], i, '1등', wins));
                  break;
                }
              default:
                break;
            }
          }
          setState(() {
            _isScanning = true;
            _widgets = widgets;
          });
        }
      } else {
        setState(() {
          _isScanning = false;
          _widgets = [];
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
