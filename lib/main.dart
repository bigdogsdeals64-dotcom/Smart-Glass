import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(const ZacheryGrokApp());

class ZacheryGrokApp extends StatelessWidget {
  const ZacheryGrokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Glass",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF070707),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF070707),
          foregroundColor: Color(0xFFFFD700),
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B1B1B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF151515),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111111),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          ),
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final _storage = const FlutterSecureStorage();
  final _apiKeyController = TextEditingController();
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final savedKey = await _storage.read(key: 'xai_grok_key');
    setState(() {
      _apiKey = savedKey;
      _apiKeyController.text = savedKey ?? '';
    });
  }

  Future<void> _saveApiKey(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await _storage.write(key: 'xai_grok_key', value: trimmed);
    setState(() => _apiKey = trimmed);
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('xAI Grok API Key'),
        content: TextField(
          controller: _apiKeyController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Paste your API key here',
            prefixIcon: Icon(Icons.key),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              await _saveApiKey(_apiKeyController.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Glass'),
        actions: [
          IconButton(
            tooltip: 'API Key Settings',
            icon: const Icon(Icons.settings),
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070707), Color(0xFF111111), Color(0xFF050505)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatusPanel(apiKeySaved: _apiKey != null && _apiKey!.isNotEmpty),
                  const SizedBox(height: 24),
                  const _RobotOrb(),
                  const SizedBox(height: 26),
                  const Text(
                    'Hello Zachery,\nhow can I assist you today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.visibility,
                        label: 'Connect Glasses',
                        gold: true,
                        onPressed: () => _showComingSoon('Ray-Ban Meta connection'),
                      ),
                      _ActionButton(
                        icon: Icons.memory,
                        label: 'Memory Bank',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MemoryBankScreen()),
                        ),
                      ),
                      _ActionButton(
                        icon: Icons.sms,
                        label: 'Send Text',
                        onPressed: () => _showComingSoon('Send Text'),
                      ),
                      _ActionButton(
                        icon: Icons.call,
                        label: 'Make Call',
                        onPressed: () => _showComingSoon('Make Call'),
                      ),
                      _ActionButton(
                        icon: Icons.school,
                        label: 'Teach Memory',
                        gold: true,
                        onPressed: () => _showComingSoon('Teach Grok / Save to Memory'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be connected in the next build.')),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.apiKeySaved});

  final bool apiKeySaved;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              'Assistant Status',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _StatusLine(icon: Icons.wifi, text: 'Internet Online', active: true),
            _StatusLine(icon: Icons.mic, text: 'Mic Ready', active: true),
            _StatusLine(icon: Icons.visibility_outlined, text: 'Smart Glasses Ready', active: false),
            _StatusLine(icon: Icons.key, text: apiKeySaved ? 'API Key Saved' : 'API Key Needed', active: apiKeySaved),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.icon, required this.text, required this.active});

  final IconData icon;
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFFFFD700) : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: active ? Colors.white : Colors.grey)),
        ],
      ),
    );
  }
}

class _RobotOrb extends StatelessWidget {
  const _RobotOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 230,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151515),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x55FFD700), blurRadius: 35, spreadRadius: 4),
        ],
      ),
      child: const Icon(Icons.smart_toy, size: 120, color: Color(0xFFFFD700)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.gold = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold ? const Color(0xFFFFD700) : const Color(0xFF1B1B1B),
        foregroundColor: gold ? Colors.black : Colors.white,
      ),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: onPressed,
    );
  }
}

class MemoryBankScreen extends StatelessWidget {
  const MemoryBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Work Instruction - Procedure #7', 'Stored work instructions'),
      ('Personal Note', 'Your saved note'),
      ('Work Instruction - Procedure #6', 'Ready for details'),
      ('Personal Note', 'Ready for details'),
      ('Work Instruction - Procedure #5', 'Ready for details'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Bank')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Ray-Ban Meta: Not connected yet\nInternet: Online\nMemory: Local placeholder ready',
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            label: const Text('Teach New Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.memory, color: Color(0xFFFFD700)),
                title: Text(item.$1),
                subtitle: Text(item.$2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
