import 'dart:math';
import 'package:flutter/material.dart';


void main() => runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: GameScreen()));


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}


class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  int score = 0, highScore = 0;
  bool gameOver = true; // game paused at start
  final rand = Random();
  late AnimationController tileCtrl, bgCtrl;
  late Animation<Color?> bg1, bg2;
  double left = 0, speed = 3;


  final gradients = [
    [Colors.cyan, Colors.blueAccent],
    [Colors.purple, Colors.pinkAccent],
    [Colors.orange, Colors.redAccent],
    [Colors.greenAccent, Colors.teal],
    [Colors.yellow, Colors.deepOrange],
  ];
  final bgColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.orange,
    Colors.red
  ];


  @override
  void initState() {
    super.initState();
    tileCtrl = AnimationController(vsync: this)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && !gameOver) {
          _endGame();
        }
      });
    bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    bg1 = ColorTween(begin: bgColors[0], end: bgColors[3]).animate(bgCtrl);
    bg2 = ColorTween(begin: bgColors[2], end: bgColors[5]).animate(bgCtrl);


    // Show "Start Game" dialog when app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartDialog();
    });
  }


  void _newTile() {
    if (gameOver) return;
    left = rand.nextDouble();
    tileCtrl.duration = Duration(milliseconds: (speed * 1000).toInt());
    tileCtrl.reset();
    tileCtrl.forward();
  }


  void _tap() {
    if (gameOver || !tileCtrl.isAnimating) return;
    setState(() {
      score++;
      if (score > highScore) highScore = score;
      speed = (speed * 0.9).clamp(0.7, 5);
    });
    _newTile();
  }


  void _restart() {
    setState(() {
      score = 0;
      speed = 3;
      gameOver = false;
    });
    _newTile();
  }


  void _endGame() {
    setState(() => gameOver = true);
    tileCtrl.stop();


    bool newHigh = score >= highScore;
    if (newHigh) highScore = score;


    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(newHigh ? "🎉 Yay!" : "😢 Oops!",
              style: const TextStyle(color: Colors.white)),
          content: Text(
            newHigh
                ? "You got the highest score!\nHigh Score: $highScore"
                : "Try again!\nYour Score: $score",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restart();
              },
              child: const Text("Restart",
                  style: TextStyle(color: Colors.purpleAccent)),
            )
          ],
        ),
      );
    });
  }


  void _showStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // force user to press button
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text("🚀 Start Game",
            style: TextStyle(color: Colors.white)),
        content: const Text("Tap the falling tiles to score points!",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restart();
            },
            child: const Text("Start",
                style: TextStyle(color: Colors.purpleAccent, fontSize: 18)),
          )
        ],
      ),
    );
  }


  @override
  void dispose() {
    tileCtrl.dispose();
    bgCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext ctx) {
    final h = MediaQuery.of(ctx).size.height,
        w = MediaQuery.of(ctx).size.width;
    return Scaffold(
      body: AnimatedBuilder(
        animation: bgCtrl,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [bg1.value!, bg2.value!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: Stack(children: [
            Positioned(
                top: 50,
                left: 20,
                child: Text("Score: $score   High: $highScore",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold))),
            if (!gameOver)
              AnimatedBuilder(
                animation: tileCtrl,
                builder: (_, __) => Positioned(
                  top: tileCtrl.value * (h - 120),
                  left: left * (w - 80),
                  child: GestureDetector(
                    onTap: _tap,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: gradients[score % gradients.length]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: gradients[score % gradients.length][1]
                                  .withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2)
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text("Tap",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
