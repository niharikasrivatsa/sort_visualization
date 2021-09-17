import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sort Visualization',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> _numbers = [];
  late StreamController<List<int>> _streamController = StreamController();
  String _currentSortAlgo = 'bubble';
  double _sampleSize = 320;
  bool isSorted = false;
  bool isSorting = false;
  int speed = 0;
  static int duration = 1500;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Duration _getDuration() {
    return Duration(microseconds: duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sampleSize = MediaQuery.of(context).size.width / 2;
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(500));
    }
    setState(() {});
  }


  _bubbleSort() async{
    for (int i = 0; i < _numbers.length; ++i){
      for (int j = 0; j < _numbers.length - i - 1; ++j){
        if(_numbers[j] > _numbers[j+1]){
          int temp = _numbers[j];
          _numbers[j] = _numbers[j + 1];
          _numbers[j +1] = temp;
        }
        await Future.delayed(Duration(microseconds: 500));
 //       setState(() {});
        _streamController.add(_numbers);

      }
    }
  }

  _recursiveBubbleSort(int n) async {
    if (n == 1) {
      return;
    }
    for (int i = 0; i < n - 1; i++) {
      if (_numbers[i] > _numbers[i + 1]) {
        int temp = _numbers[i];
        _numbers[i] = _numbers[i + 1];
        _numbers[i + 1] = temp;
      }
      await Future.delayed(_getDuration());
      _streamController.add(_numbers);
    }
    await _recursiveBubbleSort(n - 1);
  }

  _selectionSort() async {
    for (int i = 0; i < _numbers.length; i++) {
      for (int j = i + 1; j < _numbers.length; j++) {
        if (_numbers[i] > _numbers[j]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[i];
          _numbers[i] = temp;
        }

        await Future.delayed(_getDuration(), () {});

        _streamController.add(_numbers);
      }
    }
  }

  _insertionSort() async {
    for (int i = 1; i < _numbers.length; i++) {
      int temp = _numbers[i];
      int j = i - 1;
      while (j >= 0 && temp < _numbers[j]) {
        _numbers[j + 1] = _numbers[j];
        --j;
        await Future.delayed(_getDuration(), () {});

        _streamController.add(_numbers);
      }
      _numbers[j + 1] = temp;
      await Future.delayed(_getDuration(), () {});

      _streamController.add(_numbers);
    }
  }

  cf(int a, int b) {
    if (a < b) {
      return -1;
    } else if (a > b) {
      return 1;
    } else {
      return 0;
    }
  }

  _reset() {
    isSorted = false;
    _numbers = [];
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(500));
    }
    _streamController.add(_numbers);
  }

  _setSortAlgo(String type) {
    setState(() {
      _currentSortAlgo = type;
    });
  }

  _checkAndResetIfSorted() async {
    if (isSorted) {
      _reset();
      await Future.delayed(Duration(milliseconds: 200));
    }
  }


  _changeSpeed() {
    if (speed >= 3) {
      speed = 0;
      duration = 1500;
    } else {
      speed++;
      duration = duration ~/ 2;
    }

    print(speed.toString() + " " + duration.toString());
    setState(() {});
  }

  _sort() async {
    setState(() {
      isSorting = true;
    });

    await _checkAndResetIfSorted();

    Stopwatch stopwatch = new Stopwatch()..start();

    switch (_currentSortAlgo) {
      case "bubble":
        await _bubbleSort();
        break;
      case "recursivebubble":
        await _recursiveBubbleSort(_sampleSize.toInt() - 1);
        break;
      case "selection":
        await _selectionSort();
        break;
      case "insertion":
        await _insertionSort();
        break;
    }

    stopwatch.stop();

    _scaffoldKey.currentState!.removeCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(
          "Sorting completed in ${stopwatch.elapsed.inMilliseconds} ms.",
        ),
      ),
    );
    setState(() {
      isSorting = false;
      isSorted = true;
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sorting Algorithms: A Visulization"),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<String>(
          initialValue: _currentSortAlgo,
          itemBuilder: (ctx) {
            return [
              PopupMenuItem(
                value: 'bubble',
                child: Text("Bubble Sort"),
              ),
              PopupMenuItem(
                value: 'recursivebubble',
                child: Text("Recursive Bubble Sort"),
              ),
              PopupMenuItem(
                value: 'selection',
                child: Text("Selection Sort"),
              ),
              PopupMenuItem(
                value: 'insertion',
                child: Text("Insertion Sort"),
              ),
          ];
        },
        onSelected: (String value) {
            _reset();
            _setSortAlgo(value);
         },
        ),
      ],
      ),

      body: SafeArea(
      child:Container(
        padding: const EdgeInsets.only(top: 0.0),
        child:StreamBuilder<Object>(
          initialData: _numbers,
          stream: _streamController.stream,
          builder: (context, snapshot){
            Object? numbers = snapshot.data;
            int counter = 0;

              return Row(
                children: _numbers.map((int num) {
                counter++;
                return Container(
                    child: CustomPaint(
                      painter: BarPainter(
                          index: counter,
                          value: num,
                          width: MediaQuery.of(context).size.width / _sampleSize),
                  ),
                );
              }).toList(),
            );
          }),
      ),
        ),

          bottomNavigationBar: BottomAppBar(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      onPressed: isSorting
                          ? null
                          : () {
                            _reset();
                            _setSortAlgo(_currentSortAlgo);
                          },
                      child: Text("RESET"))),
                  Expanded(child: TextButton(onPressed: isSorting ? null : _sort, child: Text("SORT"))),
                  Expanded(
                    child: TextButton(
                      onPressed: isSorting ? null : _changeSpeed,
                      child: Text(
                      "${speed + 1}x",
                    style: TextStyle(fontSize: 20),
                  ))),
         ],
        ),
      ),
    );
  }
}



class BarPainter extends CustomPainter{
  final double width;
  final int value;
  final int index;

  BarPainter({required this.width, required this.value, required this.index});

  @override
  void paint(Canvas canvas, Size size){

    Paint paint = Paint();
    if (this.value < 500 * .10) {
      paint.color = Color(0xFFDEEDCF);
    } else if (this.value < 500 * .20) {
      paint.color = Color(0xFFBFE1B0);
    } else if (this.value < 500 * .30) {
      paint.color = Color(0xFF99D492);
    } else if (this.value < 500 * .40) {
      paint.color = Color(0xFF74C67A);
    } else if (this.value < 500 * .50) {
      paint.color = Color(0xFF56B870);
    } else if (this.value < 500 * .60) {
      paint.color = Color(0xFF39A96B);
    } else if (this.value < 500 * .70) {
      paint.color = Color(0xFF1D9A6C);
    } else if (this.value < 500 * .80) {
      paint.color = Color(0xFF188977);
    } else if (this.value < 500 * .90) {
      paint.color = Color(0xFF137177);
    } else {
      paint.color = Color(0xFF0E4D64);
    }

    paint.strokeWidth =  width;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(index * width, 0), Offset(index * width, value.ceilToDouble()) , paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return true;
  }
}
