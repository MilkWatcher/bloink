import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(DilfApp());

class DilfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DILF Prototype',
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme)
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
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
  bool escalationActive = false;

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return OnboardingScreen(onComplete: (name) => setState(() => username = name));
    }

    return MainMenu(
      username: username!,
      goals: goals,
      onUpdateGoals: (updated) => setState(() => goals = updated),
      onUpdateSettings: (rand, morning) => setState(() {
        randomizeAlarm = rand;
        requireMorningPrompt = morning;
      }),
      randomizeAlarm: randomizeAlarm,
      requireMorningPrompt: requireMorningPrompt,
      escalationActive: escalationActive,
    );
  }
}

class BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF0F1724), Color(0xFF081023)],
          radius: 1.2,
          center: Alignment(-0.6, -0.8),
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const GlassPanel({required this.child, this.padding = const EdgeInsets.all(16.0), this.borderRadius, this.border});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final void Function(String username) onComplete;
  const OnboardingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BackgroundGradient(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GlassPanel(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('Welcome to DILF', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                      SizedBox(height: 10),
                      Text('Doomscroll Intervention & Life Focus', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      SizedBox(height: 20),
                      Text('Pick a name to get started:', style: TextStyle(fontSize: 16, color: Colors.white70)),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration.collapsed(hintText: 'Your name', hintStyle: TextStyle(color: Colors.white38)),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            final name = _controller.text.trim();
                            if (name.isNotEmpty) widget.onComplete(name);
                          },
                          child: Text('Get started', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

  const MainMenu({required this.username, required this.goals, required this.onUpdateGoals, required this.onUpdateSettings, required this.randomizeAlarm, required this.requireMorningPrompt, required this.escalationActive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('DILF')),
      body: Stack(
        children: [
          BackgroundGradient(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
              child: GlassPanel(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good evening, $username', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                      SizedBox(height: 10),
                      Text('Tonight: set three goals', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.45)),
                      SizedBox(height: 20),
                      for (int i = 0; i < 3; i++)
                        GoalRow(
                          index: i,
                          value: goals[i],
                          onChanged: (v) {
                            final updated = List<String>.from(goals);
                            updated[i] = v;
                            onUpdateGoals(updated);
                          },
                        ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF9F8EFF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => AlarmScreen(goals: goals, randomizeOrder: randomizeAlarm, escalationMode: escalationActive, requireMorningPrompt: requireMorningPrompt)))
                                    .then((result) {
                                  if (result != null && result is Map && result['fastDismiss'] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fast dismissal detected')));
                                  }
                                });
                              },
                              child: Text('Simulate Alarm', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          SizedBox(width: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feature coming soon')));
                            },
                            child: Text('Wind-down settings', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          )
                        ],
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: Text('Randomize bubble order', style: TextStyle(color: Colors.white70))),
                          Switch(value: randomizeAlarm, onChanged: (v) => onUpdateSettings(v, requireMorningPrompt), activeColor: Color(0xFF7BE8FF)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text('Require morning word prompt', style: TextStyle(color: Colors.white70))),
                          Switch(value: requireMorningPrompt, onChanged: (v) => onUpdateSettings(randomizeAlarm, v), activeColor: Color(0xFF7BE8FF)),
                        ],
                      ),
                      if (escalationActive)
                        Padding(padding: EdgeInsets.only(top: 12), child: Text('Escalation mode active', style: TextStyle(color: Colors.orangeAccent))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalRow extends StatelessWidget {
  final int index;
  final String value;
  final void Function(String) onChanged;
  const GoalRow({required this.index, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(border: InputBorder.none, hintText: 'Goal ${index + 1}', hintStyle: TextStyle(color: Colors.white38)),
        ),
      ),
    );
  }
}

class AlarmScreen extends StatefulWidget {
  final List<String> goals;
  final bool randomizeOrder;
  final bool escalationMode;
  final bool requireMorningPrompt;

  const AlarmScreen({Key? key, required this.goals, required this.randomizeOrder, required this.escalationMode, required this.requireMorningPrompt}) : super(key: key);

  @override
  AlarmScreenState createState() => AlarmScreenState();
}

class AlarmScreenState extends State<AlarmScreen> {
  late List<double> progress;
  late List<bool> completed;
  List<Timer?> timers = [null, null, null];

  @override
  void initState() {
    super.initState();
    progress = List<double>.filled(3, 0.0);
    completed = List<bool>.filled(3, false);
  }

  void startHold(int i) {
    if (widget.escalationMode) {
      final firstIncomplete = completed.indexWhere((c) => c == false);
      if (i != firstIncomplete) return;
    }

    timers[i]?.cancel();
    timers[i] = Timer.periodic(Duration(milliseconds: 100), (t) {
      setState(() {
        progress[i] += 0.034; // ~3 seconds to reach 1.0
        if (progress[i] >= 1.0) {
          progress[i] = 1.0;
          completed[i] = true;
          t.cancel();
        }
      });
    });
  }

  void cancelHold(int i) {
    timers[i]?.cancel();
    timers[i] = null;
    setState(() {
      if (!completed[i]) progress[i] = 0.0;
    });
  }

  @override
  void dispose() {
    for (var t in timers) t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alarm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 0; i < 3; i++)
              AlarmBubble(
                label: widget.goals[i],
                progress: progress[i],
                completed: completed[i],
                locked: i > 0 && widget.escalationMode && !completed[i - 1],
                onHoldStart: () => startHold(i),
                onHoldCancel: () => cancelHold(i),
              ),
          ],
        ),
      ),
    );
  }
}

class AlarmBubble extends StatefulWidget {
  final String label;
  final double progress;
  final bool completed;
  final bool locked;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldCancel;

  const AlarmBubble({required this.label, required this.progress, required this.completed, required this.locked, required this.onHoldStart, required this.onHoldCancel});

  @override
  _AlarmBubbleState createState() => _AlarmBubbleState();
}

class _AlarmBubbleState extends State<AlarmBubble> {
  bool _pressed = false;

  void _handleDown() {
    if (widget.locked || widget.completed) return;
    setState(() => _pressed = true);
    widget.onHoldStart();
  }

  void _handleUp() {
    if (_pressed) widget.onHoldCancel();
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = LinearGradient(colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.03)]);
    return GestureDetector(
      onTapDown: (_) => _handleDown(),
      onTapUp: (_) => _handleUp(),
      onTapCancel: _handleUp,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 160),
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                if (widget.completed)
                  Icon(Icons.check_circle, color: Colors.lightGreenAccent)
                else if (widget.locked)
                  Icon(Icons.lock_outline, color: Colors.white70)
                else
                  Icon(Icons.touch_app, color: Colors.white70),
              ],
            ),
            SizedBox(height: 10),
            Text(widget.locked ? 'Hold after previous goal' : 'Hold to dismiss', style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: widget.completed ? 1.0 : widget.progress,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(widget.completed ? Colors.lightGreenAccent : Colors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
