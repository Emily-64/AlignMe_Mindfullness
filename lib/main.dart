// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(AlignMeFinalApp());

class AlignMeFinalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlignMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

/* ===========================
   Assets (add these files)
   - assets/images/forest.png
   - assets/images/mountain.png
   - assets/images/desert.png
   - assets/images/hill.png
   - assets/images/relax_banner.png
   - assets/images/lotus.png (optional, used in appbar)
   Declare in pubspec.yaml:
   flutter:
     assets:
       - assets/images/
   Also include dependency:
     url_launcher: ^6.3.0
   =========================== */

/* ---------------------------
   Data models & sample data
----------------------------*/
class SoundSession {
  final String id, title, subtitle, duration, artwork;
  SoundSession(this.id, this.title, this.subtitle, this.duration, this.artwork);
}

List<SoundSession> sampleRelax = [
  SoundSession('r1', 'Painting Forest', 'By: Painting with Passion', '20 min', 'assets/images/forest.png'),
  SoundSession('r2', 'Mountaineers', 'By: Summit Sounds', '15 min', 'assets/images/mountain.png'),
  SoundSession('r3', 'Lovely Deserts', 'By: Dune Studio', '39 min', 'assets/images/desert.png'),
  SoundSession('r4', 'The Hill Sides', 'By: Hillside Audio', '50 min', 'assets/images/hill.png'),
];

List<SoundSession> sampleCalm = [
  SoundSession('c1', 'Morning Calm', 'By: Gentle Waves', '10 min', 'assets/images/forest.png'),
  SoundSession('c2', 'Soft Rain', 'By: Cozy Ambience', '15 min', 'assets/images/mountain.png'),
];

List<SoundSession> sampleFocus = [
  SoundSession('f1', 'Concentration Flow', 'By: Focus Lab', '25 min', 'assets/images/hill.png'),
  SoundSession('f2', 'Alpha Tones', 'By: Brainwave Co', '30 min', 'assets/images/desert.png'),
];

List<SoundSession> sampleAnxious = [
  SoundSession('a1', 'Quick Reset', 'By: Calm Tools', '5 min', 'assets/images/forest.png'),
  SoundSession('a2', 'Safe Space', 'By: Guided Peace', '12 min', 'assets/images/mountain.png'),
];

List<Map<String, String>> youtubeSessions = [
  {'title': 'Yoga for Stress Relief', 'url': 'https://www.youtube.com/watch?v=4pKly2JojMw'},
  {'title': 'Breathing for Anxiety', 'url': 'https://www.youtube.com/watch?v=inpok4MKVLM'},
  {'title': 'Guided Calm Meditation', 'url': 'https://www.youtube.com/watch?v=ZToicYcHIOU'},
];

List<Map<String, String>> stressActivities = [
  {'title': '5-4-3-2-1 Grounding', 'detail': 'Name 5 things you see, 4 you can touch, 3 you hear, 2 you can smell, 1 you can taste.'},
  {'title': 'Visualization Escape', 'detail': 'Close your eyes and imagine a safe, calm place.'},
  {'title': 'Progressive Muscle Relaxation', 'detail': 'Tense and relax muscle groups from toes to head.'},
  {'title': 'EFT Tapping', 'detail': 'Tap on meridian points while breathing slowly.'},
];

/* ---------------------------
   Utility: gradient scaffold used everywhere
----------------------------*/
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  GradientScaffold({required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E5954), Color(0xFF1E3C38), Color(0xFF142F2C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(backgroundColor: Colors.transparent, appBar: appBar, body: child),
    );
  }
}

/* ---------------------------
   AppBar: back arrow on all pages, lotus center, no profile
   Home back shows confirm-exit dialog
----------------------------*/
AppBar buildPremiumAppBar(BuildContext context, {required bool isHome}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (isHome) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Exit AlignMe?'),
              content: const Text('Do you want to exit AlignMe?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                TextButton(onPressed: () => SystemNavigator.pop(), child: const Text('Yes')),
              ],
            ),
          );
        } else {
          Navigator.maybePop(context);
        }
      },
    ),
    centerTitle: true,
    title: SizedBox(
      height: 36,
      child: Image.asset('assets/images/lotus.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.spa, size: 30)),
    ),
  );
}

/* ---------------------------
   Artwork widget with fallback
----------------------------*/
class Artwork extends StatelessWidget {
  final String asset;
  final double radius;
  Artwork(this.asset, {this.radius = 36});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        asset,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
            child: const Icon(Icons.music_note, color: Colors.white70),
          );
        },
      ),
    );
  }
}

/* ---------------------------
   HOME PAGE
----------------------------*/
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  String selectedMood = 'Calm';
  final moods = ['Calm', 'Relax', 'Focus', 'Anxious', 'Tools'];
  final double cardRadius = 25.0;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: true),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 6),
              const Text('Welcome back', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('How are you feeling today ?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              SizedBox(
                height: 86,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: moods.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final m = moods[i];
                    final isSel = m == selectedMood;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedMood = m);
                        if (m == 'Relax') Navigator.push(context, MaterialPageRoute(builder: (_) => RelaxSoundsPage()));
                        if (m == 'Calm') Navigator.push(context, MaterialPageRoute(builder: (_) => CalmMeditationPage()));
                        if (m == 'Focus') Navigator.push(context, MaterialPageRoute(builder: (_) => FocusMusicPage()));
                        if (m == 'Anxious') Navigator.push(context, MaterialPageRoute(builder: (_) => AnxietyReliefPage()));
                        if (m == 'Tools') Navigator.push(context, MaterialPageRoute(builder: (_) => ToolsPage()));
                      },
                      child: Container(
                        width: 92,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: isSel ? Colors.white24 : Colors.white12, borderRadius: BorderRadius.circular(25)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          // Use lotus-style icons as requested (Calm: smile-like, Relax: spa/leaf, Focus: target, Anxious: meditation)
                          Icon(_moodIcon(m), color: Colors.white, size: 26),
                          const SizedBox(height: 6),
                          Text(m, style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: ListView(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Recommended Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sampleRelax.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, idx) {
                        final s = sampleRelax[idx];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(s))),
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(cardRadius)),
                            child: Row(children: [
                              Artwork(s.artwork, radius: 38),
                              const SizedBox(width: 12),
                              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 6),
                                Text(s.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(s.duration, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ])),
                              const SizedBox(width: 8),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Mindfulness Tools', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),

                  _toolCard(context, 'Breathing Exercise', 'Box breathing (4-4-4-4)', Icons.air, () => Navigator.push(context, MaterialPageRoute(builder: (_) => BreathingExercisePage()))),
                  _toolCard(context, 'Stress Relief Activities', 'Grounding & quick practices', Icons.self_improvement, () => Navigator.push(context, MaterialPageRoute(builder: (_) => StressReliefPage()))),
                  _toolCard(context, 'YouTube Sessions', 'Curated guided videos', Icons.play_circle_fill, () => Navigator.push(context, MaterialPageRoute(builder: (_) => YouTubeSessionsPage()))),
                  _toolCard(context, 'Sleep Music', 'Ambient soundscapes', Icons.nightlight_round, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SleepMusicPage()))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _moodIcon(String m) {
    switch (m) {
      case 'Calm':
        return Icons.sentiment_satisfied; // smile-like
      case 'Relax':
        return Icons.spa; // lotus / leaf
      case 'Focus':
        return Icons.center_focus_strong; // focus target
      case 'Anxious':
        return Icons.self_improvement; // meditating person
      default:
        return Icons.spa;
    }
  }

  Widget _toolCard(BuildContext ctx, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white12, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}

/* ---------------------------
   RELAX / CALM / FOCUS / ANXIETY PAGES
   All use same layout but different data sources
----------------------------*/

class RelaxSoundsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MoodListPage(title: 'Relax Sounds', banner: 'assets/images/relax_banner.png', sessions: sampleRelax);
  }
}

class CalmMeditationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MoodListPage(title: 'Calming Sessions', banner: 'assets/images/relax_banner.png', sessions: sampleCalm);
  }
}

class FocusMusicPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MoodListPage(title: 'Focus Music', banner: 'assets/images/relax_banner.png', sessions: sampleFocus);
  }
}

class AnxietyReliefPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MoodListPage(title: 'Anxiety Relief', banner: 'assets/images/relax_banner.png', sessions: sampleAnxious);
  }
}

/* Reusable mood list page to match your reference layout */
class MoodListPage extends StatelessWidget {
  final String title;
  final String banner;
  final List<SoundSession> sessions;
  MoodListPage({required this.title, required this.banner, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 150,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), image: DecorationImage(image: AssetImage(banner), fit: BoxFit.cover)),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('Sometimes the most productive thing you can do is relax.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = sessions[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  Artwork(s.artwork, radius: 30),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    const Text('58,999 Listening', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(s.duration, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white70, size: 30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(s)))),
                  ])
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

/* ---------------------------
   PLAYER PAGE (restored original style)
   - big circular artwork
   - waveform bars
   - centered play/pause
----------------------------*/
class PlayerPage extends StatefulWidget {
  final SoundSession session;
  PlayerPage(this.session);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool isPlaying = false;
  double progress = 0.0;
  Timer? _timer;

  void togglePlay() {
    setState(() => isPlaying = !isPlaying);
    if (isPlaying) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
        setState(() {
          progress += 0.01;
          if (progress >= 1.0) {
            progress = 1.0;
            isPlaying = false;
            t.cancel();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 18)]),
            child: Artwork(s.artwork, radius: 110),
          ),
          const SizedBox(height: 18),
          Text(s.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(s.subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          SizedBox(height: 72, child: Waveform(progress: progress)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.replay_10), color: Colors.white70, onPressed: () => setState(() => progress = (progress - 0.05).clamp(0.0, 1.0))),
            const SizedBox(width: 18),
            ElevatedButton(
              onPressed: togglePlay,
              style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(16)),
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 30),
            ),
            const SizedBox(width: 18),
            IconButton(icon: const Icon(Icons.forward_10), color: Colors.white70, onPressed: () => setState(() => progress = (progress + 0.05).clamp(0.0, 1.0))),
          ]),
          const SizedBox(height: 18),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.white12, color: Colors.tealAccent),
        ]),
      ),
    );
  }
}

/* Simple waveform visual matching your reference */
class Waveform extends StatelessWidget {
  final double progress;
  Waveform({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(24, (i) {
        final t = i / 24;
        final base = 6 + 20 * (1 - ((t - progress).abs()));
        final h = base.clamp(4.0, 32.0);
        final opacity = (1.0 - (t - progress).abs()).clamp(0.0, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(height: h, decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.5 * opacity), borderRadius: BorderRadius.circular(3))),
          ),
        );
      }),
    );
  }
}
/// ADD THIS CLASS to lib/main.dart (place it before BreathingExercisePage)
class ToolsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: ListView(
          children: [
            const SizedBox(height: 6),
            const Text('Tools & Utilities', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // Breathing
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.air, color: Colors.white)),
                title: const Text('Breathing Exercise', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Box breathing (4-4-4-4)', style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BreathingExercisePage())),
              ),
            ),

            const SizedBox(height: 12),

            // Stress Relief
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.self_improvement, color: Colors.white)),
                title: const Text('Stress Relief Activities', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Grounding & relaxation', style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StressReliefPage())),
              ),
            ),

            const SizedBox(height: 12),

            // YouTube Sessions
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.play_circle_fill, color: Colors.white)),
                title: const Text('YouTube Sessions', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Guided videos', style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => YouTubeSessionsPage())),
              ),
            ),

            const SizedBox(height: 12),

            // Sleep Music
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.nightlight_round, color: Colors.white)),
                title: const Text('Sleep Music', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Ambient soundscapes', style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SleepMusicPage())),
              ),
            ),

            const SizedBox(height: 24),

            // Optional: extra text or links
            const Text('Quick Tools', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('Use the Breathing exercise to calm your nervous system, or open YouTube Sessions for guided videos.', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


/* ---------------------------
   Tools: Breathing / Stress / YouTube / Sleep Music
----------------------------*/

class BreathingExercisePage extends StatefulWidget {
  @override
  State<BreathingExercisePage> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercisePage> {
  final phases = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  int phaseIndex = 0;
  int secondsLeft = 4;
  Timer? _timer;
  double size = 120;
  bool running = false;

  void start() {
    _timer?.cancel();
    running = true;
    phaseIndex = 0;
    secondsLeft = 4;
    animatePhase();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsLeft--;
        if (secondsLeft <= 0) {
          phaseIndex = (phaseIndex + 1) % phases.length;
          secondsLeft = 4;
          animatePhase();
        }
      });
    });
  }

  void animatePhase() {
    final name = phases[phaseIndex];
    setState(() {
      if (name == 'Inhale') size = 220;
      else if (name == 'Exhale') size = 100;
      else size = 140;
    });
  }

  void stop() {
    _timer?.cancel();
    setState(() {
      running = false;
      phaseIndex = 0;
      secondsLeft = 4;
      size = 120;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(children: [
          const SizedBox(height: 8),
          const Text('Box Breathing', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          AnimatedContainer(duration: const Duration(milliseconds: 400), width: size, height: size, curve: Curves.easeInOut, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(22)), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(phases[phaseIndex], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(secondsLeft > 0 ? '$secondsLeft s' : '', style: const TextStyle(color: Colors.white70)),
          ]))),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: running ? null : start, icon: const Icon(Icons.play_arrow), label: const Text('Start')),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: running ? stop : null, child: const Text('Stop')),
          ]),
        ]),
      ),
    );
  }
}

class StressReliefPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: ListView(padding: const EdgeInsets.all(16), children: stressActivities.map((a) {
        return Card(
          color: Colors.white12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: ListTile(
            title: Text(a['title']!, style: const TextStyle(color: Colors.white)),
            subtitle: Text(a['detail']!, style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StressDetailPage(a['title']!, a['detail']!))),
          ),
        );
      }).toList()),
    );
  }
}

class StressDetailPage extends StatelessWidget {
  final String title, detail;
  StressDetailPage(this.title, this.detail);
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Text(detail, style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
      ])),
    );
  }
}

class YouTubeSessionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: youtubeSessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = youtubeSessions[i];
          return Card(
            color: Colors.white12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: ListTile(
              leading: Container(width: 60, height: 60, decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), image: DecorationImage(image: AssetImage('assets/images/relax_banner.png'), fit: BoxFit.cover))),
              title: Text(s['title']!, style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.open_in_new, color: Colors.white70),
              onTap: () => _openUrl(s['url']!),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // no-op or show snackbar
    }
  }
}

class SleepMusicPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: buildPremiumAppBar(context, isHome: false),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sampleRelax.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = sampleRelax[i];
          return Card(
            color: Colors.white12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: ListTile(
              leading: Artwork(s.artwork, radius: 28),
              title: Text(s.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text('${s.duration}  ·  ${s.subtitle}', style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white70), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(s)))),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(s))),
            ),
          );
        },
      ),
    );
  }
}
