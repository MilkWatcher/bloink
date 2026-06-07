import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(DilfApp());
}

class DilfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DILF Prototype',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF9F8EFF),
          secondary: Color(0xFF90E1C9),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
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

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final BoxBorder? border;

  const GlassPanel({required this.child, this.padding = const EdgeInsets.all(20), this.borderRadius = const BorderRadius.all(Radius.circular(30)), this.border});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: borderRadius,
            border: border ?? Border.all(color: Colors.white.withOpacity(0.14), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: Offset(0, 10)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1323), Color(0xFF070B13)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF8EAAFF).withOpacity(0.22), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF8EEDC2).withOpacity(0.16), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
                ),
              ),
            ),
          ),
        ],
      ),
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BackgroundGradient(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GlassPanel(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text('Welcome to DILF', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10),
                    Text('Doomscroll Intervention & Life Focus', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    SizedBox(height: 30),
                    Text('Pick a name to get started:', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    SizedBox(height: 12),
                    GlassPanel(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your name',
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        final name = _controller.text.trim();
                        if (name.isNotEmpty) widget.onComplete(name);
                      },
                      child: Text('Get started', style: TextStyle(color: Colors.white, fontSize: 16)),
                    )
                  ],
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

  MainMenu({required this.username, required this.goals, required this.onUpdateGoals, required this.onUpdateSettings, required this.randomizeAlarm, required this.requireMorningPrompt, required this.escalationActive});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good evening, $username', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                    SizedBox(height: 10),
                    Text('Set three thoughtful goals for tomorrow.', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.45)),
                    SizedBox(height: 20),
                    for (int i = 0; i < 3; i++) GoalRow(index: i, value: goals[i], onChanged: (v) {
                      final updated = List<String>.from(goals);
                      updated[i] = v;
                      onUpdateGoals(updated);
                    }),
                    Spacer(),
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
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlarmScreen(goals: goals, randomizeOrder: randomizeAlarm, escalationMode: escalationActive, requireMorningPrompt: requireMorningPrompt))).then((result) {
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
                    if (escalationActive) Padding(padding: EdgeInsets.only(top: 12), child: Text('Escalation mode active', style: TextStyle(color: Colors.orangeAccent))),
                  ],
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
  GoalRow({required this.index, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        borderRadius: BorderRadius.circular(24),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Goal ${index + 1}',
            hintStyle: TextStyle(color: Colors.white38),
          ),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('DILF Alarm')),
      body: Stack(
        children: [
          BackgroundGradient(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GlassPanel(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    Text('Hold each pill for 3 seconds to dismiss', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    SizedBox(height: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final actual = order[i];
                          final locked = sequentialRequired && actual != order[nextRequiredIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AlarmBubble(
                              label: widget.goals[actual].isEmpty ? 'Goal ${actual + 1}' : widget.goals[actual],
                              progress: progress[actual],
                              completed: completed[actual],
                              locked: locked,
                              onHoldStart: () => startHold(i),
                              onHoldEnd: () => cancelHold(i),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (completed.every((c) => c)) Text('Dismissed — good job!', style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
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
  final VoidCallback onHoldEnd;

  AlarmBubble({required this.label, required this.progress, required this.completed, required this.onHoldStart, required this.onHoldEnd, this.locked = false});

  @override
  _AlarmBubbleState createState() => _AlarmBubbleState();
}

class _AlarmBubbleState extends State<AlarmBubble> {
  bool _pressed = false;

  void _handleDown() {
    setState(() => _pressed = true);
    widget.onHoldStart();
  }

  void _handleUp() {
    setState(() => _pressed = false);
    widget.onHoldEnd();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = widget.completed
        ? LinearGradient(colors: [Color(0xFF1A472B), Color(0xFF2F7A48)])
        : (widget.locked
            ? LinearGradient(colors: [Color(0xFF26292D), Color(0xFF1C1F22)])
            : LinearGradient(colors: [Color(0xFF22232A), Color(0xFF181A1F)]));

    return GestureDetector(
      onTapDown: (_) => _handleDown(),
      onTapUp: (_) => _handleUp(),
      onTapCancel: () => _handleUp(),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
          decoration: BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.16), width: 1.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(_pressed ? 0.20 : 0.28), blurRadius: 20, offset: Offset(0, _pressed ? 8 : 12)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
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
              Text(
                widget.locked ? 'Hold after previous goal' : 'Hold to dismiss',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: widget.completed ? 1.0 : widget.progress),
                  duration: Duration(milliseconds: 180),
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.completed ? Colors.lightGreenAccent : Colors.cyanAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
