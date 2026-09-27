import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            Text('Settings', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 24),
            const _Section(
              title: 'Appearance',
              children: [
                ListTile(leading: Icon(Icons.dark_mode_outlined), title: Text('Dark appearance'), subtitle: Text('Cinematic dark theme is active')),
                ListTile(leading: Icon(Icons.palette_outlined), title: Text('Artwork accents'), subtitle: Text('Use subtle artwork-derived color where available')),
              ],
            ),
            const _Section(
              title: 'Playback',
              children: [
                ListTile(leading: Icon(Icons.high_quality_outlined), title: Text('Streaming quality'), subtitle: Text('Source quality from the open music provider')),
                ListTile(leading: Icon(Icons.storage_outlined), title: Text('Audio cache'), subtitle: Text('Streaming audio is not permanently downloaded')),
              ],
            ),
            const _Section(
              title: 'About',
              children: [
                ListTile(leading: Icon(Icons.info_outline), title: Text('Aurora'), subtitle: Text('Personal open-music player')),
                ListTile(leading: Icon(Icons.code_rounded), title: Text('Open-source licenses')),
              ],
            ),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: .55), letterSpacing: 1.2, fontSize: 12))),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Material(color: const Color(0x1fffffff), child: Column(children: children))),
        ]),
      );
}
