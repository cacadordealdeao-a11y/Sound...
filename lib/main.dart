import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() => runApp(const RetroAudioApp());

class RetroAudioApp extends StatefulWidget {
  const RetroAudioApp({super.key});
  @override
  State<RetroAudioApp> createState() => _RetroAudioAppState();
}

class _RetroAudioAppState extends State<RetroAudioApp> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF5F5DC);
    final Color textColor = isDarkMode ? const Color(0xFFF5F5DC) : const Color(0xFF808080);
    return MaterialApp(
      title: 'SOUND BIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: bgColor, fontFamily: 'monospace'),
      home: HomeScreen(
        textColor: textColor, 
        isDarkMode: isDarkMode,
        toggleTheme: () => setState(() => isDarkMode = !isDarkMode)
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Color textColor;
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.textColor, required this.toggleTheme, required this.isDarkMode});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildMusicList(),
      Center(child: Text("PLAYLISTS", style: TextStyle(color: widget.textColor))),
      Center(child: Text("FAVORITAS", style: TextStyle(color: widget.textColor))),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("SOUND BIT", style: TextStyle(color: Color(0xFF808080), fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.settings, color: widget.textColor), onPressed: () => _showSettings(context))],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        currentIndex: _selectedIndex,
        selectedItemColor: widget.textColor,
        unselectedItemColor: widget.textColor.withOpacity(0.3),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'MÚSICAS'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'PLAYLISTS'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'FAVORITAS'),
        ],
      ),
    );
  }

  Widget _buildMusicList() {
    return FutureBuilder<List<SongModel>>(
      future: _audioQuery.querySongs(sortType: null, orderType: OrderType.ASC_OR_SMALLER, uriType: UriType.EXTERNAL, ignoreCase: true),
      builder: (context, item) {
        if (item.data == null) return const Center(child: CircularProgressIndicator());
        if (item.data!.isEmpty) return const Center(child: Text("SEM MÚSICAS"));
        return ListView.builder(
          itemCount: item.data!.length,
          itemBuilder: (context, index) => ListTile(
            leading: Icon(Icons.audiotrack, color: widget.textColor),
            title: Text(item.data![index].title, style: TextStyle(color: widget.textColor, fontSize: 14)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerDisplay(song: item.data![index], player: _player, textColor: widget.textColor))),
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SwitchListTile(
          title: Text("TEMA ESCURO", style: TextStyle(color: widget.textColor)),
          value: widget.isDarkMode,
          onChanged: (val) { widget.toggleTheme(); Navigator.pop(context); },
        ),
      ),
    );
  }
}

class PlayerDisplay extends StatefulWidget {
  final SongModel song;
  final AudioPlayer player;
  final Color textColor;
  const PlayerDisplay({super.key, required this.song, required this.player, required this.textColor});
  @override
  State<PlayerDisplay> createState() => _PlayerDisplayState();
}

class _PlayerDisplayState extends State<PlayerDisplay> {
  @override
  void initState() { super.initState(); _play(); }
  void _play() async {
    try {
      await widget.player.setAudioSource(AudioSource.uri(Uri.parse(widget.song.uri!)));
      widget.player.play();
    } catch (e) { debugPrint("Erro: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.song.title.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: widget.textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.skip_previous, color: widget.textColor, size: 40),
                Icon(Icons.pause, color: widget.textColor, size: 60),
                Icon(Icons.skip_next, color: widget.textColor, size: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
