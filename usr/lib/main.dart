import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MagicalClockApp());
}

class MagicalClockApp extends StatelessWidget {
  const MagicalClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Timekeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CinematicSceneScreen(),
      },
    );
  }
}

class CinematicSceneScreen extends StatefulWidget {
  const CinematicSceneScreen({super.key});

  @override
  State<CinematicSceneScreen> createState() => _CinematicSceneScreenState();
}

class _CinematicSceneScreenState extends State<CinematicSceneScreen>
    with TickerProviderStateMixin {
  late AnimationController _clockController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  bool _isTimeStopped = false;

  @override
  void initState() {
    super.initState();
    // Clock animation running continuously
    _clockController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update();
          }
          _particles.removeWhere((p) => p.life <= 0);
        });
      });
  }

  @override
  void dispose() {
    _clockController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _touchClock() {
    if (_isTimeStopped) return;

    setState(() {
      _isTimeStopped = true;
      _clockController.stop();
      _generateParticles();
      _particleController.forward(from: 0).then((_) {
        // Option to reset after some time
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isTimeStopped = false;
              _clockController.repeat();
              _particles.clear();
            });
          }
        });
      });
    });
  }

  void _generateParticles() {
    final random = Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: 0, // Centered relative to the clock
        y: 0,
        vx: (random.nextDouble() - 0.5) * 10,
        vy: (random.nextDouble() - 0.5) * 10,
        life: 1.0,
        decay: random.nextDouble() * 0.02 + 0.01,
        color: Colors.blueAccent.withOpacity(random.nextDouble() * 0.5 + 0.5),
        size: random.nextDouble() * 6 + 2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background - Morning Sunlight in Indian Village Courtyard vibe
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF8B5A2B), // warm morning light
                    Color(0xFF2C3E50), // shadows of courtyard
                    Color(0xFF1A1A1D),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // Cinematic Lighting overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Colors.orangeAccent.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: _isTimeStopped ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: const Text(
                        "Morning Sunlight\nBirds Singing",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // The Magical Wooden Clock
                    GestureDetector(
                      onTap: _touchClock,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Clock Widget
                          Container(
                            width: isMobile ? 250 : 350,
                            height: isMobile ? 250 : 350,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3E2723), // Dark wood
                              boxShadow: [
                                BoxShadow(
                                  color: _isTimeStopped 
                                      ? Colors.blueAccent.withOpacity(0.6) 
                                      : Colors.black54,
                                  blurRadius: _isTimeStopped ? 50 : 20,
                                  spreadRadius: _isTimeStopped ? 10 : 5,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  inset: true,
                                ) as BoxShadow,
                              ],
                              border: Border.all(
                                color: const Color(0xFF5D4037),
                                width: 10,
                              ),
                            ),
                            child: AnimatedBuilder(
                              animation: _clockController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: ClockPainter(
                                    progress: _clockController.value,
                                    isStopped: _isTimeStopped,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Particle Layer
                          if (_particles.isNotEmpty)
                            SizedBox(
                              width: isMobile ? 250 : 350,
                              height: isMobile ? 250 : 350,
                              child: CustomPaint(
                                painter: ParticlePainter(particles: _particles),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: _isTimeStopped
                          ? const Text(
                              "The birds suddenly become silent.\nTime stands still.",
                              key: ValueKey('stopped'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                color: Colors.blueAccent,
                                shadows: [
                                  Shadow(
                                    color: Colors.blue,
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                            )
                          : const Text(
                              "Touch the wooden clock...",
                              key: ValueKey('running'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: Colors.white70,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
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

class ClockPainter extends CustomPainter {
  final double progress;
  final bool isStopped;

  ClockPainter({required this.progress, required this.isStopped});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clock ticks
    final tickPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * pi / 180;
      final innerRadius = radius - (i % 3 == 0 ? 20 : 10);
      final outerRadius = radius - 5;
      
      final p1 = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Hands
    final hoursAngle = (progress * 2 * pi * 2) - pi / 2; // Slow
    final minutesAngle = (progress * 2 * pi * 12) - pi / 2; // Faster
    final secondsAngle = (progress * 2 * pi * 60) - pi / 2; // Fastest

    // Draw Hour Hand
    _drawHand(canvas, center, hoursAngle, radius * 0.4, 6, const Color(0xFFD7CCC8));
    // Draw Minute Hand
    _drawHand(canvas, center, minutesAngle, radius * 0.6, 4, const Color(0xFFBCAAA4));
    // Draw Second Hand
    _drawHand(
      canvas, 
      center, 
      secondsAngle, 
      radius * 0.7, 
      2, 
      isStopped ? Colors.blueAccent : const Color(0xFFEF9A9A)
    );

    // Center dot
    canvas.drawCircle(
      center, 
      8, 
      Paint()..color = isStopped ? Colors.blueAccent : const Color(0xFFD7CCC8)
    );
  }

  void _drawHand(Canvas canvas, Offset center, double angle, double length, double width, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final endPoint = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    canvas.drawLine(center, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isStopped != isStopped;
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double decay;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.decay,
    required this.color,
    required this.size,
  });

  void update() {
    x += vx;
    y += vy;
    life -= decay;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      if (p.life > 0) {
        final paint = Paint()
          ..color = p.color.withOpacity(p.life.clamp(0.0, 1.0))
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0); // Magical glow
        
        canvas.drawCircle(
          Offset(center.dx + p.x, center.dy + p.y), 
          p.size, 
          paint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true; // Continuously repaint as particles update
  }
}
