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
  bool randomizeAlarm = false;
  bool requireMorningPrompt = false;
  int fastDismissCounter = 0;
  bool escalationActive = false;

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
      randomizeAlarm: randomizeAlarm,
      requireMorningPrompt: requireMorningPrompt,
      escalationActive: escalationActive,
      onUpdateGoals: (updated) {
        setState(() {
          goals = updated;
        });
      },
      onUpdateSettings: (rand, promptReq) {
        setState(() {
          randomizeAlarm = rand;
          requireMorningPrompt = promptReq;
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
              Text('Welcome to DILF', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Doomscroll Intervention & Life Focus', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
  final void Function(bool, bool) onUpdateSettings;
  final bool randomizeAlarm;
  final bool requireMorningPrompt;
  final bool escalationActive;

  MainMenu({required this.username, required this.goals, required this.onUpdateGoals, required this.onUpdateSettings, required this.randomizeAlarm, required this.requireMorningPrompt, required this.escalationActive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DILF')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good evening, $username', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlarmScreen(goals: goals, randomizeOrder: randomizeAlarm, escalationMode: escalationActive, requireMorningPrompt: requireMorningPrompt))).then((result) {
                      if (result != null && result is Map && result['fastDismiss'] == true) {
                        // Notifying user via snackbar; higher-level state could persist this
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fast dismissal detected')));
                      }
                    });
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
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text('Randomize bubble order')),
                Switch(value: randomizeAlarm, onChanged: (v) => onUpdateSettings(v, requireMorningPrompt)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Require morning word prompt')),
                Switch(value: requireMorningPrompt, onChanged: (v) => onUpdateSettings(randomizeAlarm, v)),
              ],
            ),
            if (escalationActive) Padding(padding: EdgeInsets.only(top:12), child: Text('Escalation mode active', style: TextStyle(color: Colors.orangeAccent))),
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
  final bool randomizeOrder;
  final bool escalationMode;
  final bool requireMorningPrompt;
  AlarmScreen({required this.goals, this.randomizeOrder = false, this.escalationMode = false, this.requireMorningPrompt = false});

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late List<double> progress;
  late List<bool> completed;
  List<Timer?> timers = [null, null, null];
  late List<int> order;
  bool sequentialRequired = false;
  int nextRequiredIndex = 0;
  late int startTimestamp;

  @override
  void initState() {
    super.initState();
    progress = [0.0, 0.0, 0.0];
    completed = [false, false, false];
    order = [0,1,2];
    if (widget.randomizeOrder && !widget.escalationMode) {
      order.shuffle();
    }
    sequentialRequired = widget.escalationMode;
    nextRequiredIndex = 0;
    startTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  void startHold(int i) {
    // map visible index to actual goal index
    final actual = order[i];
    if (completed[actual]) return;
    if (sequentialRequired && actual != order[nextRequiredIndex]) {
      // provide UI feedback that this bubble is locked
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please dismiss bubbles in order')));
      });
      return;
    }
    timers[actual]?.cancel();
    const totalMs = 3000;
    const tickMs = 50;
    int elapsed = 0;
    timers[actual] = Timer.periodic(Duration(milliseconds: tickMs), (t) {
      setState(() {
        elapsed += tickMs;
        progress[actual] = (elapsed / totalMs).clamp(0.0, 1.0);
        if (progress[actual] >= 1.0) {
          completed[actual] = true;
          timers[actual]?.cancel();
          timers[actual] = null;
          if (sequentialRequired) nextRequiredIndex++;
          checkAllCompleted();
        }
      });
    });
  }

  void cancelHold(int i) {
    final actual = order[i];
    timers[actual]?.cancel();
    timers[actual] = null;
    setState(() {
      progress[actual] = 0.0;
    });
  }

  void checkAllCompleted() {
    if (completed.every((c) => c)) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTimestamp;
      final totalHoldMs = 3000 * 3;
      final fastDismiss = elapsed < (totalHoldMs * 0.6);
      if (widget.requireMorningPrompt) {
        // show prompt input before finishing
        showDialog<String>(context: context, barrierDismissible: false, builder: (_) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text('Morning word'),
            content: TextField(controller: controller, decoration: InputDecoration(hintText: 'One word to describe how you feel')),
            actions: [TextButton(onPressed: (){
              if (controller.text.trim().isNotEmpty) Navigator.of(context).pop(controller.text.trim());
            }, child: Text('Submit'))],
          );
        }).then((word) {
          Navigator.of(context).pop({'elapsed': elapsed, 'fastDismiss': fastDismiss, 'word': word});
        });
      } else {
        Navigator.of(context).pop({'elapsed': elapsed, 'fastDismiss': fastDismiss});
      }
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
            Text('Hold each bubble for 3 seconds to dismiss', style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) {
                  final actual = order[i];
                  final locked = sequentialRequired && actual != order[nextRequiredIndex];
                  return AlarmBubble(
                    label: widget.goals[actual].isEmpty ? 'Goal ${actual+1}' : widget.goals[actual],
                    progress: progress[actual],
                    completed: completed[actual],
                    locked: locked,
                    onHoldStart: () => startHold(i),
                    onHoldEnd: () => cancelHold(i),
                  );
                }),
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
  final bool locked;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  AlarmBubble({required this.label, required this.progress, required this.completed, required this.onHoldStart, required this.onHoldEnd, this.locked = false});

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
                  gradient: completed
                      ? LinearGradient(colors: [Colors.green, Colors.lightGreenAccent])
                      : (locked ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700]) : LinearGradient(colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade700])),
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
              ),
              if (locked) Positioned(
                right: 6,
                top: 6,
                child: Icon(Icons.lock, size: 20, color: Colors.white70),
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
