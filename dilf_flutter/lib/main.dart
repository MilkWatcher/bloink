import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(DilfApp());
}

class DilfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DILF Prototype',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(),
        scaffoldBackgroundColor: Color(0xFF0B0B0D),
      ),
      home: HomeRouter(),
    );
  }
}

class HomeRouter extends StatefulWidget {
  @override
  _HomeRouterState createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  String? username;
  List<String> goals = ['', '', ''];

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return OnboardingScreen(
        onComplete: (name) {
          setState(() {
            username = name;
          });
        },
      );
    }

    return MainMenu(
      username: username!,
      goals: goals,
      onUpdateGoals: (updated) {
        setState(() {
          goals = updated;
        });
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final void Function(String username) onComplete;
  OnboardingScreen({required this.onComplete});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text('Welcome to DILF', style: Theme.of(context).textTheme.headline4),
              SizedBox(height: 12),
              Text('Doomscroll Intervention & Life Focus', style: Theme.of(context).textTheme.subtitle1),
              SizedBox(height: 32),
              Text('Pick a name to get started:'),
              SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850],
                  hintText: 'Your name',
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  final name = _controller.text.trim();
                  if (name.isNotEmpty) widget.onComplete(name);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  child: Text('Get started'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  final String username;
  final List<String> goals;
  final void Function(List<String>) onUpdateGoals;

  MainMenu({required this.username, required this.goals, required this.onUpdateGoals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DILF')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good evening, $username', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 16),
            Text('Tonight: set three goals for tomorrow'),
            SizedBox(height: 12),
            for (int i = 0; i < 3; i++) GoalRow(index: i, value: goals[i], onChanged: (v) {
              final updated = List<String>.from(goals);
              updated[i] = v;
              onUpdateGoals(updated);
            }),
            Spacer(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlarmScreen(goals: goals)));
                  },
                  child: Text('Simulate Alarm'),
                ),
                SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // placeholder for future features
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feature coming soon')));
                  },
                  child: Text('Wind-down settings'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class GoalRow extends StatelessWidget {
  final int index;
  final String value;
  final void Function(String) onChanged;
  GoalRow({required this.index, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: 'Goal ${index + 1}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmScreen extends StatefulWidget {
  final List<String> goals;
  AlarmScreen({required this.goals});

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late List<double> progress;
  late List<bool> completed;
  List<Timer?> timers = [null, null, null];

  @override
  void initState() {
    super.initState();
    progress = [0.0, 0.0, 0.0];
    completed = [false, false, false];
  }

  void startHold(int i) {
    if (completed[i]) return;
    timers[i]?.cancel();
    const totalMs = 3000;
    const tickMs = 50;
    int elapsed = 0;
    timers[i] = Timer.periodic(Duration(milliseconds: tickMs), (t) {
      setState(() {
        elapsed += tickMs;
        progress[i] = (elapsed / totalMs).clamp(0.0, 1.0);
        if (progress[i] >= 1.0) {
          completed[i] = true;
          timers[i]?.cancel();
          timers[i] = null;
          checkAllCompleted();
        }
      });
    });
  }

  void cancelHold(int i) {
    timers[i]?.cancel();
    timers[i] = null;
    setState(() {
      progress[i] = 0.0;
    });
  }

  void checkAllCompleted() {
    if (completed.every((c) => c)) {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Alarm dismissed'),
        content: Text('Nice — you read your goals. Have a good morning.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close'))],
      ));
    }
  }

  @override
  void dispose() {
    for (var t in timers) t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DILF Alarm')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 12),
            Text('Hold each bubble for 3 seconds to dismiss', style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) => AlarmBubble(
                  label: widget.goals[i].isEmpty ? 'Goal ${i+1}' : widget.goals[i],
                  progress: progress[i],
                  completed: completed[i],
                  onHoldStart: () => startHold(i),
                  onHoldEnd: () => cancelHold(i),
                )),
              ),
            ),
            SizedBox(height: 24),
            if (completed.every((c) => c)) Text('Dismissed — good job!', style: TextStyle(color: Colors.greenAccent)),
          ],
        ),
      ),
    );
  }
}

class AlarmBubble extends StatelessWidget {
  final String label;
  final double progress;
  final bool completed;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  AlarmBubble({required this.label, required this.progress, required this.completed, required this.onHoldStart, required this.onHoldEnd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onHoldStart(),
      onTapUp: (_) => onHoldEnd(),
      onTapCancel: () => onHoldEnd(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: completed ? LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]) : LinearGradient(colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade700]),
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: completed ? 1.0 : progress,
                  strokeWidth: 8,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(completed ? Icons.check : Icons.play_arrow, size: 32),
              )
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: 140,
            child: Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          )
        ],
      ),
    );
  }
}
