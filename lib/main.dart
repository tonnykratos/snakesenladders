import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const SnakesAndLaddersApp());
}

class SnakesAndLaddersApp extends StatelessWidget {
  const SnakesAndLaddersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snakes & Ladders Epic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ==================== SPLASH SCREEN ====================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to Mode Select after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const GameModeSelectScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF311042)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing Icon Logo
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.6),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.casino,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'SNAKES & LADDERS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The Ultimate Epic Board Adventure',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 80),
                    // Credits Footer
                    Column(
                      children: [
                        Text(
                          'DEVELOPED BY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tonny Kratos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF59E0B),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== MODELS ====================

class Player {
  final int id;
  String name;
  Color color;
  int position; // 1 to 100 (0 means start before 1)
  IconData icon;
  bool isAi;

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.position = 0,
    required this.icon,
    this.isAi = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
        'position': position,
        'icon': icon.codePoint,
        'isAi': isAi,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'],
        color: Color(json['color']),
        position: json['position'],
        icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
        isAi: json['isAi'] ?? false,
      );
}

class BoardEntity {
  final int start;
  final int end;
  final bool isLadder;

  const BoardEntity({
    required this.start,
    required this.end,
    required this.isLadder,
  });
}

const List<BoardEntity> snakesAndLadders = [
  // Ladders
  BoardEntity(start: 2, end: 38, isLadder: true),
  BoardEntity(start: 7, end: 14, isLadder: true),
  BoardEntity(start: 8, end: 31, isLadder: true),
  BoardEntity(start: 15, end: 26, isLadder: true),
  BoardEntity(start: 21, end: 42, isLadder: true),
  BoardEntity(start: 28, end: 84, isLadder: true),
  BoardEntity(start: 36, end: 44, isLadder: true),
  BoardEntity(start: 51, end: 67, isLadder: true),
  BoardEntity(start: 71, end: 91, isLadder: true),
  BoardEntity(start: 78, end: 98, isLadder: true),
  BoardEntity(start: 87, end: 94, isLadder: true),

  // Snakes
  BoardEntity(start: 16, end: 6, isLadder: false),
  BoardEntity(start: 46, end: 25, isLadder: false),
  BoardEntity(start: 49, end: 11, isLadder: false),
  BoardEntity(start: 62, end: 19, isLadder: false),
  BoardEntity(start: 64, end: 60, isLadder: false),
  BoardEntity(start: 74, end: 53, isLadder: false),
  BoardEntity(start: 89, end: 68, isLadder: false),
  BoardEntity(start: 92, end: 88, isLadder: false),
  BoardEntity(start: 95, end: 75, isLadder: false),
  BoardEntity(start: 99, end: 80, isLadder: false),
];

// ==================== GAME MODE SELECTION ====================

class GameModeSelectScreen extends StatelessWidget {
  const GameModeSelectScreen({super.key});

  Future<String> _getLocalIP() async {
    try {
      for (var interface in await io.NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == io.InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '192.168.1.50';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF311042)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.casino,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SNAKES & LADDERS EPIC',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose Game Mode',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Mode 1: Quick Play vs AI
                    _buildModeCard(
                      context,
                      title: 'Play vs Computer (AI)',
                      subtitle: '1 Human vs 3 AI Bot opponents',
                      icon: Icons.smart_toy,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        List<Player> aiPlayers = [
                          Player(id: 1, name: 'You (Human)', color: const Color(0xFFEF4444), icon: Icons.person, isAi: false),
                          Player(id: 2, name: 'AI Bot 1', color: const Color(0xFF3B82F6), icon: Icons.smart_toy, isAi: true),
                          Player(id: 3, name: 'AI Bot 2', color: const Color(0xFF10B981), icon: Icons.android, isAi: true),
                          Player(id: 4, name: 'AI Bot 3', color: const Color(0xFFF59E0B), icon: Icons.precision_manufacturing, isAi: true),
                        ];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(players: aiPlayers),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mode 2: Pass & Play with Bot option
                    _buildModeCard(
                      context,
                      title: 'Pass & Play / Custom Bots',
                      subtitle: 'Configure players & toggle Human or AI bots',
                      icon: Icons.phone_android,
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameSetupScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mode 3: Host LAN Game
                    _buildModeCard(
                      context,
                      title: 'Host Wi-Fi Game',
                      subtitle: 'Create a room on Wi-Fi for others to join',
                      icon: Icons.wifi,
                      color: const Color(0xFF10B981),
                      onTap: () async {
                        String ip = await _getLocalIP();
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HostLobbyScreen(localIp: ip),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mode 4: Join LAN Game
                    _buildModeCard(
                      context,
                      title: 'Join Wi-Fi Game',
                      subtitle: 'Connect to another player\'s room on Wi-Fi',
                      icon: Icons.group_add,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinGameScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}

// ==================== SETUP / LOBBY SCREEN (LOCAL WITH BOT TOGGLE) ====================

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _playerCount = 4;
  final List<String> _names = ['Player 1', 'AI Bot 1', 'AI Bot 2', 'AI Bot 3'];
  final List<bool> _isAiList = [false, true, true, true];
  final List<Color> _colors = [
    const Color(0xFFEF4444), // Red
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Amber
  ];
  final List<IconData> _icons = [
    Icons.person,
    Icons.smart_toy,
    Icons.android,
    Icons.precision_manufacturing,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Configure Players & Bots'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF311042)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Number of Players',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [2, 3, 4].map((count) {
                              final isSelected = _playerCount == count;
                              return GestureDetector(
                                onTap: () => setState(() => _playerCount = count),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF6366F1),
                                              Color(0xFF8B5CF6),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$count Players',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Player Profiles & Bot Toggle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(_playerCount, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _colors[index],
                                    child: Icon(
                                      _isAiList[index] ? Icons.smart_toy : _icons[index],
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: _names[index],
                                      ),
                                      onChanged: (val) => _names[index] = val,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.05,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Human / AI Switch Button
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isAiList[index] = !_isAiList[index];
                                        if (_isAiList[index] && _names[index].startsWith('Player')) {
                                          _names[index] = 'AI Bot ${index + 1}';
                                        } else if (!_isAiList[index] && _names[index].startsWith('AI')) {
                                          _names[index] = 'Player ${index + 1}';
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _isAiList[index] ? const Color(0xFFEC4899) : const Color(0xFF6366F1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _isAiList[index] ? '🤖 AI Bot' : '👤 Human',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          List<Player> players = [];
                          for (int i = 0; i < _playerCount; i++) {
                            players.add(
                              Player(
                                id: i + 1,
                                name: _names[i].isEmpty
                                    ? (_isAiList[i] ? 'AI Bot ${i + 1}' : 'Player ${i + 1}')
                                    : _names[i],
                                color: _colors[i],
                                icon: _isAiList[i] ? Icons.smart_toy : _icons[i],
                                isAi: _isAiList[i],
                              ),
                            );
                          }
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(players: players),
                            ),
                          );
                        },
                        child: const Text(
                          'START MATCH',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== HOST LOBBY (LAN MULTIPLAYER) ====================

class HostLobbyScreen extends StatefulWidget {
  final String localIp;
  const HostLobbyScreen({super.key, required this.localIp});

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  io.HttpServer? _server;
  final List<io.WebSocket> _clients = [];
  final List<Player> _players = [
    Player(id: 1, name: 'Host (P1)', color: const Color(0xFFEF4444), icon: Icons.rocket_launch, isAi: false),
  ];

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    try {
      _server = await io.HttpServer.bind(io.InternetAddress.anyIPv4, 4040);

      _server!.listen((io.HttpRequest request) async {
        if (io.WebSocketTransformer.isUpgradeRequest(request)) {
          io.WebSocket socket = await io.WebSocketTransformer.upgrade(request);
          _clients.add(socket);

          int newId = _players.length + 1;
          if (newId <= 4) {
            List<Color> colors = [
              const Color(0xFFEF4444),
              const Color(0xFF3B82F6),
              const Color(0xFF10B981),
              const Color(0xFFF59E0B),
            ];
            List<IconData> icons = [
              Icons.rocket_launch,
              Icons.flash_on,
              Icons.star,
              Icons.shield,
            ];

            Player newPlayer = Player(
              id: newId,
              name: 'Player $newId',
              color: colors[newId - 1],
              icon: icons[newId - 1],
              isAi: false,
            );

            setState(() {
              _players.add(newPlayer);
            });

            socket.add(jsonEncode({
              'type': 'WELCOME',
              'assignedId': newId,
              'players': _players.map((p) => p.toJson()).toList(),
            }));

            _broadcastPlayers();
          }

          socket.listen(
            (data) {},
            onDone: () {
              _clients.remove(socket);
            },
          );
        }
      });
    } catch (_) {}
  }

  void _broadcastPlayers() {
    String payload = jsonEncode({
      'type': 'PLAYERS_UPDATE',
      'players': _players.map((p) => p.toJson()).toList(),
    });
    for (var c in _clients) {
      c.add(payload);
    }
  }

  @override
  void dispose() {
    for (var c in _clients) {
      c.close();
    }
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Hosting LAN Game Room'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF311042)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.wifi, size: 64, color: Color(0xFF10B981)),
                const SizedBox(height: 16),
                const Text(
                  'Share this IP with other players on your Wi-Fi:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Text(
                    widget.localIp,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Connected Players (Up to 4):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      var p = _players[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: p.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.color),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: p.color, child: Icon(p.icon, color: Colors.white)),
                            const SizedBox(width: 16),
                            Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: p.color, fontSize: 16)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            players: _players,
                            isHost: true,
                            serverSockets: _clients,
                            localPlayerId: 1,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'START MULTIPLAYER MATCH',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== JOIN GAME SCREEN ====================

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.');
  bool _connecting = false;
  String _status = '';

  void _connectToHost() async {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    setState(() {
      _connecting = true;
      _status = 'Connecting to $ip:4040...';
    });

    try {
      io.WebSocket socket = await io.WebSocket.connect('ws://$ip:4040/ws').timeout(const Duration(seconds: 5));

      socket.listen(
        (data) {
          try {
            var decoded = jsonDecode(data);
            if (decoded['type'] == 'WELCOME' || decoded['type'] == 'PLAYERS_UPDATE') {
              List<dynamic> playerListJson = decoded['players'];
              List<Player> players = playerListJson.map((p) => Player.fromJson(p)).toList();
              int assignedId = decoded['assignedId'] ?? 2;

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      players: players,
                      isHost: false,
                      clientSocket: socket,
                      localPlayerId: assignedId,
                    ),
                  ),
                );
              }
            }
          } catch (_) {}
        },
        onDone: () {},
        onError: (_) {
          setState(() {
            _connecting = false;
            _status = 'Connection failed or closed.';
          });
        },
      );
    } catch (_) {
      setState(() {
        _connecting = false;
        _status = 'Could not connect. Check IP and Wi-Fi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Join Wi-Fi Game Room'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF311042)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_add, size: 64, color: Color(0xFFF59E0B)),
                const SizedBox(height: 24),
                const Text(
                  'Enter Host IP Address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ipController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    hintText: 'e.g. 192.168.1.50',
                  ),
                ),
                const SizedBox(height: 20),
                if (_status.isNotEmpty)
                  Text(_status, style: const TextStyle(color: Colors.amber, fontSize: 14)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _connecting ? null : _connectToHost,
                    child: Text(
                      _connecting ? 'CONNECTING...' : 'JOIN ROOM',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== GAME SCREEN & BOARD ====================

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final bool isHost;
  final io.WebSocket? clientSocket;
  final List<io.WebSocket>? serverSockets;
  final int localPlayerId;

  const GameScreen({
    super.key,
    required this.players,
    this.isHost = false,
    this.clientSocket,
    this.serverSockets,
    this.localPlayerId = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<Player> _players;
  int _currentPlayerIndex = 0;
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMoving = false;
  final List<String> _gameLogs = [];
  Player? _winner;

  late AnimationController _diceAnimController;

  @override
  void initState() {
    super.initState();
    _players = widget.players;
    _diceAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _addLog('🎮 Game started with ${_players.length} players! ${_players[0].name}\'s turn.');

    if (widget.clientSocket != null) {
      widget.clientSocket!.listen((data) {
        try {
          var decoded = jsonDecode(data);
          if (decoded['type'] == 'STATE_UPDATE') {
            setState(() {
              _currentPlayerIndex = decoded['currentPlayerIndex'];
              _diceValue = decoded['diceValue'];
              List<dynamic> pList = decoded['players'];
              for (int i = 0; i < pList.length; i++) {
                _players[i].position = pList[i]['position'];
              }
              if (decoded['log'] != null) {
                _gameLogs.insert(0, decoded['log']);
              }
              if (decoded['winner'] != null) {
                _winner = _players.firstWhere((p) => p.id == decoded['winner']);
                _showWinDialog(_winner!);
              }
            });
          }
        } catch (_) {}
      });
    }

    _checkAiTurn();
  }

  @override
  void dispose() {
    _diceAnimController.dispose();
    widget.clientSocket?.close();
    if (widget.serverSockets != null) {
      for (var s in widget.serverSockets!) {
        s.close();
      }
    }
    super.dispose();
  }

  void _addLog(String msg) {
    setState(() {
      _gameLogs.insert(0, msg);
      if (_gameLogs.length > 20) _gameLogs.removeLast();
    });
  }

  void _broadcastState([String? logMsg, int? winnerId]) {
    if (widget.serverSockets == null) return;
    String payload = jsonEncode({
      'type': 'STATE_UPDATE',
      'currentPlayerIndex': _currentPlayerIndex,
      'diceValue': _diceValue,
      'players': _players.map((p) => p.toJson()).toList(),
      'log': logMsg,
      'winner': winnerId,
    });
    for (var s in widget.serverSockets!) {
      s.add(payload);
    }
  }

  void _checkAiTurn() {
    if (_winner != null || _isRolling || _isMoving) return;
    if (_players[_currentPlayerIndex].isAi) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && _players[_currentPlayerIndex].isAi && _winner == null) {
          _rollDice();
        }
      });
    }
  }

  Future<void> _rollDice() async {
    if (_isRolling || _isMoving || _winner != null) return;

    if (widget.clientSocket != null && _players[_currentPlayerIndex].id != widget.localPlayerId) {
      _addLog('⚠️ Wait for your turn!');
      return;
    }

    setState(() {
      _isRolling = true;
    });

    _diceAnimController.repeat();
    await Future.delayed(const Duration(milliseconds: 800));
    _diceAnimController.stop();

    final randomValue = math.Random().nextInt(6) + 1;

    setState(() {
      _diceValue = randomValue;
      _isRolling = false;
    });

    String logMsg = '🎲 ${_players[_currentPlayerIndex].name} rolled a $randomValue!';
    _addLog(logMsg);

    await _movePlayer(_players[_currentPlayerIndex], randomValue);
  }

  Future<void> _movePlayer(Player player, int steps) async {
    setState(() {
      _isMoving = true;
    });

    int targetPosition = player.position + steps;

    if (targetPosition > 100) {
      targetPosition = player.position;
      _addLog('⚠️ ${player.name} needs exact roll to reach 100! Stays at ${player.position}.');
    } else {
      for (int p = player.position + 1; p <= targetPosition; p++) {
        setState(() {
          player.position = p;
        });
        await Future.delayed(const Duration(milliseconds: 150));
      }

      for (var entity in snakesAndLadders) {
        if (entity.start == player.position) {
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            player.position = entity.end;
          });
          if (entity.isLadder) {
            _addLog('🪜 YAY! ${player.name} climbed a ladder from ${entity.start} to ${entity.end}!');
          } else {
            _addLog('🐍 OOPS! ${player.name} bitten by a snake at ${entity.start} down to ${entity.end}!');
          }
          break;
        }
      }
    }

    if (player.position == 100) {
      setState(() {
        _winner = player;
      });
      _broadcastState('🎉 ${player.name} wins the game!', player.id);
      _showWinDialog(player);
      return;
    }

    setState(() {
      _isMoving = false;
      if (_diceValue == 6) {
        _addLog('🔥 Bonus Turn! ${_players[_currentPlayerIndex].name} rolled a 6 and gets another turn!');
      } else {
        _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      }
    });

    _broadcastState();
    _checkAiTurn();
  }

  void _showWinDialog(Player winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Color(0xFFF59E0B)),
            const SizedBox(height: 16),
            Text(
              '🎉 ${winner.name} WINS! 🎉',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Congratulations! ${winner.name} conquered the Snakes & Ladders epic board!',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GameModeSelectScreen()),
              );
            },
            child: const Text('Main Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = _players[_currentPlayerIndex];
    final isMyTurn = (widget.clientSocket == null && !currentPlayer.isAi) || (currentPlayer.id == widget.localPlayerId);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 0,
        title: Text(
          currentPlayer.isAi ? '🤖 AI Thinking...' : (widget.clientSocket != null ? 'Multiplayer (Player ${widget.localPlayerId})' : 'Snakes & Ladders'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GameModeSelectScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          return isWide
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: BoardWidget(
                              players: _players,
                              snakesAndLadders: snakesAndLadders,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          border: Border(left: BorderSide(color: Colors.white.withOpacity(0.08))),
                        ),
                        child: Column(
                          children: [
                            _buildPlayerStatusBar(),
                            const SizedBox(height: 20),
                            _buildDiceSection(currentPlayer, isMyTurn),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Live Activity Feed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                            ),
                            const SizedBox(height: 8),
                            Expanded(child: _buildLogView()),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Top Big Turn Banner & Roll Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [currentPlayer.color.withOpacity(0.4), const Color(0xFF1E1B4B)],
                        ),
                        border: Border(bottom: BorderSide(color: currentPlayer.color, width: 3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: currentPlayer.color,
                                radius: 16,
                                child: Icon(currentPlayer.isAi ? Icons.smart_toy : currentPlayer.icon, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentPlayer.isAi ? "🤖 AI BOT TURN" : "NOW PLAYING",
                                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.2),
                                  ),
                                  Text(
                                    currentPlayer.name,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: currentPlayer.color),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMyTurn ? currentPlayer.color : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: isMyTurn ? _rollDice : null,
                            icon: Icon(currentPlayer.isAi ? Icons.smart_toy : Icons.casino, size: 16),
                            label: Text(
                              _isRolling ? '...' : (currentPlayer.isAi ? 'AI ROLLING' : 'ROLL ($_diceValue)'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // MAXIMUM EXPANDED BOARD FILLING 100% OF REMAINING VERTICAL SPACE
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: BoardWidget(
                            players: _players,
                            snakesAndLadders: snakesAndLadders,
                          ),
                        ),
                      ),
                    ),
                    // Compact Standings Bar at Bottom
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _players.map((p) {
                          bool isTurn = p == currentPlayer;
                          return Container(
                            width: 95,
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTurn ? p.color.withOpacity(0.3) : Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isTurn ? p.color : Colors.white12, width: isTurn ? 2 : 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: p.color, fontSize: 11), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 1),
                                Text('Tile ${p.position}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildPlayerStatusBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Players Standings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        ..._players.map((p) {
          final isTurn = p == _players[_currentPlayerIndex];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTurn ? p.color.withOpacity(0.15) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isTurn ? p.color : Colors.white.withOpacity(0.1), width: isTurn ? 2 : 1),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: p.color, radius: 16, child: Icon(p.icon, size: 16, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: p.color, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                  child: Text('Tile ${p.position}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDiceSection(Player currentPlayer, bool isMyTurn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [currentPlayer.color.withOpacity(0.2), const Color(0xFF1E1B4B)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentPlayer.color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(currentPlayer.icon, color: currentPlayer.color),
              const SizedBox(width: 8),
              Text(
                isMyTurn ? "${currentPlayer.name}'s Turn (YOURS)" : "${currentPlayer.name}'s Turn",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: currentPlayer.color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isMyTurn ? currentPlayer.color : Colors.grey,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isMyTurn ? _rollDice : null,
            icon: const Icon(Icons.casino),
            label: Text(
              _isRolling ? 'Rolling...' : 'ROLL DICE ($_diceValue)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogView() {
    return ListView.builder(
      itemCount: _gameLogs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            _gameLogs[index],
            style: TextStyle(
              fontSize: 12,
              color: index == 0 ? Colors.white : Colors.white60,
              fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      },
    );
  }
}

// ==================== BOARD WIDGET & PAINTER ====================

class BoardWidget extends StatelessWidget {
  final List<Player> players;
  final List<BoardEntity> snakesAndLadders;

  const BoardWidget({super.key, required this.players, required this.snakesAndLadders});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, spreadRadius: 3),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            children: List.generate(10, (rowIndex) {
              int actualRowFromTop = rowIndex;
              return Expanded(
                child: Row(
                  children: List.generate(10, (colIndex) {
                    int tileNum = _getTileNumber(actualRowFromTop, colIndex);
                    bool isAlt = (tileNum + rowIndex) % 2 == 0;

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: isAlt
                              ? const Color(0xFF334155).withOpacity(0.9)
                              : const Color(0xFF475569).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 1,
                              left: 2,
                              child: Text(
                                '$tileNum',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: BoardEntitiesPainter(snakesAndLadders: snakesAndLadders),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double w = constraints.maxWidth;
                double h = constraints.maxHeight;
                double tileW = w / 10;
                double tileH = h / 10;

                Map<int, List<Player>> posMap = {};
                for (var p in players) {
                  int pos = p.position == 0 ? 1 : p.position;
                  posMap.putIfAbsent(pos, () => []).add(p);
                }

                List<Widget> tokenWidgets = [];

                posMap.forEach((tileNum, tilePlayers) {
                  Offset center = _getTileCenter(tileNum, tileW, tileH);

                  for (int i = 0; i < tilePlayers.length; i++) {
                    var player = tilePlayers[i];
                    double offsetX = (i % 2 == 0 ? -1 : 1) * (tilePlayers.length > 2 ? 5.0 : 3.0);
                    double offsetY = (i < 2 ? -1 : 1) * (tilePlayers.length > 2 ? 5.0 : 3.0);
                    if (tilePlayers.length == 1) {
                      offsetX = 0;
                      offsetY = 0;
                    }

                    tokenWidgets.add(
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: center.dx + offsetX - 9,
                        top: center.dy + offsetY - 9,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: player.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: player.color.withOpacity(0.9),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              player.isAi ? Icons.smart_toy : player.icon,
                              size: 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                });

                return Stack(children: tokenWidgets);
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getTileNumber(int rowFromTop, int col) {
    int rowFromBottom = 9 - rowFromTop;
    if (rowFromBottom % 2 == 0) {
      return rowFromBottom * 10 + col + 1;
    } else {
      return rowFromBottom * 10 + (9 - col) + 1;
    }
  }

  Offset _getTileCenter(int tileNum, double tileW, double tileH) {
    int t = tileNum - 1;
    int rowFromBottom = t ~/ 10;
    int rowFromTop = 9 - rowFromBottom;
    int col;
    if (rowFromBottom % 2 == 0) {
      col = t % 10;
    } else {
      col = t % 10 == 0 ? 0 : 9 - (t % 10);
    }
    return Offset((col + 0.5) * tileW, (rowFromTop + 0.5) * tileH);
  }
}

class BoardEntitiesPainter extends CustomPainter {
  final List<BoardEntity> snakesAndLadders;

  BoardEntitiesPainter({required this.snakesAndLadders});

  @override
  void paint(Canvas canvas, Size size) {
    double tileW = size.width / 10;
    double tileH = size.height / 10;

    for (var entity in snakesAndLadders) {
      Offset startPt = _getTileCenter(entity.start, tileW, tileH);
      Offset endPt = _getTileCenter(entity.end, tileW, tileH);

      if (entity.isLadder) {
        final paintRail = Paint()
          ..color = const Color(0xFFF59E0B)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final paintRung = Paint()
          ..color = const Color(0xFFFCD34D)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        Offset dir = endPt - startPt;
        Offset normal = Offset(-dir.dy, dir.dx);
        if (normal.distance > 0) {
          normal = normal / normal.distance * 3.0;
        }

        canvas.drawLine(startPt + normal, endPt + normal, paintRail);
        canvas.drawLine(startPt - normal, endPt - normal, paintRail);

        int rungs = 6;
        for (int i = 1; i < rungs; i++) {
          double t = i / rungs;
          Offset p1 = (startPt + normal) + (endPt - startPt) * t;
          Offset p2 = (startPt - normal) + (endPt - startPt) * t;
          canvas.drawLine(p1, p2, paintRung);
        }
      } else {
        final paintSnake = Paint()
          ..color = const Color(0xFFEF4444)
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final path = Path();
        path.moveTo(startPt.dx, startPt.dy);

        Offset controlPt = Offset(
          (startPt.dx + endPt.dx) / 2 + (startPt.dy > endPt.dy ? 15 : -15),
          (startPt.dy + endPt.dy) / 2 + (startPt.dx > endPt.dx ? 15 : -15),
        );

        path.quadraticBezierTo(controlPt.dx, controlPt.dy, endPt.dx, endPt.dy);
        canvas.drawPath(path, paintSnake);

        final paintHead = Paint()..color = const Color(0xFFDC2626);
        canvas.drawCircle(startPt, 4.5, paintHead);
      }
    }
  }

  Offset _getTileCenter(int tileNum, double tileW, double tileH) {
    int t = tileNum - 1;
    int rowFromBottom = t ~/ 10;
    int rowFromTop = 9 - rowFromBottom;
    int col;
    if (rowFromBottom % 2 == 0) {
      col = t % 10;
    } else {
      col = t % 10 == 0 ? 0 : (9 - (t % 10));
    }
    return Offset((col + 0.5) * tileW, (rowFromTop + 0.5) * tileH);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
