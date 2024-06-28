import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crono Wear',
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return TimerScreen(mode);
          },
        );
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  final WearMode mode;

  const TimerScreen(this.mode, {super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  late int _count;
  late String _strCount;
  late bool _isRunning;
  late double _iconOpacity;
  Color _currentColor = Colors.amber; // Initial color

  @override
  void initState() {
    _count = 0;
    _strCount = "00:00:00.0"; // Initial value with milliseconds
    _isRunning = false;
    _iconOpacity = 0.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 27,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Cronó Wear',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold, // Bold font weight
                      ),
                    ),
                    SizedBox(
                        height: 5), // Adjust this height to move the icon down
                    Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: _currentColor,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _strCount.substring(0, _strCount.length - 1),
                        style: TextStyle(
                          color: _currentColor,
                          fontSize: 30.0,
                          fontFamily: 'Digital',
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: _currentColor
                                  .withOpacity(0.6), // Neon glow color
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: _strCount.substring(_strCount.length - 1),
                        style: TextStyle(
                          color: _currentColor,
                          fontSize: 20.0,
                          fontFamily: 'Digital',
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: _currentColor
                                  .withOpacity(0.6), // Neon glow color
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: AnimatedOpacity(
                  opacity: _iconOpacity,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    _isRunning
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white.withOpacity(0.8),
                    size: 80.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: GestureDetector(
                  onTap: _resetTimer,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 28, 28, 28),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.replay,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      _iconOpacity = 1.0;
      if (_isRunning) {
        _timer.cancel();
        _isRunning = false;
      } else {
        _startTimer();
        _isRunning = true;
      }
    });
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _iconOpacity = 0.0;
      });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _count += 100;
        int hour = _count ~/ 3600000;
        int minute = (_count % 3600000) ~/ 60000;
        int second = (_count % 60000) ~/ 1000;
        int millisecond = (_count % 1000) ~/ 100; // Only first digit

        _strCount = (hour < 10 ? "0$hour" : "$hour") +
            ":" +
            (minute < 10 ? "0$minute" : "$minute") +
            ":" +
            (second < 10 ? "0$second" : "$second") +
            "." +
            "$millisecond"; // Showing only the first digit of milliseconds

        // Change color every minute (60 seconds)
        if (second == 0 && millisecond == 0) {
          _currentColor = _getNextColor(_currentColor);
        }
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _timer.cancel();
      _count = 0;
      _strCount = "00:00:00.0";
      _isRunning = false;
      _currentColor = Colors.amber; // Reset color to initial
    });
  }

  Color _getNextColor(Color currentColor) {
    List<Color> colorList = [
      Color.fromARGB(255, 27, 255, 35),
      const Color.fromARGB(255, 33, 215, 243),
      const Color.fromARGB(255, 198, 38, 226),
      const Color.fromARGB(255, 255, 25, 9),
      const Color.fromARGB(255, 255, 199, 29),
    ];

    int currentIndex = colorList.indexOf(currentColor);
    int nextIndex = (currentIndex + 1) % colorList.length;
    return colorList[nextIndex];
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
