import 'package:flutter/material.dart';
import 'package:flutter_lotto/widgets/generate_number_widget.dart';
import 'package:flutter_lotto/widgets/qr_widget.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> _title = ['당첨 확인', '번호 생성'];
    List<Widget> _widgetOptions = [
      QRWidget(),
      GenerateNumberWidget(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title[_selectedIndex]),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '당첨확인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '번호생성',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
