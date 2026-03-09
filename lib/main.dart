import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() => runApp(const MaterialApp(home: SoundBitHome()));

class SoundBitHome extends StatelessWidget {
  const SoundBitHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(title: const Text("SOUND BIT"), backgroundColor: Colors.transparent, elevation: 0),
      body: const Center(child: Text("O seu App de Música Retro", style: TextStyle(color: Color(0xFF808080)))),
    );
  }
}
