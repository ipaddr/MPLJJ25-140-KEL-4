import 'package:flutter/material.dart';

class RegistrasiBerhasilScreen extends StatefulWidget {
  const RegistrasiBerhasilScreen({super.key});

  @override
  State<RegistrasiBerhasilScreen> createState() =>
      _RegistrasiBerhasilScreenState();
}

class _RegistrasiBerhasilScreenState extends State<RegistrasiBerhasilScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _checkController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  late Animation<double> _logoFade;
  late Animation<double> _checkScale;
  late Animation<double> _checkRotate;
  late Animation<double> _textFade;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkRotate = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack),
    );
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _buttonFade = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeIn,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _checkController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _goToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F5B99)),
          onPressed: () => _goToDashboard(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoFade,
                child: Image.asset('assets/images/logo.png', height: 100),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _textFade,
                child: const Text(
                  "Registrasi Pasien Berhasil",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07477C),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _checkController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _checkRotate.value * 3.14,
                    child: Transform.scale(
                      scale: _checkScale.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.1),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 80,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _textFade,
                child: const Text(
                  "Silahkan melakukan penjadwalan pemeriksaan pada menu utama.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF07477C)),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _buttonFade,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.dashboard, size: 20),
                    label: const Text("Kembali ke Dashboard"),
                    onPressed: () => _goToDashboard(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07477C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      shadowColor: Colors.blueGrey.withOpacity(0.2),
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
}
