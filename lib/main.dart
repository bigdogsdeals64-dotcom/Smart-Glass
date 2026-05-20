import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(const ZacheryGrokApp());

class ZacheryGrokApp extends StatelessWidget {
  const ZacheryGrokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Glass',
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

class MemoryItem {
  const MemoryItem(this.title, this.subtitle);
  final String title;
  final String subtitle;
  Map<String, String> toJson() => {'title': title, 'subtitle': subtitle};
}

class MemoryStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'smart_glass_memory_items';

  static Future<List<MemoryItem>> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((entry) {
      final map = entry as Map<String, dynamic>;
      return MemoryItem(map['title'] as String? ?? 'Memory Note', map['subtitle'] as String? ?? '');
    }).toList();
  }

  static Future<void> save(List<MemoryItem> items) async {
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await _storage.write(key: _key, value: encoded);
  }

  static Future<void> add(MemoryItem item) async {
    final items = await load();
    await save([item, ...items]);
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
  bool _setupViewed = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final savedKey = await _storage.read(key: 'xai_grok_key');
    final setup = await _storage.read(key: 'smart_glass_setup_viewed');
    if (!mounted) return;
    setState(() {
      _apiKey = savedKey;
      _apiKeyController.text = savedKey ?? '';
      _setupViewed = setup == 'true';
    });
  }

  Future<void> _saveApiKey(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await _storage.write(key: 'xai_grok_key', value: trimmed);
    if (!mounted) return;
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
          decoration: const InputDecoration(hintText: 'Paste your API key here', prefixIcon: Icon(Icons.key)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
            onPressed: () async {
              await _saveApiKey(_apiKeyController.text);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _showMessage('API key saved on this phone.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectGlasses() async {
    await _storage.write(key: 'smart_glass_setup_viewed', value: 'true');
    if (!mounted) return;
    setState(() => _setupViewed = true);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Smart Glass Setup'),
        content: const Text(
          'Use the Meta View app and Android Bluetooth to pair your glasses first.\n\n'
          'After pairing, this app can be used as your Smart Glass control center for memory notes, assistant setup, and future voice features.',
          style: TextStyle(height: 1.35),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
      ),
    );
  }

  Future<void> _teachMemory() async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Teach Smart Glass'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: noteController, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'What should I remember?')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
            onPressed: () async {
              final title = titleController.text.trim().isEmpty ? 'Memory Note' : titleController.text.trim();
              final note = noteController.text.trim();
              if (note.isEmpty) return;
              await MemoryStore.add(MemoryItem(title, note));
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _showMessage('Memory saved.');
            },
            child: const Text('Save Memory'),
          ),
        ],
      ),
    );
    titleController.dispose();
    noteController.dispose();
  }

  void _openTextComposer() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ComposeScreen(mode: ComposeMode.text)));
  }

  void _openCallPad() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ComposeScreen(mode: ComposeMode.call)));
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Glass'), actions: [IconButton(icon: const Icon(Icons.settings), onPressed: _showApiKeyDialog)]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF070707), Color(0xFF111111), Color(0xFF050505)]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatusPanel(apiKeySaved: _apiKey != null && _apiKey!.isNotEmpty, setupViewed: _setupViewed),
                  const SizedBox(height: 24),
                  const _RobotOrb(),
                  const SizedBox(height: 26),
                  const Text('Hello Zachery,\nhow can I assist you today?', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 26),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _ActionButton(icon: Icons.visibility, label: 'Connect Glasses', gold: true, onPressed: _connectGlasses),
                      _ActionButton(icon: Icons.memory, label: 'Memory Bank', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryBankScreen()))),
                      _ActionButton(icon: Icons.sms, label: 'Send Text', onPressed: _openTextComposer),
                      _ActionButton(icon: Icons.call, label: 'Make Call', onPressed: _openCallPad),
                      _ActionButton(icon: Icons.school, label: 'Teach Memory', gold: true, onPressed: _teachMemory),
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
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(color: const Color(0xFF151515), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: child);
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.apiKeySaved, required this.setupViewed});
  final bool apiKeySaved;
  final bool setupViewed;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          const Text('Assistant Status', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const _StatusLine(icon: Icons.wifi, text: 'Internet Online', active: true),
          const _StatusLine(icon: Icons.mic, text: 'Mic Ready', active: true),
          _StatusLine(icon: Icons.visibility_outlined, text: setupViewed ? 'Smart Glass Setup Viewed' : 'Smart Glass Setup Needed', active: setupViewed),
          _StatusLine(icon: Icons.key, text: apiKeySaved ? 'API Key Saved' : 'API Key Needed', active: apiKeySaved),
        ]),
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: active ? const Color(0xFFFFD700) : Colors.grey, size: 20), const SizedBox(width: 8), Text(text, style: TextStyle(color: active ? Colors.white : Colors.grey))]),
      );
}

class _RobotOrb extends StatelessWidget {
  const _RobotOrb();
  @override
  Widget build(BuildContext context) => Container(
        width: 230,
        height: 230,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF151515), border: Border.all(color: const Color(0xFFFFD700), width: 2), boxShadow: const [BoxShadow(color: Color(0x55FFD700), blurRadius: 35, spreadRadius: 4)]),
        child: const Icon(Icons.smart_toy, size: 120, color: Color(0xFFFFD700)),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onPressed, this.gold = false});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool gold;
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: gold ? const Color(0xFFFFD700) : const Color(0xFF1B1B1B), foregroundColor: gold ? Colors.black : Colors.white), icon: Icon(icon), label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), onPressed: onPressed);
}

enum ComposeMode { text, call }

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, required this.mode});
  final ComposeMode mode;
  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final numberController = TextEditingController();
  final messageController = TextEditingController();
  @override
  void dispose() {
    numberController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isText = widget.mode == ComposeMode.text;
    return Scaffold(
      appBar: AppBar(title: Text(isText ? 'Send Text' : 'Make Call')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(child: Padding(padding: const EdgeInsets.all(16), child: Text(isText ? 'Type a number and message here. Phone-app sending can be connected in the Android permission build.' : 'Type a number here. Dialer launch can be connected in the Android permission build.', style: const TextStyle(color: Colors.grey, height: 1.4)))),
        const SizedBox(height: 16),
        TextField(controller: numberController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
        if (isText) ...[const SizedBox(height: 12), TextField(controller: messageController, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Message'))],
        const SizedBox(height: 16),
        ElevatedButton.icon(icon: Icon(isText ? Icons.sms : Icons.call), label: Text(isText ? 'Save Text Draft' : 'Save Call Number'), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved on screen. Android app handoff will be added next.')))),
      ]),
    );
  }
}

class MemoryBankScreen extends StatefulWidget {
  const MemoryBankScreen({super.key});
  @override
  State<MemoryBankScreen> createState() => _MemoryBankScreenState();
}

class _MemoryBankScreenState extends State<MemoryBankScreen> {
  List<MemoryItem> _items = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await MemoryStore.load();
    if (!mounted) return;
    setState(() => _items = loaded);
  }

  Future<void> _clearAll() async {
    await MemoryStore.save(const []);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _items.isEmpty ? const [MemoryItem('No saved memory yet', 'Tap Teach Memory on the home screen to save your first note.')] : _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Bank'), actions: [IconButton(onPressed: _clearAll, icon: const Icon(Icons.delete_outline))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const AppCard(child: Padding(padding: EdgeInsets.all(16), child: Text('Saved notes stay on this phone using secure storage.', style: TextStyle(color: Colors.grey, height: 1.5)))),
        const SizedBox(height: 16),
        for (final item in displayItems) AppCard(child: ListTile(leading: const Icon(Icons.memory, color: Color(0xFFFFD700)), title: Text(item.title), subtitle: Text(item.subtitle))),
      ]),
    );
  }
}
