import 'package:flutter/material.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'package:flutter_lotto/utils.dart';

class GenerateNumberWidget extends StatefulWidget {
  @override
  _GenerateNumberWidgetState createState() => _GenerateNumberWidgetState();
}

class _GenerateNumberWidgetState extends State<GenerateNumberWidget> {
  double _value = 1;
  List<int> _selectedNumbers = List.generate(45, (index) => index + 1);
  List<bool> _isSelected = List.generate(45, (_) => false);
  List<bool> _isExcepted = List.generate(45, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '생성할 개수',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: FluidSlider(
                      value: _value,
                      min: 1.0,
                      max: 30.0,
                      onChanged: (newValue) {
                        setState(() {
                          _value = newValue;
                        });
                      }),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Card(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '포함할 번호',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildDialog(
                            context: context,
                            title: '포함할 번호',
                            isSelected: _isSelected,
                            isDisabled: _isExcepted,
                            selectedNumbers: _selectedNumbers,
                          ),
                        ).then((value) => setState(() {
                              _isSelected = value;
                            }));
                      },
                    ),
                  ],
                ),
                Row(
                  children: List.generate(
                    _selectedNumbers.length,
                    (index) => _isSelected[index]
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: makeLottoBallColor(
                                      _selectedNumbers[index]),
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  _selectedNumbers[index].toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Card(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '제외할 번호',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildDialog(
                              context: context,
                              title: '제외할 번호',
                              selectedNumbers: _selectedNumbers,
                              isSelected: _isExcepted,
                              isDisabled: _isSelected),
                        ).then((value) => setState(() {
                              _isExcepted = value;
                            }));
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _selectedNumbers.length,
                        (index) => _isExcepted[index]
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: makeLottoBallColor(
                                          _selectedNumbers[index]),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      _selectedNumbers[index].toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(),
        ),
        Container(
          padding: EdgeInsets.all(12),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.1,
          child: FlatButton(
            color: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.deepPurple),
            ),
            child: Text(
              '번호 생성',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
              List<List<int>> results = _generateRandomNumbers(
                  _isSelected, _isExcepted, _value.toInt());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultWidget(
                      results: results,
                    ),
                  ));
            },
          ),
        ),
      ],
    );
  }

  _buildDialog({
    BuildContext context,
    String title,
    List<bool> isSelected,
    List<bool> isDisabled,
    List<int> selectedNumbers,
  }) {
    List<bool> tmp = List();
    tmp.addAll(isSelected);
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: selectedNumbers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7),
                  itemBuilder: (context, index) {
                    return isDisabled[index]
                        ? Container(
                            child: Center(
                              child: Text('${selectedNumbers[index]}'),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected[index] = !isSelected[index];
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: isSelected[index]
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    '${selectedNumbers[index]}',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: FlatButton(
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: Colors.deepPurple,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, tmp);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: FlatButton(
                          color: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.deepPurple),
                          ),
                          child: Text(
                            '적용',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, isSelected);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _generateRandomNumbers(
      List<bool> isSelected, List<bool> isExcepted, int howMany) {
    List<int> includedNumbers = List();
    List<int> exceptNumbers = List();

    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        includedNumbers.add(i + 1);
      } else if (isExcepted[i]) {
        exceptNumbers.add(i + 1);
      }
    }

    List<List<int>> resultNumbers = List();
    for (int i = 0; i < howMany; i++) {
      List<int> randomNumbers = List.generate(45, (index) => index + 1);
      randomNumbers.shuffle();

      for (int j = 0; j < includedNumbers.length; j++) {
        randomNumbers.remove(includedNumbers[j]);
      }

      for (int k = 0; k < exceptNumbers.length; k++) {
        randomNumbers.remove(exceptNumbers[k]);
      }

      List<int> generatedNumbers = List();
      for (int n = 0; n < 6 - includedNumbers.length; n++) {
        generatedNumbers.add(randomNumbers[n]);
      }
      generatedNumbers.addAll(includedNumbers);
      generatedNumbers.sort();
      resultNumbers.add(generatedNumbers);
    }
    return resultNumbers;
  }
}

class ResultWidget extends StatelessWidget {
  final List<List<int>> results;
  ResultWidget({Key key, this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('생성 결과'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: results.length,
        itemBuilder: (context, index) {
          List<int> item = results[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  item.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          color: makeLottoBallColor(item[index]),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          item[index].toString(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
